# frozen_string_literal: true

shared_context "grants the badges as planned" do
  context "when the badge does not exist in the database" do
    it "does not create a badge score" do
      expect { command.call }.not_to(change(Decidim::Badges::BadgeScore, :count))
    end
  end

  context "when the badge exists but is not published" do
    let!(:badge) { create(:badge, :unpublished, manifest_name:, organization:) }

    it "does not create a badge score" do
      expect { command.call }.not_to(change(Decidim::Badges::BadgeScore, :count))
    end
  end

  context "when the badge exists and is published" do
    let!(:badge) { create(:badge, :published, manifest_name:, organization:, participatory_space: nil) }

    it "creates a badge score" do
      expect { command.call }.to change(Decidim::Badges::BadgeScore, :count).by(1)
    end
  end

  context "when the badge exists and is published and space is scoped" do
    let!(:badge) { create(:badge, :published, manifest_name:, organization:, participatory_space:, create_component: false) }

    it "creates a badge score" do
      expect { command.call }.to change(Decidim::Badges::BadgeScore, :count).by(1)
    end
  end

  context "when the badge exists and is published and has space and component" do
    let!(:badge) { create(:badge, :published, manifest_name:, organization:, participatory_space:, component:, create_component: false) }

    it "creates a badge score" do
      expect { command.call }.to change(Decidim::Badges::BadgeScore, :count).by(1)
    end
  end

  context "when it matches 2 badges" do
    let!(:badge) { create(:badge, :published, manifest_name:, organization:, participatory_space: nil, create_component: false) }
    let!(:badge_space) { create(:badge, :published, manifest_name:, organization:, participatory_space:, create_component: false) }

    it "creates a badge score" do
      expect { command.call }.to change(Decidim::Badges::BadgeScore, :count).by(2)
    end
  end

  context "when it matches 3 badges" do
    let!(:badge) { create(:badge, :published, manifest_name:, organization:, participatory_space: nil, create_component: false) }
    let!(:badge_space) { create(:badge, :published, manifest_name:, organization:, participatory_space:, create_component: false) }
    let!(:badge_component) { create(:badge, :published, manifest_name:, organization:, participatory_space:, component:, create_component: false) }

    it "creates a badge score" do
      expect { command.call }.to change(Decidim::Badges::BadgeScore, :count).by(3)
    end
  end
end

shared_examples "sending level up notifications" do
  let(:user) { author }
  context "and was not previously granted" do
    let!(:badge) { create(:badge, :published, manifest_name:, organization:, participatory_space: nil) }

    it "dispatches a Badge Earned event" do
      expect(Decidim::Notification.where(event_name: "decidim.events.badges.badge_earned").count).to eq(0)
      expect(Decidim::Notification.where(event_name: "decidim.events.badges.level_up").count).to eq(0)

      perform_enqueued_jobs { command.call }

      expect(Decidim::Notification.where(event_name: "decidim.events.badges.badge_earned").count).to eq(1)
      expect(Decidim::Notification.where(event_name: "decidim.events.badges.level_up").count).to eq(0)
    end
  end

  context "and was previously granted" do
    let!(:badge) { create(:badge, :published, manifest_name:, organization:, participatory_space: nil) }
    let!(:badge_score) { create(:badge_badge_score, badge:, user:, value: count, level: 1) }
    let(:count) { 4 }

    it "dispatches a Level up badge" do
      expect(Decidim::Notification.where(event_name: "decidim.events.badges.badge_earned").count).to eq(0)
      expect(Decidim::Notification.where(event_name: "decidim.events.badges.level_up").count).to eq(0)

      additional.map(&:reload)
      perform_enqueued_jobs { command.call }

      expect(Decidim::Notification.where(event_name: "decidim.events.badges.badge_earned").count).to eq(0)
      expect(Decidim::Notification.where(event_name: "decidim.events.badges.level_up").count).to eq(1)
    end
  end

  context "and was previously granted" do
    let!(:badge) { create(:badge, :published, manifest_name:, organization:, participatory_space: nil) }
    let!(:badge_score) { create(:badge_badge_score, badge:, user:, value: count, level: 3) }
    let(:count) { 7 }

    it "skips displatching the level up event" do
      expect(Decidim::Notification.where(event_name: "decidim.events.badges.badge_earned").count).to eq(0)
      expect(Decidim::Notification.where(event_name: "decidim.events.badges.level_up").count).to eq(0)

      additional.map(&:reload)
      perform_enqueued_jobs { command.call }

      expect(Decidim::Notification.where(event_name: "decidim.events.badges.badge_earned").count).to eq(0)
      expect(Decidim::Notification.where(event_name: "decidim.events.badges.level_up").count).to eq(0)
    end
  end
end

shared_examples "badge granted on published meeting" do
  let(:manifest_name) { "meeting_created" }
  let(:component_manifest) { "meetings" }
  let(:dummy_resource) { create(:meeting, :participant_author, component:) }
  let(:meeting) { dummy_resource }

  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, organization:) }
  let!(:author) { meeting.author }
  let(:component) { create(:meeting_component, participatory_space:, manifest_name: component_manifest) }

  it_behaves_like "grants the badges as planned"
end

shared_examples "badge granted on published proposal" do
  let(:manifest_name) { "proposal_created" }
  let(:component_manifest) { "proposals" }
  let(:dummy_resource) { create(:proposal, :participant_author, :unpublished, component:) }
  let(:proposal) { dummy_resource }

  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, organization:) }
  let!(:author) { proposal.coauthorships.first.author }
  let(:component) { create(:proposal_component, participatory_space:, manifest_name: component_manifest) }

  it_behaves_like "grants the badges as planned"
end

shared_examples "badge granted on new comment" do
  let(:manifest_name) { "comment_created" }
  let(:component_manifest) { "dummy" }
  let(:dummy_resource) { create(:dummy_resource, component:) }
  let(:commentable) { dummy_resource }

  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, organization:) }
  let!(:author) { create(:user, :confirmed, organization:) }
  let(:component) { create(:component, participatory_space:, manifest_name: component_manifest) }

  it_behaves_like "grants the badges as planned"
end
