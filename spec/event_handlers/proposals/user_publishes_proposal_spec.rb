# frozen_string_literal: true

require "spec_helper"

describe "User creates proposal", type: :system do
  let(:command) { Decidim::Proposals::PublishProposal.new(proposal, author) }

  include_examples "badge granted on published proposal"
  include_examples "sending level up notifications" do
    let(:additional) { create_list(:proposal, count, :published, users: [author], component:) }
  end
end
