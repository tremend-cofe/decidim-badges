# frozen_string_literal: true

module Decidim
  module Badges
    module Overwrites
      module DeleteFollow
        def call
          return broadcast(:invalid) if form.invalid?

          with_events do
            delete_follow!
          end

          broadcast(:ok)
        end

        def event_arguments
          {
            resource: form.follow.followable,
            extra: {
              event_author: current_user
            }
          }
        end
      end
    end
  end
end
