# frozen_string_literal: true

require "spec_helper"

describe "User creates meeting", type: :system do
  let(:command) { Decidim::Meetings::WithdrawMeeting.new(meeting, author) }

  include_examples "badge granted on published meeting"
end
