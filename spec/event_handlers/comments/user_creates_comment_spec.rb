# frozen_string_literal: true

require "spec_helper"

describe "User creates comment", type: :system do
  let(:form_params) do
    {
      "comment" => {
        "body" => body,
        "alignment" => 1,
        "commentable" => commentable
      }
    }
  end
  let(:form) do
    Decidim::Comments::CommentForm.from_params(
      form_params
    ).with_context(
      current_organization: organization,
      current_user: author
    )
  end
  let(:command) { Decidim::Comments::CreateComment.new(form) }
  let(:body) { "Very nice idea that is not going to be blocked by engine" }

  include_examples "badge granted on new comment"
  include_examples "sending level up notifications" do
    let(:additional) do
      additional_res = []
      count.times { additional_res.push create(:comment, author:, commentable: create(:dummy_resource, component:)) }

      additional_res
    end
  end
end
