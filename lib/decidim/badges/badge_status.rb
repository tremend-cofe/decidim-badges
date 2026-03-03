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
        @badge.level_of(score)
      end

      # Public: Returns the score remaining to get to the next level.
      #
      # Returns an Integer with the remaining score.
      def next_level_in
        return nil if last_level?

        threshold = @badge.levels[level.to_s]

        return nil if threshold.blank?

        threshold.to_i - score
      end

      # Public: Returns the score of a user on the badge.
      #
      # Returns an Integer with the score.
      def score
        @score ||= Decidim::Badges::BadgeScore.where(user:, badge:).first_or_initialize(value: 0).value
      end

      def level_up
        return 1.0 if last_level?

        score.to_f / (score + next_level_in.to_f)
      end

      def last_level?
        level >= @badge.levels.count
      end
    end
  end
end
