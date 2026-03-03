# frozen_string_literal: true

module Decidim
  module Badges
    module Admin
      class OrganizationBadgeCell < ::Decidim::Admin::ContentBlockCell
        delegate :content_block_destroy_confirmation_text, to: :view_context

        def edit_content_block_path = decidim_admin_badges.edit_badge_list_badge_path(model)

        def content_block_path = decidim_admin_badges.badge_list_badge_path(model)

        def decidim_admin = Decidim::Admin::Engine.routes.url_helpers

        def name = translated_attribute(model.name)
      end
    end
  end
end
