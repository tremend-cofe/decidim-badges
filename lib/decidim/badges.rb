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
    autoload :BadgeStatus, "decidim/badges/badge_status"

    module Overwrites
      autoload :BadgesController, "decidim/badges/overwrites/badges_controller"
      autoload :BadgeCell, "decidim/badges/overwrites/badge_cell"
      autoload :BadgesCell, "decidim/badges/overwrites/badges_cell"
    end

    # Semi-private: The BadgeRegistry to register manifests of badges to.
    def self.registry
      @badge_registry ||= Decidim::Badges::BadgeRegistry.new
    end

    # Public: Returns all available badges.
    #
    # Returns an Array<BadgeManifest>
    def self.manifests
      registry.all
    end

    # Public: Finds a BadgeManifest given a name.
    #
    # Returns a BadgeManifest if found, nil otherwise.
    def self.find_manifest(name)
      registry.find(name)
    end

    # Public: Registers a new BadgeManifest.
    #
    # Example:
    #
    #     Decidim::Badges.register_badge(:foo) do |badge|
    #     end
    #
    # Returns nothing if registered successfully, raises an exception
    # otherwise.
    def self.register_manifest(name, &)
      registry.register(name, &)
    end
  end
end
