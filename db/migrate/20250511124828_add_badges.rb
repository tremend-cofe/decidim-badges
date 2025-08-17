# frozen_string_literal: true

class AddBadges < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_badges_badges do |t|
      t.belongs_to :decidim_organization, index: true, foreign_key: true

      t.jsonb :name, null: false, default: {}
      t.jsonb :description, null: false, default: {}
      t.jsonb :earning_methods, null: false, default: {}
      t.datetime :published_at, index: true
      t.integer :weight
      t.jsonb :levels, default: {}

      t.belongs_to :participatory_space, index: { name: :badge_space_condition }, polymorphic: true, optional: true
      t.belongs_to :decidim_component, index: true, foreign_key: true, optional: true
      t.string :action_name
    end
  end
end
