# frozen_string_literal: true

module Decidim
  module Badges
    module Overwrites
      module PublishProposal
        def increment_scores
          @proposal.coauthorships.find_each do |coauthorship|
            ActiveSupport::Notifications.publish("decidim.proposals.publish_proposal", { resource: @proposal, creator: coauthorship.author })
          end
        end
      end
    end
  end
end
