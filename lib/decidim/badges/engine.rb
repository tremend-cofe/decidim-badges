# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Badges
    # This is the engine that runs on the public interface of badges.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Badges

      initializer "decidim_badges.add_cells_view_paths", before: "decidim_core.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Badges::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Badges::Engine.root}/app/views")
      end
    end
  end
end
