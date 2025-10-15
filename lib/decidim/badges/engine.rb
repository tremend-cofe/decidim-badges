# frozen_string_literal: true

require "rails"
require "decidim/core"
require "deface"

module Decidim
  module Badges
    # This is the engine that runs on the public interface of badges.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Badges

      initializer "decidim_badges.add_cells_view_paths", before: "decidim_core.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Badges::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Badges::Engine.root}/app/views")
      end

      initializer "decidim_badges.deface" do
        Rails.application.configure do
          config.deface.enabled = Decidim::Env.new("DEFACE_ENABLED", true).present?
        end
      end

      initializer "decidim_badges.add_badges" do
        Rails.application.config.to_prepare do
          Decidim::Gamification.singleton_class.send(:prepend, Decidim::Badges::Overwrites::Gamification)
          Decidim::Gamification::BadgeScorer.prepend(Decidim::Badges::Overwrites::BadgeScorer)
          Decidim::Gamification::BadgeStatus.prepend(Decidim::Badges::Overwrites::BadgeStatus)

          Decidim::BadgeCell.prepend(Decidim::Badges::Overwrites::BadgeCell)
          Decidim::BadgesCell.prepend(Decidim::Badges::Overwrites::BadgesCell)
          Decidim::Gamification::BadgesController.prepend(Decidim::Badges::Overwrites::BadgesController)
          Decidim::Gamification::BadgesController.helper(Decidim::ResourceHelper)

          Decidim::Comments::DeleteComment.prepend(Decidim::Badges::Overwrites::DeleteComment) if Decidim.module_installed?(:comments)
        end
      end

      initializer "decidim_badges.register_badges.comment_created", after: "decidim_badges.register_badges" do
        if Decidim.module_installed?(:comments)
          Decidim::Badges.register_manifest(:comment_created) do |badge|
            badge.reset = lambda { |author, participatory_space, component|
              comments = Decidim::Comments::Comment.not_deleted.not_hidden.where(author:)

              comments.where(participatory_space:) if participatory_space.present?

              if component.present?
                root_commentables = begin
                  component.manifest.data_portable_entities.collect do |entity|
                    entity.constantize.where(component: component).all
                  end
                rescue StandardError
                  []
                end

                comments.where(root_commentable: root_commentables)
              end

              comments.distinct.count(:decidim_root_commentable_id)
            }
          end

          ActiveSupport::Notifications.subscribe("decidim.comments.create_comment:after") do |_event_name, data|
            user = data[:resource].author

            Decidim::Badges.compute_score(:comment_created, user:)
            Decidim::Badges.compute_score(:comment_created, user:, participatory_space: data[:resource].participatory_space)
            Decidim::Badges.compute_score(:comment_created, user:, participatory_space: data[:resource].participatory_space, component: data[:resource].component)
          end

          ActiveSupport::Notifications.subscribe("decidim.comments.delete_comment:after") do |_event_name, data|
            user = data[:resource].author

            Decidim::Badges.compute_score(:comment_created, user:)
            Decidim::Badges.compute_score(:comment_created, user:, participatory_space: data[:resource].participatory_space)
            Decidim::Badges.compute_score(:comment_created, user:, participatory_space: data[:resource].participatory_space, component: data[:resource].component)
          end
        end
      end
    end
  end
end
