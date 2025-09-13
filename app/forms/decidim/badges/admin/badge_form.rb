
module Decidim
  module Badges
    module Admin
      class BadgeForm < Decidim::Form
        include TranslatableAttributes

        mimic :badge

        attribute :file
        attribute :participatory_space
        attribute :participatory_space_type
        attribute :participatory_space_id
        attribute :levels, Hash
        attribute :decidim_component_id, Integer
        attribute :manifest_name, String

        translatable_attribute :name, String
        translatable_attribute :description, String
        translatable_attribute :earning_methods, String
        validates :file, presence: true, unless: :persisted?

        validates :name, :description, :earning_methods, translatable_presence: true

        def map_model(model)
          self.participatory_space = [model.participatory_space_type, model.participatory_space_id].join("#")
        end

        def self.from_params(params, additional_params = {})
          participatory_space = params.dig(:badge, :participatory_space)

          if participatory_space.present?
            additional_params.merge!(
              participatory_space_type: participatory_space.split("#").first,
              participatory_space_id: participatory_space.split("#").last
            )
          end

          super
        end
      end
    end
  end
end