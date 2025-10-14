# frozen_string_literal: true

module Decidim
  module Badges
    module Overwrites
      module VoteProposal

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal vote.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if @proposal.maximum_votes_reached? && !@proposal.can_accumulate_votes_beyond_threshold

          build_proposal_vote
          return broadcast(:invalid) unless vote.valid?

          ActiveRecord::Base.transaction do
            @proposal.with_lock do
              vote.save!
              update_temporary_votes
            end
          end

          Decidim::Gamification.increment_score(@current_user, :proposal_votes)

          ActiveSupport::Notifications.publish("decidim.proposals.vote_proposal:after", **event_arguments)

          broadcast(:ok, vote)
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
