# frozen_string_literal: true

module Decidim
  module Badges
    module Organization
      module Admin
        class BadgeController < ApplicationController
          layout "decidim/admin/settings"

          include Decidim::SanitizeHelper

          helper_method :badge, :badge_edit_text, :resource_landing_page_content_block_path, :submit_button_text,
                        :badge_add_text, :participatory_space_options, :grouped_components_options, :grouped_actions_options

          def new
            enforce_permission_to_update_resource
            @badge = Decidim::Badges::Badge.new(organization: current_organization, manifest_name: params[:manifest_name])
            @form = form(Decidim::Badges::Admin::BadgeForm).from_model(badge)
          end

          def edit
            enforce_permission_to_update_resource
            @form = form(Decidim::Badges::Admin::BadgeForm).from_model(badge)

            render "decidim/badges/organization/admin/badge/edit"
          end

          def create
            enforce_permission_to_update_resource
            @badge = Decidim::Badges::Badge.new(organization: current_organization, manifest_name: params[:manifest_name])
            @form = form(Decidim::Badges::Admin::BadgeForm).from_params(params)
            Decidim::Badges::Admin::CreateBadge.call(@form) do
              on(:ok) do
                flash.now[:success] = t("decidim.badges.admin.badge.create.success")
                redirect_to edit_resource_landing_page_path
              end

              on(:invalid) do
                flash.now[:error] = t("decidim.badges.admin.badge.create.error")
                render "decidim/badges/organization/admin/badge/new"
              end
            end
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
                flash.now[:error] = t("decidim.badges.admin.badge.update.error")
                render "decidim/badges/organization/admin/badge/edit"
              end
            end
          end

          def destroy
            enforce_permission_to_update_resource

            Decidim::Badges::Admin::DestroyBadge.call(badge, current_user) do
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

          def badge_edit_text
            t("edit", scope: "decidim.badges.organization.admin.badge.edit",
                      badge: decidim_sanitize_translated(badge.name).presence || badge.manifest.translated_name)
          end

          def badge_add_text = t("add", scope: "decidim.badges.organization.admin.badge.add")

          def submit_button_text = t("submit", scope: "decidim.badges.organization.admin.badge.form")

          def resource_landing_page_content_block_path = decidim_admin_badges.badge_list_badge_path(params[:id])

          def participatory_space_options = dropdown_options.fetch(:participatory_spaces, []).sort_by(&:first)

          def grouped_components_options = dropdown_options.fetch(:components, [])

          def grouped_actions_options = dropdown_options.fetch(:actions, [])

          def dropdown_options
            return @dropdown_options if defined?(@dropdown_options)

            @dropdown_options = { participatory_spaces: [], components: {}, actions: {} }

            current_organization.public_participatory_spaces.map do |space|
              space_id = [translated_attribute(space.title), "(#{space.class.name.demodulize.underscore.humanize})"].join(" ")
              @dropdown_options[:participatory_spaces].push [space_id, [space.class.name.to_s, space.id].join("#")]

              @dropdown_options[:components][space_id] = []
              space.components.published.map do |component|
                @dropdown_options[:components][space_id].push([translated_attribute(component.name), component.id])
              end
            end

            @dropdown_options
          end
        end
      end
    end
  end
end
