# frozen_string_literal: true

require "rails"
require "decidim/core"
require "deface"

module Decidim
  module Badges
    # This is the engine that runs on the public interface of badges.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Badges

      initializer "decidim_badges.add_cells_view_paths", before: "decidim_core.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Badges::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Badges::Engine.root}/app/views")
      end

      initializer "decidim_badges.deface" do
        Rails.application.configure do
          config.deface.enabled = Decidim::Env.new("DEFACE_ENABLED", true).present?
        end
      end

      initializer "decidim_badges.add_overrides" do
        Rails.application.config.to_prepare do
          Decidim::Gamification.singleton_class.send(:prepend, Decidim::Badges::Overwrites::Gamification)
          Decidim::Gamification::BadgeScorer.prepend(Decidim::Badges::Overwrites::BadgeScorer)
          Decidim::Gamification::BadgeStatus.prepend(Decidim::Badges::Overwrites::BadgeStatus)

          Decidim::BadgeCell.prepend(Decidim::Badges::Overwrites::BadgeCell)
          Decidim::BadgesCell.prepend(Decidim::Badges::Overwrites::BadgesCell)
          Decidim::Gamification::BadgesController.prepend(Decidim::Badges::Overwrites::BadgesController)
          Decidim::Gamification::BadgesController.helper(Decidim::ResourceHelper)

          Decidim::Comments::DeleteComment.prepend(Decidim::Badges::Overwrites::DeleteComment) if Decidim.module_installed?(:comments)

          if Decidim.module_installed?(:proposals)
            Decidim::Proposals::VoteProposal.prepend(Decidim::Badges::Overwrites::VoteProposal)
            Decidim::Proposals::UnvoteProposal.prepend(Decidim::Badges::Overwrites::UnvoteProposal)
            Decidim::Proposals::PublishProposal.prepend(Decidim::Badges::Overwrites::PublishProposal)
            Decidim::Proposals::WithdrawProposal.prepend(Decidim::Badges::Overwrites::WithdrawProposal)
            Decidim::Proposals::Admin::NotifyProposalAnswer.prepend(Decidim::Badges::Overwrites::NotifyProposalAnswer)
          end

          Decidim::Meetings::WithdrawMeeting.prepend(Decidim::Badges::Overwrites::WithdrawMeeting) if Decidim.module_installed?(:meetings)

          Decidim::CreateFollow.prepend Decidim::Badges::Overwrites::CreateFollow
          Decidim::DeleteFollow.prepend Decidim::Badges::Overwrites::DeleteFollow
        end
      end

      initializer "decidim_badges.register_badges.comment_created" do
        if Decidim.module_installed?(:comments)
          Decidim::Badges.register_manifest(:comment_created) do |badge|
            badge.reset = lambda { |author, participatory_space, component|
              conditions = { author: }
              conditions.merge!(participatory_space:) if participatory_space.present?

              comments = Decidim::Comments::Comment.not_deleted.not_hidden.where(**conditions)

              if component.present?
                root_commentables = component.manifest.data_portable_entities.collect do |entity|
                  component_association = entity.constantize.reflect_on_all_associations.select { |a| a.class_name == "Decidim::Component" }.first
                  if component_association.present?
                    entity.constantize.where({ component_association.name => component }).all
                  else
                    []
                  end
                end

                root_commentables = nil if root_commentables.blank?

                comments = comments.where(root_commentable: root_commentables)
              end

              comments.distinct.count(:decidim_root_commentable_id)
            }
          end

          ActiveSupport::Notifications.subscribe("decidim.comments.create_comment:after") do |_event_name, data|
            user = data[:resource].author

            Decidim::Badges.compute_score(:comment_created, user:)
            Decidim::Badges.compute_score(:comment_created, user:, participatory_space: data[:resource].participatory_space)
            Decidim::Badges.compute_score(:comment_created, user:, participatory_space: data[:resource].participatory_space, component: data[:resource].component)
          end

          ActiveSupport::Notifications.subscribe("decidim.comments.delete_comment:after") do |_event_name, data|
            user = data[:resource].author

            Decidim::Badges.compute_score(:comment_created, user:)
            Decidim::Badges.compute_score(:comment_created, user:, participatory_space: data[:resource].participatory_space)
            Decidim::Badges.compute_score(:comment_created, user:, participatory_space: data[:resource].participatory_space, component: data[:resource].component)
          end
        end
      end

      initializer "decidim_badges.register_badges.user_follow" do
        Decidim::Badges.register_manifest(:followers) do |badge|
          badge.reset = ->(user, _participatory_space, _component) { user.followers_count }
        end

        ActiveSupport::Notifications.subscribe("decidim.create_follow:after") do |_event_name, data|
          Decidim::Badges.compute_score(:followers, user: data[:resource]) if data[:resource].is_a?(Decidim::User)
        end

        ActiveSupport::Notifications.subscribe("decidim.delete_follow:after") do |_event_name, data|
          Decidim::Badges.compute_score(:followers, user: data[:resource]) if data[:resource].is_a?(Decidim::User)
        end
      end

      initializer "decidim_badges.register_badges.proposal_created" do
        if Decidim.module_installed?(:proposals)
          Decidim::Badges.register_manifest(:proposal_created) do |badge|
            badge.reset = lambda { |author, participatory_space, component|
              conditions = { decidim_coauthorships: { author: } }
              conditions.merge!(component: component) if component.present?
              conditions.merge!(component: { participatory_space: }) if participatory_space.present?

              Decidim::Proposals::Proposal
                .joins(:coauthorships, :component)
                .published
                .not_withdrawn
                .not_hidden
                .where(**conditions)
                .distinct
                .count
            }
          end

          ActiveSupport::Notifications.subscribe("decidim.proposals.publish_proposal") do |_event_name, data|
            Decidim::Badges.compute_score(:proposal_created, user: data[:creator])
            Decidim::Badges.compute_score(:proposal_created, user: data[:creator], participatory_space: data[:resource].participatory_space)
            Decidim::Badges.compute_score(:proposal_created, user: data[:creator], participatory_space: data[:resource].participatory_space, component: data[:resource].component)
          end

          ActiveSupport::Notifications.subscribe("decidim.proposals.withdraw_proposal") do |_event_name, data|
            Decidim::Badges.compute_score(:proposal_created, user: data[:creator])
            Decidim::Badges.compute_score(:proposal_created, user: data[:creator], participatory_space: data[:resource].participatory_space)
            Decidim::Badges.compute_score(:proposal_created, user: data[:creator], participatory_space: data[:resource].participatory_space, component: data[:resource].component)
          end
        end
      end

      initializer "decidim_badges.register_badges.proposal_accepted" do
        if Decidim.module_installed?(:proposals)
          Decidim::Badges.register_manifest(:proposal_accepted) do |badge|
            badge.reset = lambda { |author, participatory_space, component|
              conditions = { decidim_coauthorships: { author: } }
              conditions.merge!(component: component) if component.present?
              conditions.merge!(component: { participatory_space: }) if participatory_space.present?

              Decidim::Proposals::Proposal
                .joins(:coauthorships, :component)
                .published
                .accepted
                .not_withdrawn
                .not_hidden
                .where(**conditions)
                .distinct
                .count
            }
          end

          ActiveSupport::Notifications.subscribe("decidim.proposals.proposal_state_changed") do |_event_name, data|
            Decidim::Badges.compute_score(:proposal_accepted, user: data[:creator])
            Decidim::Badges.compute_score(:proposal_accepted, user: data[:creator], participatory_space: data[:resource].participatory_space)
            Decidim::Badges.compute_score(:proposal_accepted, user: data[:creator], participatory_space: data[:resource].participatory_space, component: data[:resource].component)
          end
        end
      end

      initializer "decidim_badges.register_badges.proposal_voted" do
        if Decidim.module_installed?(:proposals)
          Decidim::Badges.register_manifest(:proposal_voted) do |badge|
            badge.reset = lambda { |author, participatory_space, component|
              conditions = { votes: { author: } }
              conditions.merge!(component: component) if component.present?
              conditions.merge!(component: { participatory_space: }) if participatory_space.present?

              Decidim::Proposals::Proposal
                .joins(:votes, :component)
                .where(**conditions)
                .published
                .not_withdrawn
                .not_hidden
                .distinct
                .count
            }
          end

          ActiveSupport::Notifications.subscribe("decidim.proposals.proposal_voted") do |_event_name, data|
            Decidim::Badges.compute_score(:proposal_voted, user: data[:creator])
            Decidim::Badges.compute_score(:proposal_voted, user: data[:creator], participatory_space: data[:resource].participatory_space)
            Decidim::Badges.compute_score(:proposal_voted, user: data[:creator], participatory_space: data[:resource].participatory_space, component: data[:resource].component)
          end
        end
      end

      initializer "decidim_badges.register_badges.meeting_created" do
        if Decidim.module_installed?(:meetings)
          Decidim::Badges.register_manifest(:meeting_created) do |badge|
            badge.reset = lambda { |author, participatory_space, component|
              conditions = { author: }
              conditions.merge!(component: component) if component.present?
              conditions.merge!(decidim_components: { participatory_space: }) if participatory_space.present?

              Decidim::Meetings::Meeting
                .joins(:component)
                .where(**conditions)
                .published
                .not_hidden
                .not_withdrawn
                .distinct
                .count
            }
          end

          ActiveSupport::Notifications.subscribe("decidim.meetings.create_meeting:after") do |_event_name, data|
            user = data[:resource].author
            Decidim::Badges.compute_score(:meeting_created, user:)
            Decidim::Badges.compute_score(:meeting_created, user:, participatory_space: data[:resource].participatory_space)
            Decidim::Badges.compute_score(:meeting_created, user:, participatory_space: data[:resource].participatory_space, component: data[:resource].component)
          end
          ActiveSupport::Notifications.subscribe("decidim.meetings.withdraw_meeting:after") do |_event_name, data|
            user = data[:resource].author
            Decidim::Badges.compute_score(:meeting_created, user:)
            Decidim::Badges.compute_score(:meeting_created, user:, participatory_space: data[:resource].participatory_space)
            Decidim::Badges.compute_score(:meeting_created, user:, participatory_space: data[:resource].participatory_space, component: data[:resource].component)
          end
        end
      end
    end
  end
end
