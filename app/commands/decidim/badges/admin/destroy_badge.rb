# frozen_string_literal: true

module Decidim
  module Badges
    module Admin
      class DestroyBadge < Decidim::Commands::DestroyResource
        private

        def extra_params
          {
            resource: {
              title: resource.name
            }
          }
        end
      end
    end
  end
end
