# frozen_string_literal: true

module Decidim
  module Badges
    module Overwrites
      module BadgeCell
        def status
          @status ||= options[:status] || Decidim::Badges::BadgeStatus.new(model, badge)
        end
      end
    end
  end
end
