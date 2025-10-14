# frozen_string_literal: true

module Decidim
  module Badges
    module Overwrites
      module JoinMeeting
        def increment_score
          Decidim::Gamification.increment_score(current_user, :attended_meetings)
          ActiveSupport::Notifications.publish("decidim.meetings.attend_meeting:after", **event_arguments)
        end

        def event_arguments
          {
            resource: @meeting,
            user: current_user
          }
        end
      end
    end
  end
end
