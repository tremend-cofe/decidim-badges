# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/badges/version"

Gem::Specification.new do |s|
  s.version = Decidim::Badges.version
  s.authors = ["Alexandru Emil Lupu"]
  s.email = ["contact@alecslupu.ro"]
  s.license = "AGPL-3.0-or-later"
  s.homepage = "https://gitlab.dhs.tech.ec.europa.eu/comm/libraries/decidim/decidim-module-badges"
  s.metadata = {}
  s.required_ruby_version = "~> 3.3"

  s.name = "decidim-badges"
  s.summary = "A decidim badges module"
  s.description = "Decidim Module to allow users define their own badges."

  s.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").select do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w(app/ config/ db/ lib/ LICENSE-AGPLv3.txt Rakefile README.md))
    end
  end

  s.add_dependency "decidim-admin", "~> 0.31.1"
  s.add_dependency "decidim-core", "~> 0.31.1"
  s.add_dependency "deface"
end
