# frozen_string_literal: true

module Decidim
  module Badges
    # This is the engine that runs on the public interface of `Badges`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Badges::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
      end

      def load_seed
        nil
      end
    end
  end
end
