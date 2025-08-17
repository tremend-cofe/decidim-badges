
module Decidim
  module Badges
    module Admin
      class BadgeForm < Decidim::Form
        include TranslatableAttributes

        mimic :badge

        attribute :file
        attribute :levels, Hash
        translatable_attribute :name, String
        translatable_attribute :description, String
        translatable_attribute :earning_methods, String
        validates :file, presence: true, unless: :persisted?

        validates :name, :description, :earning_methods, translatable_presence: true
      end
    end
  end
end