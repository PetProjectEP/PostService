require 'rails_helper'
require 'tests_helpers/user_assets'

RSpec.describe Post, type: :model do
  describe "validations, " do
    before :all do
      @user = UserAssets::ensure_valid_user
      @valid_user_id = @user[:id]
    end
    
    subject(:post) { Post.new({ title: "Good title", text: "A bit of good text", user_id: @valid_user_id }) } 
    
    describe "user validations, " do
      it "can be created with existing user" do  
        post[:user_id] = @valid_user_id
        expect(post.valid?).to be(true)
      end

      it "can't be created with wrong user_id" do
        post[:user_id] = -1
        expect(post.valid?).to be(false)
      end
    end
    
    describe "title validations, " do
      it "can't be created with title length > 64" do
        post[:title] = (0...65).map { (65 + rand(26)).chr }.join
        expect(post.valid?).to be(false)
      end

      it "can't be created with no title" do
        post[:title] = ""
        expect(post.valid?).to be(false)
      end
    end

    describe "text-body validations" do
      it "can't be created with text length > 512" do
        post[:text] = (0...513).map { (65 + rand(26)).chr }.join
        expect(post.valid?).to be(false)
      end

      it "can't be created with no text" do
        post[:text] = ""
        expect(post.valid?).to be(false)
      end
    end
  end
end
