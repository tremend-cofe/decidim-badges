# frozen_string_literal: true

module Decidim
  module Badges
    module Overwrites
      module DeleteComment
        def call
          return broadcast(:invalid) unless comment.authored_by?(current_user)

          with_events do
            delete_comment
          end

          broadcast(:ok)
        end

        def event_arguments
          {
            resource: comment,
            extra: {
              event_author: current_user,
              locale:
            }
          }
        end
      end
    end
  end
end
