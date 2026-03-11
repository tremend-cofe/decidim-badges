# frozen_string_literal: true

module Decidim
  module Badges
    module Overwrites
      module NotifyProposalAnswer
        def increment_score
          proposal.coauthorships.find_each do |coauthorship|
            ActiveSupport::Notifications.publish("decidim.proposals.proposal_state_changed", { resource: proposal, creator: coauthorship.author })
          end
        end
      end
    end
  end
end
