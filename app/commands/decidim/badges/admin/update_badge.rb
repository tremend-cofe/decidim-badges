# frozen_string_literal: true

module Decidim
  module Badges
    module Admin
      class UpdateBadge < Decidim::Commands::UpdateResource
        fetch_form_attributes :name, :organization, :earning_methods, :description, :levels,
                              :participatory_space_type, :participatory_space_id, :decidim_component_id
        fetch_file_attributes :file

        def run_after_hooks
          Decidim::Badges::PublishBadgeJob.perform_later(resource.id)
        end
      end
    end
  end
end
