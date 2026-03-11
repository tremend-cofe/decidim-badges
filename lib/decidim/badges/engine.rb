# frozen_string_literal: true

require "rails"
require "decidim/core"
require "deface"

module Decidim
  module Badges
    # This is the engine that runs on the public interface of badges.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Badges

      initializer "decidim_badges.add_cells_view_paths", before: "decidim_core.add_cells_view_paths"  do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Badges::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Badges::Engine.root}/app/views")
      end

      initializer "decidim_badges.deface" do
        Rails.application.configure do
          config.deface.enabled = Decidim::Env.new("DEFACE_ENABLED", true).present?
        end
      end

      initializer "decidim_badges.add_badges" do
        Rails.application.config.to_prepare do
          Decidim::Gamification::BadgesController.prepend(Decidim::Badges::Overwrites::BadgesController)
          Decidim::Gamification::BadgesController.helper(Decidim::ResourceHelper)
        end
      end


      initializer "decidim_badges.register_badges" do
        Decidim::Badges.register_manifest(:followers) do |badge|
          badge.reset = ->(user) { user.followers.count }
        end
      end

      initializer "decidim_badges.register_badges.proposals", after: "decidim_badges.register_badges" do
        if Decidim.module_installed?(:proposals)

          Decidim::Badges.register_manifest(:proposals) do |badge|
            badge.reset = lambda { |model|
              Decidim::Coauthorship.where(
                coauthorable_type: "Decidim::Proposals::Proposal",
                author: model
              ).count
            }
          end

          Decidim::Badges.register_manifest(:accepted_proposals) do |badge|
            badge.reset = lambda { |model|
              proposal_ids = Decidim::Coauthorship.where(
                coauthorable_type: "Decidim::Proposals::Proposal",
                author: model
              ).select(:coauthorable_id)

              Decidim::Proposals::Proposal.where(id: proposal_ids).accepted.count
            }
          end

          Decidim::Badges.register_manifest(:proposal_votes) do |badge|
            badge.reset = lambda { |user|
              Decidim::Proposals::ProposalVote.where(author: user).select(:decidim_proposal_id).distinct.count
            }
          end

        end
      end

      initializer "decidim_badges.register_badges.meetings", after: "decidim_badges.register_badges" do
        if Decidim.module_installed?(:meetings)
          Decidim::Badges.register_manifest(:meetings_created) do |badge|
            badge.reset = lambda do |user|
              Decidim::Comments::Comment.where(author: user).distinct.count(:decidim_root_commentable_id)
            end
          end

          Decidim::Badges.register_manifest(:attended_meetings) do |badge|
            badge.reset = lambda do |user|
              Decidim::Meetings::Registration.where(user:).count
            end
          end
        end
      end

      initializer "decidim_badges.register_badges.comments", after: "decidim_badges.register_badges" do
        if Decidim.module_installed?(:comments)
          Decidim::Badges.register_manifest(:comments_created) do |badge|
            badge.reset = lambda do |user|
              debates = Decidim::Comments::Comment.where(
                author: user,
                decidim_root_commentable_type: "Decidim::Debates::Debate"
              )
              debates.pluck(:decidim_root_commentable_id).uniq.count
            end
          end
        end
      end

      initializer "decidim_badges.register_badges.debates", after: "decidim_badges.register_badges" do
        if Decidim.module_installed?(:debates)
          Decidim::Badges.register_manifest(:commented_debates) do |badge|
            badge.reset = lambda do |user|
              debates = Decidim::Comments::Comment.where(
                author: user,
                decidim_root_commentable_type: "Decidim::Debates::Debate"
              )
              debates.pluck(:decidim_root_commentable_id).uniq.count
            end
          end
        end
      end

      initializer "decidim_badges.register_badges.initiatives", after: "decidim_badges.register_badges" do
        if Decidim.module_installed?(:initiatives)

          Decidim::Badges.register_manifest(:initiatives) do |badge|
            badge.reset = lambda { |model|
              Decidim::Initiative.where(
                author: model
              ).published.count
            }
          end
        end
      end
    end
  end
end
