# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Badges do
    subject { described_class }

    it "has version" do
      expect(subject.version).to eq("0.32.0.rc1")
    end
  end
end
