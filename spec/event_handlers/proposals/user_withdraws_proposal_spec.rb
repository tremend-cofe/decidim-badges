# frozen_string_literal: true

require "spec_helper"

describe "User widthraws proposal", type: :system do
  let(:command) { Decidim::Proposals::WithdrawProposal.new(proposal, author) }

  include_examples "badge granted on published proposal"
end
