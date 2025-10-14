# frozen_string_literal: true

module Decidim
  module Badges
    module Overwrites
      module UnvoteProposal
        def call
          ActiveRecord::Base.transaction do
            ProposalVote.where(
              author: @current_user,
              proposal: @proposal
            ).destroy_all

            update_temporary_votes
          end

          Decidim::Gamification.decrement_score(@current_user, :proposal_votes)

          ActiveSupport::Notifications.publish("decidim.proposals.unvote_proposal:after", **event_arguments)

          broadcast(:ok, @proposal)
        end

        def event_arguments
          {
            resource: @proposal,
            user: @current_user
          }
        end
      end
    end
  end
end
