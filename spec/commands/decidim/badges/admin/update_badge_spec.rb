# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Badges
    module Admin
      describe UpdateBadge do
        subject { described_class.new(form, badge) }

        let(:organization) { create(:organization) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let(:badge) { create(:badge, organization:) }
        let(:invalid) { false }

        let(:participatory_space) { create(:participatory_process, organization:) }

        let(:form) do
          BadgeForm.from_params(
            name: {
              "en" => "New name"
            },
            earning_methods: {
              "en" => "Earning methods"
            },
            description: {
              "en" => "Description field"
            },
            participatory_space_type: participatory_space.class.name,
            participatory_space_id: participatory_space.id,
            decidim_component_id: nil,
            file: upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg")),
            manifest_name: "proposal_created",
            levels: {
              "0" => 3,
              "1" => 7,
              "2" => 13,
              "3" => 23,
              "4" => 70
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
            subject.call
            badge.reload
          end

          it "updates the name of the badge" do
            expect(translated(badge.name)).to eq("New name")
          end

          it "updates the description of the badge" do
            expect(translated(badge.description)).to eq("Description field")
          end

          it "updates the earning_methods of the badge" do
            expect(translated(badge.earning_methods)).to eq("Earning methods")
          end

          it "updates the participatory_space of the badge" do
            expect(badge.participatory_space).to eq(participatory_space)
          end

          it "updates the file of the badge" do
            expect(badge.file).to be_attached
            expect(badge.file.filename).to eq("city.jpeg")
          end

          it "updates the levels of the badge" do
            expect(badge.levels).to eq({
                                         "0" => 3,
                                         "1" => 7,
                                         "2" => 13,
                                         "3" => 23,
                                         "4" => 70
                                       })
          end

          it "traces the action", versioning: true do
            expect(Decidim.traceability)
              .to receive(:update!)
              .with(badge, user, hash_including(:name, :description, :levels))
              .and_call_original

            expect { subject.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
          end
        end
      end
    end
  end
end
