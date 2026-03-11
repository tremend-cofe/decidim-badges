# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Badges
    module Admin
      describe CreateBadge do
        subject { described_class.new(form) }
        let(:organization) { create(:organization) }
        let(:user) { create(:user, :admin, :confirmed, organization: organization) }
        let(:form) do
          BadgeForm.from_params(
            name: Decidim::Faker::Localized.name,
            earning_methods: Decidim::Faker::Localized.sentences(number: 2),
            description: Decidim::Faker::Localized.sentences(number: 2),
            participatory_space_type: nil,
            participatory_space_id: nil,
            decidim_component_id: nil,
            file: upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg")),
            manifest_name: "proposal_created",
            levels: {
              "0" => 1,
              "1" => 3,
              "2" => 5,
              "3" => 10,
              "4" => 20
            }
          ).with_context(current_organization: organization, current_user: user)
        end

        context "when form is invalid" do
          before do
            allow(form).to receive(:valid?).and_return(false)
          end

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when the form is valid" do
          before do
            form.valid?
            expect(form.errors).to be_empty
          end

          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "creates a new badge" do
            expect { subject.call }.to change(Badges::Badge, :count).by(1)
          end

          it "updates the file of the badge" do
            expect(badge.file).to be_attached
            expect(badge.file.filename).to eq("city.jpeg")
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability).to receive(:create).with(
              Decidim::Badges::Badge,
              user,
              hash_including(:name, :organization, :earning_methods, :description, :levels,
                             :participatory_space_type, :participatory_space_id, :decidim_component_id, :manifest_name)
            ).and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count).by(1)
            action_log = Decidim::ActionLog.last!
            expect(action_log.version).to be_present
          end
        end
      end
    end
  end
end
