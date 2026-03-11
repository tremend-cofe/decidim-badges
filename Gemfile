# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = ENV.fetch("DECIDIM_VERSION", "~> 0.31.1")

gem "decidim", DECIDIM_VERSION
gem "decidim-badges", path: "./"

gem "bootsnap", "~> 1.3"
gem "deface"
gem "sidekiq"

group :development, :test do
  gem "decidim-dev", DECIDIM_VERSION
  gem "rubocop-performance"
  gem "simplecov", require: false
end

group :development do
  gem "letter_opener_web", "~> 1.4"
  gem "listen", "~> 3.1"
  gem "web-console", "~> 4.0"
end

group :test do
  gem "rubocop-faker"
end
