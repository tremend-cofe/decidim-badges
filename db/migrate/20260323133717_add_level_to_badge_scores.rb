# frozen_string_literal: true

class AddLevelToBadgeScores < ActiveRecord::Migration[7.2]
  def change
    add_column :decidim_badges_badge_scores, :level, :integer, null: false, default: 0
  end
end
