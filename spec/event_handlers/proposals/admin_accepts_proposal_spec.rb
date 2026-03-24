# frozen_string_literal: true

require "spec_helper"

describe "User widthraws proposal", type: :system do
  let(:command) { Decidim::Proposals::Admin::NotifyProposalAnswer.new(proposal, "not_answered") }

  include_examples "badge granted on published proposal" do
    let(:manifest_name) { "proposal_accepted" }
    let(:dummy_resource) { create(:proposal, :accepted, :participant_author, :unpublished, component:) }
  end
end
