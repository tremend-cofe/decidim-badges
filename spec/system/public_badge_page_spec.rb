# frozen_string_literal: true

require "spec_helper"

describe "Visitors checks the badge page" do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
    visit decidim.gamification_badges_path
  end

  context "when badge system is disabled" do
    let(:organization) { create(:organization, badges_enabled: false) }

    it "the page is not present" do
      expect(page).to have_content("Routing Error")
    end
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
        expect(page).to have_content(translated(badge.description))
        expect(page).to have_content(translated(badge.earning_methods))
      end

      context "when participatory space is present" do
        it "displays the space information" do
          expect(page).to have_content("Perform the action in #{translated(badge.participatory_space.title)} space")
        end
      end

      context "when participatory space is not present" do
        let!(:badge) { create(:badge, organization:, participatory_space: nil) }

        it "displays the space information" do
          expect(page).to have_no_content("Perform the action")
        end
      end

      context "when component is present" do
        it "displays the component information" do
          expect(page).to have_content("Perform the action in #{translated(badge.component.name)} component")
        end
      end

      context "when component is not present" do
        let!(:badge) { create(:badge, create_component: false, organization:) }

        it "hides the component information" do
          expect(page).to have_no_content("component")
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
          expect(page).to have_css("h2", count: 5)
        end
      end
    end
  end
end
