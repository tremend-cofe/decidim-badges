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

      initializer "decidim_badges.add_badges" do
        Rails.application.config.to_prepare do
          Decidim::Gamification::BadgesController.prepend(Decidim::Badges::Overwrites::BadgesController)
          Decidim::Gamification::BadgesController.helper(Decidim::ResourceHelper)

          if Decidim.module_installed?(:proposals)
            Decidim::Proposals::VoteProposal.prepend(Decidim::Badges::Overwrites::VoteProposal)
            Decidim::Proposals::UnvoteProposal.prepend(Decidim::Badges::Overwrites::UnvoteProposal)
          end

          if Decidim.module_installed?(:meetings)
            Decidim::Meetings::JoinMeeting.prepend(Decidim::Badges::Overwrites::JoinMeeting)
            Decidim::Meetings::LeaveMeeting.prepend(Decidim::Badges::Overwrites::LeaveMeeting)
          end
        end
      end

      initializer "decidim_badges.register_badges" do
        Decidim::Badges.register_manifest(:followers) do |badge|
          badge.reset = ->(user, _participatory_space, _component) { user.followers.count }
        end
      end

      initializer "decidim_badges.register_badges.proposals", after: "decidim_badges.register_badges" do
        if Decidim.module_installed?(:proposals)

          Decidim::Badges.register_manifest(:proposals) do |badge|
            badge.reset = lambda { |model, participatory_space, component|
              Decidim::Coauthorship.where(
                coauthorable_type: "Decidim::Proposals::Proposal",
                author: model
              ).count
            }
          end

          Decidim::Badges.register_manifest(:accepted_proposals) do |badge|
            badge.reset = lambda { |model, participatory_space, component|
              proposal_ids = Decidim::Coauthorship.where(
                coauthorable_type: "Decidim::Proposals::Proposal",
                author: model
              ).select(:coauthorable_id)

              Decidim::Proposals::Proposal.where(id: proposal_ids).accepted.count
            }
          end

          Decidim::Badges.register_manifest(:proposal_votes) do |badge|
            badge.reset = lambda { |user, participatory_space, component|
              Decidim::Proposals::ProposalVote.where(author: user).select(:decidim_proposal_id).distinct.count
            }
          end
        end
      end

      initializer "decidim_badges.subscribe_badges.proposals", after: "decidim_badges.register_badges.proposals" do
        if Decidim.module_installed?(:proposals)
          ActiveSupport::Notifications.subscribe("decidim.proposals.create_proposal:after") do |_event_name, data|
            user = data[:resource].creator
            Decidim::Badges.compute_score(:proposals, user:)
            Decidim::Badges.compute_score(:proposals, user:, participatory_space: data[:resource].participatory_space)
            Decidim::Badges.compute_score(:proposals, user:, participatory_space: data[:resource].participatory_space, component: data[:resource].component)
          end

          ActiveSupport::Notifications.subscribe("decidim.events.proposals.proposal_state_changed") do |_event_name, data|
            user = data[:resource].creator
            Decidim::Badges.compute_score(:accepted_proposals, user:)
            Decidim::Badges.compute_score(:accepted_proposals, user:, participatory_space: data[:resource].participatory_space)
            Decidim::Badges.compute_score(:accepted_proposals, user:, participatory_space: data[:resource].participatory_space, component: data[:resource].component)
          end

          ActiveSupport::Notifications.subscribe("decidim.proposals.vote_proposal:after") do |_event_name, data|
            Decidim::Badges.compute_score(:proposal_votes, user: data[:user])
            Decidim::Badges.compute_score(:proposal_votes, user: data[:user], participatory_space: data[:resource].participatory_space)
            Decidim::Badges.compute_score(:proposal_votes, user: data[:user], participatory_space: data[:resource].participatory_space, component: data[:resource].component)
          end

          ActiveSupport::Notifications.subscribe("decidim.proposals.unvote_proposal:after") do |_event_name, data|
            Decidim::Badges.compute_score(:proposal_votes, user: data[:user])
            Decidim::Badges.compute_score(:proposal_votes, user: data[:user], participatory_space: data[:resource].participatory_space)
            Decidim::Badges.compute_score(:proposal_votes, user: data[:user], participatory_space: data[:resource].participatory_space, component: data[:resource].component)
          end
        end
      end

      initializer "decidim_badges.register_badges.meetings", after: "decidim_badges.register_badges" do
        if Decidim.module_installed?(:meetings)
          Decidim::Badges.register_manifest(:meetings_created) do |badge|
            badge.reset = lambda do |author, participatory_space, component|
              Decidim::Meetings::Meeting.published.not_withdrawn.not_hidden.where(author:).count
            end
          end

          Decidim::Badges.register_manifest(:attended_meetings) do |badge|
            badge.reset = lambda do |user, participatory_space, component|
              Decidim::Meetings::Registration.where(user:).count
            end
          end
        end
      end

      initializer "decidim_badges.subscribe_badges.meetings", after: "decidim_badges.register_badges.meetings" do
        if Decidim.module_installed?(:meetings)
          ActiveSupport::Notifications.subscribe("decidim.meetings.create_meeting:after") do |_event_name, data|
            user = data[:resource].author
            Decidim::Badges.compute_score(:meetings_created, user:)
            Decidim::Badges.compute_score(:meetings_created, user:, participatory_space: data[:resource].participatory_space)
            Decidim::Badges.compute_score(:meetings_created, user:, participatory_space: data[:resource].participatory_space, component: data[:resource].component)
          end

          ActiveSupport::Notifications.subscribe("decidim.meetings.attend_meeting:after") do |_event_name, data|
            user = data[:user].first
            Decidim::Badges.compute_score(:attended_meetings, user:)
            Decidim::Badges.compute_score(:attended_meetings, user:, participatory_space: data[:resource].participatory_space)
            Decidim::Badges.compute_score(:attended_meetings, user:, participatory_space: data[:resource].participatory_space, component: data[:resource].component)
          end

          ActiveSupport::Notifications.subscribe("decidim.meetings.leave_meeting:after") do |_event_name, data|
            user = data[:user].first
            Decidim::Badges.compute_score(:attended_meetings, user:)
            Decidim::Badges.compute_score(:attended_meetings, user:, participatory_space: data[:resource].participatory_space)
            Decidim::Badges.compute_score(:attended_meetings, user:, participatory_space: data[:resource].participatory_space, component: data[:resource].component)
          end
        end
      end

      initializer "decidim_badges.register_badges.comments", after: "decidim_badges.register_badges" do
        if Decidim.module_installed?(:comments)
          Decidim::Badges.register_manifest(:debates_created) do |badge|
            badge.reset = lambda do |author, participatory_space, component|
              Decidim::Debates::Debate.not_hidden.where(author:).count
            end
          end

          Decidim::Badges.register_manifest(:comments_created) do |badge|
            badge.reset = lambda do |user, participatory_space, component|
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
            badge.reset = lambda do |user, participatory_space, component|
              debates = Decidim::Comments::Comment.where(
                author: user,
                decidim_root_commentable_type: "Decidim::Debates::Debate"
              )
              debates.pluck(:decidim_root_commentable_id).uniq.count
            end
          end
        end
      end

      initializer "decidim_badges.subscribe_badges.debates", after: "decidim_badges.register_badges.debates" do
        if Decidim.module_installed?(:debates)
          ActiveSupport::Notifications.subscribe("decidim.debates.create_debate:after") do |_event_name, data|
            user = data[:resource].author
            Decidim::Badges.compute_score(:debates_created, user:)
            Decidim::Badges.compute_score(:debates_created, user:, participatory_space: data[:resource].participatory_space)
            Decidim::Badges.compute_score(:debates_created, user:, participatory_space: data[:resource].participatory_space, component: data[:resource].component)
          end
        end
      end

      initializer "decidim_badges.register_badges.initiatives", after: "decidim_badges.register_badges" do
        if Decidim.module_installed?(:initiatives)

          Decidim::Badges.register_manifest(:initiatives) do |badge|
            badge.reset = lambda { |model, participatory_space, component|
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
