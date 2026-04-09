# frozen_string_literal: true

module Decidim
  module Badges
    class BadgeManifest
      include Decidim::AttributeObject::Model
      include ActiveModel::Validations

      # The name of the badge.
      attribute :name, String

      # whether the badge should add restriction fields
      attribute :has_restrictions, Boolean, default: true

      attribute :action_description, String

      # (Optional) you can set a lambda in order to be able to reset the score of a
      # badge if the progress gets lost somehow. The lambda receives a user as an
      # argument.
      #
      # It might not be possible sometimes, so it is fine to leave it empty.
      attribute :reset, Proc
    end
  end
end
