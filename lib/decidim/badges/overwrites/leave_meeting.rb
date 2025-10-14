# frozen_string_literal: true

module Decidim
  module Badges
    module Overwrites
      module LeaveMeeting
        def decrement_score
          Decidim::Gamification.decrement_score(@user, :attended_meetings)

          ActiveSupport::Notifications.publish("decidim.meetings.leave_meeting:after", **event_arguments)
        end

        def event_arguments
          {
            resource: @meeting,
            user: @user
          }
        end
      end
    end
  end
end
