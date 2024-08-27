class PostsController < ApplicationController
  include UserServiceReqs
  before_action :set_post, only: %i[ show update destroy ]

  # GET /posts
  def index
    @posts = Post.all

    render json: @posts.to_json(only: %i[title text])
  end

  # GET /posts/1
  def show
    render json: @post
  end

  # POST /posts
  def create
    @user_id = get_user_by_session(post_params[:token])

    unless @user_id
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
    if @post.update(post_params)
      render json: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  def destroy
    @post.destroy!
  end

  private
    def set_post
      @post = Post.find(params[:id])
    end

    def post_params
      params.require(:post).permit(:title, :text, :token)
    end
end
