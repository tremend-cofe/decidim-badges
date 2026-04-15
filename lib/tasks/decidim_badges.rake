# frozen_string_literal: true

namespace :decidim do
  namespace :badges do
    task :choose_target_plugins do
      ENV["FROM"] = "#{ENV.fetch("FROM", nil)},decidim_badges"
    end

    desc "Recompute all badge scores for all badges"
    task :compute do
      Decidim::Badges::Badge.published.find_each do |badge|
        Decidim::Badges::PublishBadgeJob.perform_later(badge.id)
      end
    end
  end
end

Rake::Task["decidim:choose_target_plugins"].enhance do
  Rake::Task["decidim:badges:choose_target_plugins"].invoke
end
