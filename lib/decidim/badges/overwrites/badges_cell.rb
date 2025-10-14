# frozen_string_literal: true

module Decidim
  module Badges
    module Overwrites
      module BadgesCell
        def available_badges
          # Decidim::Gamification.badges.select do |badge|
          #   badge.valid_for?(model)
          # end.sort_by(&:name)
          @available_badges ||= Decidim::Badges::Badge.where(organization: current_organization).published
        end
      end
    end
  end
end
