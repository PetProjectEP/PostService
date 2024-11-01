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

    # Probably will need some query builder
    if @user_id.nil?
      newer_posts = Post.where("id > ?", starting_id).order(id: :asc).limit(limit)
      posts = Post.where("id <= ?", starting_id).order(id: :desc).limit(limit + 1).to_a
    else
      newer_posts = Post.where("id > ? AND user_id = ?", starting_id, @user_id).order(id: :asc).limit(limit)
      posts = Post.where("id <= ? AND user_id = ?", starting_id, @user_id).order(id: :desc).limit(limit + 1).to_a
    end
    
    newer_page_id = newer_posts.empty? ? nil : newer_posts.last[:id]
    older_page_id = posts.length == limit + 1 ? posts.pop[:id] : nil  # If we grabbed one more post then there is next page to display from it

    render json: { 
      posts: posts.to_json,
      newer_page_id: newer_page_id,
      older_page_id: older_page_id 
    }
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
