# frozen_string_literal: true

module Decidim
  module Badges
    module Overwrites
      module BadgesController
        def index
          raise ActionController::RoutingError, "Not Found" unless current_organization.badges_enabled?

          @badges = Decidim::Badges::Badge.where(organization: current_organization).published
        end
      end
    end
  end
end
