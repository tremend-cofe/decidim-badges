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

      # t.string :gamifiable_type
      # t.integer :gamifiable_id

    end
  end
end
