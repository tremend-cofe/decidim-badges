# frozen_string_literal: true
module Decidim
  module Badges
    class Badge < ApplicationRecord
      include Decidim::HasAttachments
      include Decidim::HasUploadValidations
      include Decidim::Loggable
      include Decidim::Publicable

      belongs_to :organization, class_name: "Decidim::Organization", foreign_key: :decidim_organization_id
      belongs_to :participatory_space, polymorphic: true, optional: true
      belongs_to :component, class_name: "Decidim::Component", foreign_key: :decidim_component_id, optional: true

      has_one_attached :file
      # validates :file, presence: true, unless: :persisted?

      validates_upload :file, uploader: Decidim::ImageUploader

      default_scope -> { order(:weight) }

      def self.log_presenter_class_for(_log)
        Decidim::Badges::AdminLog::BadgePresenter
      end

    end
  end
end
