# frozen_string_literal: true

module Decidim
  module Badges
    module Overwrites
      module UnvoteProposal
        def call
          ActiveRecord::Base.transaction do
            Decidim::Proposals::ProposalVote.where(
              author: @current_user,
              proposal: @proposal
            ).destroy_all

            update_temporary_votes
          end

          ActiveSupport::Notifications.publish("decidim.proposals.proposal_voted", { resource: @proposal, creator: @current_user })

          broadcast(:ok, @proposal)
        end
      end
    end
  end
end
