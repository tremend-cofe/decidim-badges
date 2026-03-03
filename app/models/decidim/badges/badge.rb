# frozen_string_literal: true

module Decidim
  module Badges
    class Badge < ApplicationRecord
      include Decidim::HasAttachments
      include Decidim::HasUploadValidations
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::Publicable
      # include Decidim::SoftDeletable

      belongs_to :organization, class_name: "Decidim::Organization", foreign_key: :decidim_organization_id
      belongs_to :participatory_space, polymorphic: true, optional: true
      belongs_to :component, class_name: "Decidim::Component", foreign_key: :decidim_component_id, optional: true
      has_many :scores, class_name: "Decidim::Badges::BadgeScore", dependent: :destroy, foreign_key: :decidim_badges_badge_id

      has_one_attached :file
      # validates :file, presence: true, unless: :persisted?

      validates_upload :file, uploader: Decidim::ImageUploader

      default_scope -> { order(:weight) }

      def self.log_presenter_class_for(_log)
        Decidim::Badges::AdminLog::BadgePresenter
      end

      # Public: Finds the manifest this component is associated to.
      #
      # Returns a ComponentManifest.
      def manifest
        Decidim::Badges.find_manifest(manifest_name)
      end

      def level_of(score)
        levels.each do |threshold, index|
          return threshold.to_i if index.to_i > score.to_i
        end

        levels.length
      end

      def max_level
        levels.values.compact_blank.count
      end
    end
  end
end
