# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/core/test/factories"

FactoryBot.define do
  factory :badge, class: "Decidim::Badges::Badge" do
    transient do
      skip_injection { false }
    end
    organization { create(:organization, skip_injection:) }
    name { generate_localized_title(:badge_name, skip_injection:) }
    description { generate_localized_description(:badge_description, skip_injection:) }
    earning_methods { generate_localized_title(:badge_earning_methods, skip_injection:) }
    published_at { Time.current }
    weight { 0 }
    levels { { "0" => "1", "1" => "5", "2" => "6", "3" => "10", "4" => "40" } }
    participatory_space { create(:participatory_process, organization: organization, skip_injection:) }
    component { nil }
    manifest_name { "comment_created" }
    file { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }
  end
end
