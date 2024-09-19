require 'rails_helper'

RSpec.describe Post, type: :model do
  describe "RSpec installation" do
    it "runs tests properly" do
      post = Post.new({ title: "Good title", text: "A bit of good text", user_id: 1 })
      expect{post.save}.not_to raise_error
    end
  end
end
