# frozen_string_literal: true

module Decidim
  module Badges
    module Organization
      # This is the engine that runs on the public interface of `Badges`.
      class AdminEngine < ::Rails::Engine
        isolate_namespace Decidim::Badges::Organization::Admin

        paths["db/migrate"] = nil
        paths["lib/tasks"] = nil

        routes do
          resource :badge_list, only: [:edit, :update], controller: :badge_list do
            resources :badges, only: [:edit, :update, :destroy, :create], controller: :badge
          end

          root to: "badge_list#edit"
        end

        initializer "decidim_admin_badges.register_admin" do
          Decidim::Admin::Engine.routes do
            mount Decidim::Badges::Organization::AdminEngine => "/settings/badges", :as => :decidim_admin_badges
          end
        end

        initializer "decidim_admin_badges.add_menu" do
          Decidim.menu :admin_settings_menu do |menu|

            menu.add_item :badges,
                          I18n.t("menu.badges", scope: "decidim.badges.admin"),
                          decidim_admin_badges.root_path,
                          position: 1.8,
                          icon_name: "award-line",
                          if: current_organization.badges_enabled && allowed_to?(:update, :organization, organization: current_organization)
          end
        end

        def load_seed
          nil
        end
      end
    end
  end
end
