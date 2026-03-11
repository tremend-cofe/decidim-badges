# frozen_string_literal: true
#
module Decidim
  module Badges
    class BadgeRegistry
      # Public: Initializes the badge registry.
      def initialize
        @manifests = {}
      end

      # Public: Returns all the registered badges.
      #
      # Returns Array<Badge>.
      def all
        @manifests.values
      end

      # Public: Finds a badge given its name.
      #
      # name - The name of the badge to find.
      #
      # Returns a Badge if found or nil otherwise.
      def find(name)
        @manifests[name.to_s]
      end

      # Public: Registers a new badge.
      #
      # name   - The name of the badge to register.
      # &block - A block that gets the new badge as argument.
      #
      # Example:
      #     register(:fake){ |badge| badge.levels = [1, 3, 10] }
      #
      # Returns a Badge when registered successfully, raises an exception
      # otherwise.
      def register(name, &)
        name = name.to_s

        badge = Decidim::Badges::BadgeManifest.new(name:).tap do |object|
          object.instance_eval(&)
        end

        badge.validate!

        @manifests[name] = badge
      end

      # Public: Unregisters a previously registered badge.
      #
      # name - The name of the badge to unregister.
      #
      # Returns the deleted Badge if found, nil otherwise.
      def unregister(name)
        @manifests.delete(name.to_s)
      end
    end
  end
end
