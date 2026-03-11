# frozen_string_literal: true

require "decidim/badges/organization/admin"
require "decidim/badges/engine"
require "decidim/badges/organization/admin_engine"

module Decidim
  # This namespace holds the logic of the `Badges` component. This component
  # allows users to create badges in a participatory space.
  module Badges
    autoload :BadgeManifest, "decidim/badges/badge_manifest"
    autoload :BadgeRegistry, "decidim/badges/badge_registry"

    module Overwrites
      autoload :BadgesController, "decidim/badges/overwrites/badges_controller"
    end

    def self.registry
      @badge_registry ||= Decidim::Badges::BadgeRegistry.new
    end
  end
end
