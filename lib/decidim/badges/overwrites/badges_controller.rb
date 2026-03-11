# frozen_string_literal: true

module Decidim
  module Badges
    module Overwrites
      module BadgesController
        def index
          @badges = Decidim::Badges::Badge.where(organization: current_organization).published
        end
      end
    end
  end
end
