# frozen_string_literal: true

module Decidim
  module Badges
    module Admin
      class CreateBadge < Decidim::Commands::CreateResource
        fetch_form_attributes :name, :gamifiable, :earning_methods, :description, :levels
        fetch_file_attributes :file

        def resource_class = Decidim::Badges::Badge
      end
    end
  end
end
