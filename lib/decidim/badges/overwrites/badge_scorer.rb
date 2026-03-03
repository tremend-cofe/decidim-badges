# frozen_string_literal: true

module Decidim
  module Badges
    module Overwrites
      module BadgeScorer
        def increment(*) = deprecate("increment")

        def decrement(*) = deprecate("decrement")

        def set(*) = deprecate("set")

        def send_notification(*) = deprecate("send_notification")

        def publish_event(*) = deprecate("publish_event")

        def deprecate(method)
          Rails.logger.fatal("Decidim::Gamification::BadgeScorer.#{method} is disabled by the Badge System")
          nil
        end
      end
    end
  end
end
