class PostsController < ApplicationController
  include UserServiceReqs
  before_action :get_user_id
  before_action :set_post, only: %i[ show update destroy ]

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
    unless @user_id.nil?
      @post = Post.new({ title: post_params[:title], text: post_params[:text], user_id: @user_id })              
      
      if @post.save
        render json: @post, status: :created, location: @post
      else
        render json: @post.errors, status: :unprocessable_entity
      end
    else
      render json: { error: "User service error" }, status: :service_unavailable
    end   
  end

  # PATCH/PUT /posts/1
  def update
    unless @user_id != @post[:user_id]
      @post.update(title: post_params[:title], text: post_params[:text])
      render json: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  def destroy
    unless @user_id != @post[:user_id]
      @post.destroy!
    end
  end

  private
    def post_params
      params.permit(:title, :text, :id)
    end

    def navigation_params
      params.permit(:id)
    end

    def get_user_id
      # I want token param to be nowhere else but in this method
      token = params.extract!(:token)[:token]
      return nil if token.nil? || token == "null" || token.empty?

      @user_id = get_user_by_session(token)[:id]
    end

    def set_post
      @post = Post.find(post_params[:id])
    end
end
