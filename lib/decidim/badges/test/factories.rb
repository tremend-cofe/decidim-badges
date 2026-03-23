# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/core/test/factories"

FactoryBot.define do
  factory :badge, class: "Decidim::Badges::Badge" do
    transient do
      skip_injection { false }
      create_component { true }
    end
    organization { create(:organization, skip_injection:) }
    name { generate_localized_title(:badge_name, skip_injection:) }
    description { generate_localized_description(:badge_description, skip_injection:, before: "", after: "") }
    earning_methods { generate_localized_title(:badge_earning_methods, skip_injection:) }
    published_at { Time.current }
    weight { 0 }
    levels { { "0" => "1", "1" => "5", "2" => "6", "3" => "10", "4" => "40" } }
    participatory_space { create(:participatory_process, organization:, skip_injection:) }
    component { nil }
    manifest_name { "comment_created" }
    file { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }

    after(:build) do |badge, evaluator|
      if badge.participatory_space.present? && evaluator.create_component == true
        badge.component = create(:dummy_component, participatory_space: badge.participatory_space, skip_injection: evaluator.skip_injection)
      end
    end
    trait :unpublished do
      published_at { nil }
    end
  end

  factory :badge_score, class: "Decidim::Badges::BadgeScore" do
    badge { create(:badge) }
    user { create(:user, :confirmed, organization: badge.organization) }
    value { 5 }
    level { 1 }
  end
end
