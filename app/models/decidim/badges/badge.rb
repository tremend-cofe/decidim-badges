# frozen_string_literal: true
module Decidim
  module Badges
    class Badge < ApplicationRecord
      include Decidim::HasUploadValidations
      include Decidim::Publicable

      belongs_to :gamifiable, polymorphic: true

      has_one_attached :file
      # validates_upload :file, uploader: Decidim::ImageUploader

      default_scope -> { order(:weight) }
    end
  end
end
