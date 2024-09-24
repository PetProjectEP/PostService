require 'rails_helper'
require 'tests_helpers/user_assets'
require 'tests_helpers/post_assets'

RSpec.describe "Posts", type: :request do
  before :all do
    @user = UserAssets::ensure_valid_user
    @valid_user_id = @user[:id]

    @posts = PostAssets::ensure_valid_posts(@valid_user_id)
  end

  describe "navigation methods," do
    describe "GET get_next_five_posts(/:id)" do
      it "returns 5 latest posts if no argument is given" do
        get "/get_next_five_posts"
        raw_data = JSON.parse(response.body)["posts"]
        posts = JSON.parse(raw_data, symbolize_names: true)
        
        expect(posts.length).to eq(5)
        expect(posts[0][:title]).to eq(@posts.last[:title])
      end

      it "returns posts in descending order" do
        get "/get_next_five_posts"
        raw_data = JSON.parse(response.body)["posts"]
        posts = JSON.parse(raw_data, symbolize_names: true)

        is_descending = true
        posts.drop(1).each_with_index { |p, i| is_descending = posts[i][:id] < posts[i - 1][:id] }

        expect(is_descending).to be true  
      end
    end
  end
end