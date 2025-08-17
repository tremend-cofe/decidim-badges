# frozen_string_literal: true

module Decidim
  module Badges
    module Admin
      class UpdateBadge < Decidim::Command
        include ::Decidim::AttachmentAttributesMethods

        delegate :current_user, to: :form

        def initialize(form, badge)
          @form = form
          @badge = badge
        end

        def call
          return broadcast(:invalid) if form.invalid?

          update_badge

          broadcast(:ok)
        end

        private
        attr_reader :form, :badge

        def update_badge
          Decidim.traceability.update!(badge, current_user, attributes)
        end

        def attributes
          {
            name: form.name,
            earning_methods: form.earning_methods,
            description: form.description,
            file: form.file,
            levels: form.levels.compact_blank
          }.merge(
            attachment_attributes(:file)
          ).compact_blank.tap do |attrs|
            attrs[:file] = nil if form.file.blank?
          end
        end
      end
    end
  end
end