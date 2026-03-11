
module Decidim
  module Badges
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin
          return permission_action unless [:badge, :badges].include?(permission_action.subject)

          allow!
          permission_action
        end
      end
    end
  end
end
