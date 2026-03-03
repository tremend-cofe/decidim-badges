# frozen_string_literal: true

module Decidim
  module Badges
    module Overwrites
      module CreateFollow
        def call
          return broadcast(:invalid) if form.invalid?

          with_events do
            create_follow!
          end

          broadcast(:ok, follow)
        end

        def event_arguments
          {
            resource: form.followable,
            extra: {
              event_author: current_user
            }
          }
        end
      end
    end
  end
end
