# frozen_string_literal: true

module Decidim
  module Badges
    module Overwrites
      module Gamification
        def status_for(*) = deprecate("status_for")

        def increment_score(*) = deprecate("increment_score")

        def decrement_score(*) = deprecate("decrement_score")

        def set_score(*) = deprecate("set_score")

        def deprecate(method)
          Rails.logger.fatal("Decidim::Gamification.#{method} is disabled by the Badge System")
          nil
        end
      end
    end
  end
end
