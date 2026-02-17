# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Badges
    module Admin
      describe DestroyBadge do
        subject { described_class.new(badge, user) }

        let(:organization) { create(:organization) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let!(:badge) { create(:badge, organization:) }

        it "destroys the member" do
          subject.call
          expect { badge.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it "broadcasts ok" do
          expect do
            subject.call
          end.to broadcast(:ok)
        end

        it "traces the action", versioning: true do
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with(
              :delete,
              badge,
              user,
              resource: { title: badge.name }
            )
            .and_call_original

          expect { subject.call }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
        end
      end
    end
  end
end
