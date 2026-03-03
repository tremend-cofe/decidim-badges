# frozen_string_literal: true

module Decidim
  module Badges
    module Admin
      class CreateBadge < Decidim::Commands::CreateResource
        fetch_form_attributes :name, :organization, :earning_methods, :description, :levels,
                              :participatory_space_type, :participatory_space_id, :decidim_component_id, :manifest_name
        fetch_file_attributes :file

        def resource_class = Decidim::Badges::Badge
      end
    end
  end
end
