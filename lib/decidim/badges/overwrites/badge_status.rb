# frozen_string_literal: true

module Decidim
  module Badges
    module Overwrites
      module BadgeStatus
        def level = deprecate("level")

        def next_level_in = deprecate("next_level_in")

        def score = deprecate("score")

        def deprecate(method)
          Rails.logger.fatal("Decidim::Gamification::BadgeStatus.#{method} is disabled by the Badge System")
          nil
        end
      end
    end
  end
end
