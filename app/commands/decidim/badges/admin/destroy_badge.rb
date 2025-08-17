# frozen_string_literal: true

module Decidim
  module Badges
    module Admin
      class DestroyBadge < Decidim::Command
        # Public: Initializes the command.
        #
        # badge - The badge to destroy
        def initialize(badge)
          @badge = badge
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          destroy_badge
          broadcast(:ok)
        rescue StandardError
          broadcast(:invalid)
        end

        private

        def destroy_badge
          Decidim.traceability.perform_action!("delete", @badge, current_user) do
            @badge.destroy!
          end
        end
      end
    end
  end
end
