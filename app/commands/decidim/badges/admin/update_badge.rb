# frozen_string_literal: true

module Decidim
  module Badges
    module Admin
      class UpdateBadge < Decidim::Commands::UpdateResource
        fetch_form_attributes :name, :organization, :earning_methods, :description, :levels,
                              :participatory_space_type, :participatory_space_id, :component
        fetch_file_attributes :file
      end
    end
  end
end