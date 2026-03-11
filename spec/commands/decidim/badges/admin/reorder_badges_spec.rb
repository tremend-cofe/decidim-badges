# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Badges
    module Admin
      describe ReorderBadges do
        subject { described_class.new(*args) }
        let(:args) { [organization, order] }
        let(:organization) { create(:organization) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let!(:badge1) { create(:badge, organization:, weight: 0) }
        let!(:badge2) { create(:badge, organization:, weight: 1) }
        let!(:badge3) { create(:badge, organization:, weight: 2, published_at: nil) }
        let(:order) { [badge1.id, badge2.id] }

        context "when the order is nil" do
          let(:order) { nil }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the order is empty" do
          let(:order) { [] }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the order is valid" do
          it "is valid" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "reorders the blocks" do
            subject.call
            badge1.reload
            badge2.reload
            badge3.reload

            expect(badge1.weight).to eq 1
            expect(badge2.weight).to eq 2
            expect(badge3.weight).to be_nil
          end
        end

        context "when scoped resource is present and order is valid" do
          let(:order) { [badge3.id, badge2.id, badge1.id] }

          it "is valid" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "only affects to content blocks associated with the resource" do
            expect { subject.call }.not_to change(Decidim::Badges::Badge, :count)

            badge1.reload
            badge2.reload
            badge3.reload

            expect(badge1.weight).to eq 3
            expect(badge2.weight).to eq 2
            expect(badge3.weight).to eq 1
          end
        end
      end
    end
  end
end
