class PostsController < ApplicationController
  include UserServiceReqs
  include UserValidations

  before_action :get_user_id
  before_action :set_post, only: %i[ show update destroy ]
  before_action :verify_user_presence, only: %i[ create update destroy ]
  before_action :verify_post_owner, only: %i[ update destroy ]

  def list
    limit = [Integer(navigation_params[:limit]), 50].min # Hard capping output posts number
    starting_id = navigation_params[:starting_id] ? navigation_params[:starting_id] : Post.last[:id]

    newer_posts = Post.where("id > ?", starting_id).order(id: :asc).limit(limit)
    newer_page_id = newer_posts.empty? ? nil : newer_posts.last[:id]

    posts = Post.where("id <= ?", starting_id).order(id: :desc).limit(limit + 1).to_a

    # If we grabbed one more post then there is next page to display from it
    older_page_id = posts.length == limit + 1 ? posts.pop[:id] : nil

    render json: { 
      posts: posts.to_json,
      newer_page_id: newer_page_id,
      older_page_id: older_page_id 
    }
  end

  def get_next_five_posts
    count = 5
    
    starting_index = navigation_params[:id] ? navigation_params[:id] : Post.last[:id]
    
    if @user_id.nil?
      @posts = Post.where("id <= ?", starting_index).order(id: :desc).limit(count)
      @have_more = @posts.empty? ? false : Post.exists?(["id < ?", @posts.last.id])
    else
      @posts = Post.where("id <= ? && user_id = ?", starting_index, @user_id).order(id: :desc).limit(count)
      @have_more = @posts.empty? ? false : Post.exists?(["id < ? && user_id = ?", @posts.last.id, @user_id])
    end

    render json: {posts: @posts.to_json, haveMore: @have_more}
  end

  def get_prev_five_posts
    count = 5

    starting_index = navigation_params[:id]
    
    if @user_id.nil?
      # Cant use .limit cause it will cut result after sorting returning TOP posts, not BOTTOM as needed
      @posts = Post.where("id >= ?", starting_index).order(id: :desc).last(count)
      @have_more = @posts.empty? ? false : Post.exists?(["id > ?", @posts[0]])
    else
      @posts = Post.where("id >= ? && user_id = ?", starting_index, @user_id).order(id: :desc).last(count)
      @have_more = @posts.empty? ? false : Post.exists?(["id > ? && user_id = ?", @posts[0], @user_id])
    end

    render json: {posts: @posts.to_json, haveMore: @have_more}
  end

  # GET /posts/1
  def show
    render json: @post
  end

  # POST /posts
  def create
    post = Post.new({
      title: post_params[:title],
      text: post_params[:text],
      user_id: @user_id
    })

    if post.save
      render json: post, status: :created
    else
      render json: post.errors, status: :unprocessable_entity
    end 
  end

  # PATCH/PUT /posts/1
  def update
    if @post.update(title: post_params[:title], text: post_params[:text])
      render json: @post, status: :ok
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  def destroy
    if @post.destroy
      render json: {}, status: :ok
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  private
    def get_user_id
      # I want token param to be nowhere else but in this method
      token = params.extract!(:token)[:token]
      return nil if token.nil? || token == "null" || token.empty?

      @user_id = get_user_by_session(token)[:id]
    end

    def post_params
      params.permit(:title, :text, :id)
    end

    def navigation_params
      params.permit(:starting_id, :limit)
    end

    def set_post
      @post = Post.find(post_params[:id])
    end
end
