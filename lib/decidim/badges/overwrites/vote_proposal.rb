# frozen_string_literal: true

module Decidim
  module Badges
    module Overwrites
      module VoteProposal
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

          ActiveSupport::Notifications.publish("decidim.proposals.proposal_voted", { resource: @proposal, creator: @current_user })

          broadcast(:ok, vote)
        end
      end
    end
  end
end
