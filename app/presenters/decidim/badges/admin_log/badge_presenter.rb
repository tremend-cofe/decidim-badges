# frozen_string_literal: true

module Decidim
  module Badges
    module AdminLog
      class BadgePresenter < Decidim::Log::BasePresenter
        private

        def action_string
          case action
          when "create", "delete", "update"
            "decidim.badges.admin_log.badge.#{action}"
          else
            super
          end
        end
      end
    end
  end
end
