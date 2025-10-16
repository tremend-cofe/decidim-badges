# frozen_string_literal: true

require "decidim/badges/organization/admin"
require "decidim/badges/engine"
require "decidim/badges/organization/admin_engine"

module Decidim
  # This namespace holds the logic of the `Badges` component. This component
  # allows users to create badges in a participatory space.
  module Badges
    autoload :BadgeManifest, "decidim/badges/badge_manifest"
    autoload :BadgeRegistry, "decidim/badges/badge_registry"
    autoload :BadgeStatus, "decidim/badges/badge_status"

    module Overwrites
      autoload :BadgesController, "decidim/badges/overwrites/badges_controller"
      autoload :BadgeCell, "decidim/badges/overwrites/badge_cell"
      autoload :BadgesCell, "decidim/badges/overwrites/badges_cell"
      autoload :BadgeScorer, "decidim/badges/overwrites/badge_scorer"
      autoload :BadgeStatus, "decidim/badges/overwrites/badge_status"
      autoload :Gamification, "decidim/badges/overwrites/gamification"
      autoload :DeleteComment, "decidim/badges/overwrites/delete_comment"

      autoload :CreateFollow, "decidim/badges/overwrites/create_follow"
      autoload :DeleteFollow, "decidim/badges/overwrites/delete_follow"

      autoload :PublishProposal, "decidim/badges/overwrites/publish_proposal"
      autoload :WithdrawProposal, "decidim/badges/overwrites/withdraw_proposal"
      autoload :NotifyProposalAnswer, "decidim/badges/overwrites/notify_proposal_answer"
    end

    # Semi-private: The BadgeRegistry to register manifests of badges to.
    def self.registry
      @badge_registry ||= Decidim::Badges::BadgeRegistry.new
    end

    # Public: Returns all available badges.
    #
    # Returns an Array<BadgeManifest>
    def self.manifests
      registry.all
    end

    # Public: Finds a BadgeManifest given a name.
    #
    # Returns a BadgeManifest if found, nil otherwise.
    def self.find_manifest(name)
      registry.find(name)
    end

    # Public: Registers a new BadgeManifest.
    #
    # Example:
    #
    #     Decidim::Badges.register_badge(:foo) do |badge|
    #     end
    #
    # Returns nothing if registered successfully, raises an exception
    # otherwise.
    def self.register_manifest(name, &)
      registry.register(name, &)
    end

    def self.compute_score(manifest_name, user:, participatory_space: nil, component: nil)
      return unless user.is_a?(Decidim::UserBaseEntity)

      validate!(user:, participatory_space:, component:)

      badge = Decidim::Badges::Badge.published.where(organization: user.organization, manifest_name:, participatory_space:, component:).first

      return if badge.blank?

      if badge.manifest.reset.present?
        value = badge.manifest.reset.call(user, participatory_space, component)

        Decidim::Badges::BadgeScore.find_or_create_by(user:, badge:).update!(value:)
      end
    end

    def self.validate!(user:, participatory_space: nil, component: nil)
      raise ArgumentError, "The Organization mismatch in badge" if participatory_space.present? && user.organization != participatory_space.organization
      raise ArgumentError, "The Organization mismatch in badge" if component.present? && user.organization != component.organization
    end

    def self.increment_score(manifest_name, user:, participatory_space: nil, component: nil)
      return unless user.is_a?(Decidim::UserBaseEntity)

      validate!(user:, participatory_space:, component:)

      badge = Decidim::Badges::Badge.published.where(organization: user.organization, manifest_name:, participatory_space:, component:).first

      score = Decidim::Badges::BadgeScore.find_or_create_by(user:, badge:)
      score.update(value: (score.value + 1))
    end

    def self.decrement_score(manifest_name, user:, participatory_space: nil, component: nil)
      return unless user.is_a?(Decidim::UserBaseEntity)

      validate!(user:, participatory_space:, component:)

      badge = Decidim::Badges::Badge.published.where(organization: user.organization, manifest_name:, participatory_space:, component:).first

      return if badge.blank?

      score = Decidim::Badges::BadgeScore.find_or_create_by(user:, badge:)
      score.update(value: (score.value - 1))
    end
  end
end
