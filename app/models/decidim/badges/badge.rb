# frozen_string_literal: true
module Decidim
  module Badges
    class Badge < ApplicationRecord
      include Decidim::HasAttachments
      include Decidim::HasUploadValidations
      include Decidim::Loggable
      include Decidim::Publicable

      belongs_to :gamifiable, polymorphic: true

      has_one_attached :file
      # validates :file, presence: true, unless: :persisted?

      validates_upload :file, uploader: Decidim::ImageUploader

      default_scope -> { order(:weight) }

      def self.log_presenter_class_for(_log)
        Decidim::Badges::AdminLog::BadgePresenter
      end

      def organization
        gamifiable.is_a?(Decidim::Organization) ? gamifiable : gamifiable.try(:organization)
      end
    end
  end
end
