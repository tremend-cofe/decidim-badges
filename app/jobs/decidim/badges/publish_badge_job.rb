# frozen_string_literal: true

module Decidim
  module Badges
    class PublishBadgeJob < ApplicationJob
      def perform(id)
        badge = Decidim::Badges::Badge.find(id)
        Decidim::User.find_each do |user|
          Decidim::Badges.compute_score(badge.manifest_name, user:)
          Decidim::Badges.compute_score(badge.manifest_name, user:, participatory_space: badge.participatory_space)
          Decidim::Badges.compute_score(badge.manifest_name, user:, participatory_space: badge.participatory_space, component: badge.component)
        end
      end
    end
  end
end
