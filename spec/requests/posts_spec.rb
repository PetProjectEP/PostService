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
    describe "GET list" do
      it "returns latest posts if no starting id is given" do
        limit = 5
        get "/posts/list", params: { limit: limit }

        raw_posts = JSON.parse(response.body)["posts"]
        posts = JSON.parse(raw_posts, symbolize_names: true)

        newer_page_id = JSON.parse(response.body)["newer_page_id"]
        older_page_id = JSON.parse(response.body)["older_page_id"]

        expect(posts.length).to eq(limit)
        expect(posts[0][:id]).to eq(@posts.last[:id])
        expect(posts.last[:id]).to eq(@posts[-limit][:id])
        expect(newer_page_id).to be_nil
        expect(older_page_id).to eq(posts.last[:id] - 1)
      end

      it "returns posts from given starting point" do
        limit, offset = 5, 5
        starting_id = @posts.last[:id] - offset
        starting_arr_idx = @posts.index { |p| p[:id] == starting_id }

        get "/posts/list", params: { limit: limit, starting_id: starting_id }

        raw_posts = JSON.parse(response.body)["posts"]
        posts = JSON.parse(raw_posts, symbolize_names: true)

        newer_page_id = JSON.parse(response.body)["newer_page_id"]
        older_page_id = JSON.parse(response.body)["older_page_id"]
        
        expect(posts.length).to eq(limit)
        expect(posts[0][:id]).to eq(@posts[starting_arr_idx][:id])
        expect(posts.last[:id]).to eq(@posts[starting_arr_idx - limit + 1][:id])
        expect(newer_page_id).to eq([posts[0][:id] + limit, @posts.last[:id]].min)
        expect(older_page_id).to eq(posts.last[:id] - 1)
      end

      it "returns posts even if there are less posts than required" do
        limit = 30

        get "/posts/list", params: { limit: limit }

        raw_posts = JSON.parse(response.body)["posts"]
        posts = JSON.parse(raw_posts, symbolize_names: true)

        newer_page_id = JSON.parse(response.body)["newer_page_id"]
        older_page_id = JSON.parse(response.body)["older_page_id"]
        
        expect(posts.length).to eq(@posts.length)
        expect(posts[0][:id]).to eq(@posts.last[:id])
        expect(posts.last[:id]).to eq(@posts[0][:id])
        expect(newer_page_id).to be_nil
        expect(older_page_id).to be_nil
      end
    end
  end
end
