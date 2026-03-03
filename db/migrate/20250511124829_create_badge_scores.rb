# frozen_string_literal: true

class CreateBadgeScores < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_badges_badge_scores do |t|
      t.belongs_to :decidim_user, index: true, foreign_key: true
      t.belongs_to :decidim_badges_badge, index: true, foreign_key: true

      t.integer :value, default: 0, null: false
    end
  end
end
