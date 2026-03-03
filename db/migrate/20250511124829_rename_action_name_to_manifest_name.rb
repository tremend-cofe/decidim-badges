# frozen_string_literal: true

class RenameActionNameToManifestName < ActiveRecord::Migration[5.2]
  def change
    rename_column :decidim_badges_badges, :action_name, :manifest_name
  end
end
