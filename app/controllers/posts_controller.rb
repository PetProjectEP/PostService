class PostsController < ApplicationController
  include UserServiceReqs
  before_action :set_post, only: %i[ show update destroy ]

  def get_next_five_posts
    count = 5

    last_post_id = Post.last ? Post.last.id : -1
    starting_index = get_posts_params[:id] ? get_posts_params[:id] : last_post_id
    
    @posts = Post.where("id <= ?", starting_index).order(id: :desc).limit(count)
    @have_more = last_post_id == -1 ? false : Post.exists?(["id < ?", @posts.last.id])

    render json: {posts: @posts.to_json(only: %i[title text id]), haveMore: @have_more}
  end

  def get_prev_five_posts
    count = 5

    starting_index = get_posts_params[:id]
    
    @posts = Post.where("id >= ?", starting_index).order(id: :desc).limit(count)
    @have_more = Post.exists?(["id > ?", @posts[0]])

    render json: {posts: @posts.to_json(only: %i[title text id]), haveMore: @have_more}
  end

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
    @user_id = get_user_by_session(post_params[:token])[:id]

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

    def get_posts_params
      params.permit(:id)
    end
end
