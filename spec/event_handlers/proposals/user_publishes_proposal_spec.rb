# frozen_string_literal: true

require "spec_helper"

describe "User creates proposal", type: :system do
  let(:command) { Decidim::Proposals::PublishProposal.new(proposal, author) }

  include_examples "badge granted on published proposal"
end
