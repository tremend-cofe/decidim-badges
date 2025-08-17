# frozen_string_literal: true

module Decidim
  module Badges
    module Organization
      module Admin
        class BadgeController < ApplicationController
          layout "decidim/admin/settings"

          include Decidim::SanitizeHelper

          helper_method :badge, :badge_edit_text, :resource_landing_page_content_block_path, :submit_button_text, :badge_add_text

          def new
            enforce_permission_to_update_resource
            @form = form(Decidim::Badges::Admin::BadgeForm).instance
            @badge = Decidim::Badges::Badge.new(organization: current_organization)
          end

          def create
            enforce_permission_to_update_resource
            @form = form(Decidim::Badges::Admin::BadgeForm).from_params(params)

            Decidim::Badges::Admin::CreateBadge.call(@form) do
              on(:ok) do
                flash[:success] = t("decidim.badges.admin.badge.create.success")
              end
              on(:invalid) do
                flash[:error] =  t("decidim.badges.admin.badge.create.error")
              end

              redirect_to edit_resource_landing_page_path
            end
          end

          def edit
            enforce_permission_to_update_resource
            @form = form(Decidim::Badges::Admin::BadgeForm).from_model(badge)

            render "decidim/badges/organization/admin/badge/edit"
          end
          def update
            enforce_permission_to_update_resource

            @form = form(Decidim::Badges::Admin::BadgeForm).from_params(params)

            Decidim::Badges::Admin::UpdateBadge.call(@form, badge) do
              on(:ok) do
                flash[:success] = t("decidim.badges.admin.badge.update.success")
                redirect_to edit_resource_landing_page_path
              end
              on(:invalid) do
                flash[:error] = t("decidim.badges.admin.badge.update.error")
                render "decidim/badges/organization/admin/badge/edit"
              end
            end
          end

          def destroy
            enforce_permission_to_update_resource

            Decidim::Badges::Admin::DestroyBadge.call(badge) do
              on(:ok) do
                flash.now[:success] = t("decidim.badges.admin.badge.destroy.success")
              end
              on(:invalid) do
                flash.now[:error] = t("decidim.badges.admin.badge.destroy.error")
              end

              redirect_to edit_resource_landing_page_path
            end
          end

          private

          def enforce_permission_to_update_resource
            enforce_permission_to :update, :badge, organization: current_organization
          end

          def badge
            @badge ||= badges.find(params[:id])
          end

          def badges
            @badges ||= Decidim::Badges::Badge.where(organization: current_organization)
          end

          def edit_resource_landing_page_path = decidim_admin_badges.root_path

          def badge_edit_text = t("edit", scope: "decidim.badges.organization.admin.badge.edit", badge: decidim_sanitize_translated(badge.name).presence || badge.manifest.translated_name)
          def badge_add_text = t("add", scope: "decidim.badges.organization.admin.badge.add")

          def submit_button_text = t("submit", scope: "decidim.badges.organization.admin.badge.form")

          def resource_landing_page_content_block_path = decidim_admin_badges.badge_list_badge_path(params[:id])
        end
      end
    end
  end
end
