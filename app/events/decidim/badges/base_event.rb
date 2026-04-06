# frozen_string_literal: true

module Decidim
  module Badges
    class BaseEvent < Decidim::Events::SimpleEvent
      i18n_attributes :badge_name, :current_level

      delegate :url_helpers, to: "Decidim::Core::Engine.routes"

      alias user resource

      def resource_path
        url_helpers.profile_badges_path(nickname: resource.nickname)
      end

      def resource_url
        url_helpers.profile_badges_url(
          nickname: resource.nickname,
          host: resource.organization.host
        )
      end

      private

      def current_level
        extra["current_level"]
      end

      def badge_name
        translated_attribute(badge.name)
      end

      def badge
        @badge ||= Decidim::Badges::Badge.find(extra["badge"])
      end
    end
  end
end
