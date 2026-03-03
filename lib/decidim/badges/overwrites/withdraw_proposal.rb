# frozen_string_literal: true

module Decidim
  module Badges
    module Overwrites
      module WithdrawProposal
        def call
          return broadcast(:has_votes) if @proposal.votes.any?

          transaction do
            @proposal.withdraw!
            reject_emendations_if_any
            decrement_scores
          end

          broadcast(:ok, @proposal)
        end

        def decrement_scores
          @proposal.coauthorships.find_each do |coauthorship|
            ActiveSupport::Notifications.publish("decidim.proposals.withdraw_proposal", { resource: @proposal, creator: coauthorship.author })
          end
        end
      end
    end
  end
end
