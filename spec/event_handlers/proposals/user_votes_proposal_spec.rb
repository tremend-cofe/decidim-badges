# frozen_string_literal: true

require "spec_helper"

describe "User votes proposal", type: :system do
  let(:command) { Decidim::Proposals::VoteProposal.new(proposal, author) }

  include_examples "badge granted on published proposal" do
    let(:manifest_name) { "proposal_voted" }
  end

  context "when the badge does not exist in the database" do
    it "broadcasts ok" do
      expect { command.call }.to broadcast(:ok)
    end
  end
end
