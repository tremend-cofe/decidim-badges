# frozen_string_literal: true

require "spec_helper"

describe "Visitors checks the profile page" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    visit decidim.profile_badges_path(nickname: user.nickname)
  end

  context "when badge system is enabled" do
    context "when no badge is present" do
      it "displays the badge information" do
        expect(page).to have_content("Badges")
        expect(page).to have_content("Badges are recognitions to participant actions and progress in the platform.")
      end
    end

    context "when badge is unpublished" do
      let!(:badge) { create(:badge, :unpublished, organization:) }

      it "displays the badge information" do
        expect(page).to have_content("Badges")
        expect(page).to have_content("Badges are recognitions to participant actions and progress in the platform.")

        expect(page).to have_no_content(translated(badge.name))
        expect(page).to have_no_content(decidim_sanitize_translated(badge.name))
      end
    end

    context "when badge is published" do
      let!(:badge) { create(:badge, organization:) }

      before do
        visit current_path
      end

      it "displays the badge information" do
        visit current_path
        expect(page).to have_content("Badges")
        expect(page).to have_content("Badges are recognitions to participant actions and progress in the platform.")

        expect(page).to have_content(decidim_sanitize_translated(badge.name))
      end

      context "when component is not present" do
        let!(:badge) { create(:badge, create_component: false, organization:) }

        it "hides the component information" do
          expect(page).to have_no_content("component")
        end
      end

      context "when user has earned the badge" do
        context "when user has not earned the badge" do
          let!(:score) { create(:badge_score, badge:, user:, value: 0, level: 0) }

          it "displays the badge information" do
            visit current_path
            expect(page).to have_content("Level 0")
          end
        end

        context "when user has earned the level 1 badge" do
          let!(:score) { create(:badge_score, badge:, user:, value: 2, level: 1) }

          it "displays the badge information" do
            visit current_path
            expect(page).to have_content("Level 1")
          end
        end

        context "when user has earned the level 2 badge" do
          let!(:score) { create(:badge_score, badge:, user:, value: 5, level: 2) }

          it "displays the badge information" do
            visit current_path
            expect(page).to have_content("Level 2")
          end
        end

        context "when user has earned the level 3 badge" do
          let!(:score) { create(:badge_score, badge:, user:, value: 7, level: 3) }

          it "displays the badge information" do
            visit current_path
            expect(page).to have_content("Level 3")
          end
        end

        context "when user has earned the level 4 badge" do
          let!(:score) { create(:badge_score, badge:, user:, value: 10, level: 4) }

          it "displays the badge information" do
            visit current_path
            expect(page).to have_content("Level 4")
          end
        end

        context "when user has earned the level 5 badge" do
          let!(:score) { create(:badge_score, badge:, user:, value: 41, level: 5) }

          it "displays the badge information" do
            visit current_path
            expect(page).to have_content("Level 5")
          end
        end

        context "when user is hyperactive" do
          let!(:score) { create(:badge_score, badge:, user:, value: 41_000, level: 5) }

          it "displays the badge information" do
            visit current_path
            expect(page).to have_content("Level 5")
          end
        end
      end
    end

    context "when multiple badges are present" do
      let!(:badges) { create_list(:badge, 5, organization:) }

      before do
        visit current_path
      end

      it "displays the badge information" do
        expect(page).to have_content("Badges")
        expect(page).to have_content("Badges are recognitions to participant actions and progress in the platform.")
        within "#content" do
          expect(page).to have_css(".profile__badge", count: 5)
        end
      end
    end
  end
end
