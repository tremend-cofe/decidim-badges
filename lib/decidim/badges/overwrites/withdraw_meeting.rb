# frozen_string_literal: true

module Decidim
  module Badges
    module Overwrites
      module WithdrawMeeting
        def call
          return broadcast(:invalid) unless @meeting.authored_by?(@current_user)

          with_events do
            change_meeting_state_to_withdrawn
          end

          broadcast(:ok, @meeting)
        end

        def event_arguments
          {
            resource: @meeting,
            extra: {
              event_author: @current_user
            }
          }
        end
      end
    end
  end
end
