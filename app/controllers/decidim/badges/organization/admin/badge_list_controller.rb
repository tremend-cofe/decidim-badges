# frozen_string_literal: true

module Decidim
  module Badges
    module Organization
      module Admin

        class BadgeListController < ApplicationController
          layout "decidim/admin/settings"

          add_breadcrumb_item_from_menu :admin_settings_menu

          def edit
            enforce_permission_to_update_resource
          end

          def update
            enforce_permission_to_update_resource

            Decidim::Badges::Admin::ReorderBadges.call(current_organization, params[:ids_order]) do
              on(:ok) do
                head :ok
              end
              on(:invalid) do
                head :bad_request
              end
            end
          end

          helper_method :content_blocks_title, :add_content_block_text,
                        :available_manifests, :active_content_blocks_title,
                        :resource_sort_url, :inactive_content_blocks_title,
                        :inactive_blocks, :active_blocks, :resource_content_block_cell,
                        :content_block_destroy_confirmation_text, :resource_create_url

          private

          def enforce_permission_to_update_resource
            enforce_permission_to :update, :badges, organization: current_organization
          end

          def content_blocks_title = t("edit", scope: "decidim.badges.admin.badge_list")

          def add_content_block_text = t("add", scope: "decidim.badges.admin.badge_list")

          def active_content_blocks_title = t("active", scope: "decidim.badges.admin.badge_list")

          def inactive_content_blocks_title = t("inactive", scope: "decidim.badges.admin.badge_list")

          def content_block_destroy_confirmation_text = t("confirm_delete", scope: "decidim.badges.admin.badge_list")

          def available_manifests
            @available_manifests ||= Decidim::Badges.registry.all
          end

          def resource_create_url(manifest_name) = decidim_admin_badges.new_badge_list_badge_path(manifest_name:)

          def resource_sort_url = decidim_admin_badges.badge_list_path

          def active_blocks = badges.published

          def inactive_blocks = badges.unpublished

          def badges
            @badges ||= Decidim::Badges::Badge.where(organization: current_organization)
          end

          def resource_content_block_cell = "decidim/badges/admin/organization_badge"

        end
      end
    end
  end
end
