# frozen_string_literal: true

module Decidim
  module Badges
    module Admin
      class ReorderBadges < Decidim::Command
        def initialize(organization, order)
          @organization = organization
          @order = order.is_a?(Array) && order.present? ? order : []
        end

        def call
          return broadcast(:invalid) if order.blank?

          reorder_badges
          broadcast(:ok)
        end

        private

        attr_reader :organization, :order

        def reorder_badges
          transaction do
            reset_weights
            collection.reload
            set_new_weights
            unpublish_removed_content_blocks
            publish_appearing_content_blocks
          end
        end

        def reset_weights
          # rubocop:disable Rails/SkipsModelValidations
          collection.where.not(weight: nil).update_all(weight: nil)
          # rubocop:enable Rails/SkipsModelValidations
        end

        def set_new_weights
          data = order.each_with_index.inject({}) do |hash, (id, index)|
            hash.update(id => index + 1)
          end

          data.each do |id, weight|
            content_block = collection.find_by(id:)
            content_block.update!(weight:) if content_block.present?
          end
        end

        # rubocop:disable Rails/SkipsModelValidations
        def unpublish_removed_content_blocks
          collection.where(weight: nil).update_all(published_at: nil)
        end

        def publish_appearing_content_blocks
          collection.where(published_at: nil).where.not(weight: nil).update_all(published_at: Time.current)
        end
        # rubocop:enable Rails/SkipsModelValidations

        def collection
          @collection ||= Decidim::Badges::Badge.where(organization:)
        end
      end
    end
  end
end
