# frozen_string_literal: true

class AddBadges < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_badges_badges do |t|
      t.jsonb :name, null: false, default: {}
      t.jsonb :description, null: false, default: {}
      t.jsonb :earning_methods, null: false, default: {}
      t.string :gamifiable_type
      t.integer :gamifiable_id
      t.string :manifest_name, null: false, index: true
      t.datetime :published_at, index: true
      t.integer :weight
      t.jsonb :levels, default: {}
    end
  end
end
