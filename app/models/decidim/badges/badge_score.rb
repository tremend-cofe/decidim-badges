# frozen_string_literal: true

module Decidim
  module Badges
    class BadgeScore < ApplicationRecord
      belongs_to :user, class_name: "Decidim::UserBaseEntity", foreign_key: :decidim_user_id
      belongs_to :badge, class_name: "Decidim::Badges::Badge", foreign_key: :decidim_badges_badge_id

      validates :level, numericality: { greater_than_or_equal_to: 0 }
      validates :value, numericality: { greater_than_or_equal_to: 0 }
    end
  end
end
