# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/badges/version"

Gem::Specification.new do |spec|
  spec.version = "0.32.0.rc1"
  spec.authors = ["Alexandru Emil Lupu"]
  spec.email = ["contact@alecslupu.ro"]
  spec.license = "AGPL-3.0-or-later"
  spec.homepage = "https://decidim.org"
  spec.metadata = {}
  spec.required_ruby_version = "~> 3.4.0"

  spec.name = "decidim-badges"
  spec.summary = "A decidim badges module"
  spec.description = "Decidim Module to allow users define their own badges."

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").select do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w(app/ config/ db/ lib/ LICENSE-AGPLv3.txt Rakefile README.md))
    end
  end

  spec.add_dependency "decidim-admin", "~> 0.32.0.rc1"
  spec.add_dependency "decidim-core", "~> 0.32.0.rc1"
  spec.add_dependency "deface"
end
