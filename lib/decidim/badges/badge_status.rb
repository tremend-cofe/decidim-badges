# frozen_string_literal: true

module Decidim
  module Badges
    class BadgeStatus
      attr_reader :badge, :user

      delegate :max_level, to: :badge

      def initialize(user, badge)
        @user = user
        @badge = badge
      end

      # Public: Returns the current level of a user in a badge.
      #
      # Returns an Integer with the level.
      def level
        badge_score&.level || 0
      end

      # Public: Returns the score remaining to get to the next level.
      #
      # Returns an Integer with the remaining score.
      def next_level_in
        return nil if level >= @badge.levels.count

        @badge.levels[level] - score
      end

      # Public: Returns the score of a user on the badge.
      #
      # Returns an Integer with the score.
      def score
        badge_score&.value || 0
      end

      private

      def badge_score
        @badge_score ||= Decidim::Badges::BadgeScore.where(user:, badge:).first_or_initialize
      end
    end
  end
end
