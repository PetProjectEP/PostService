module UserValidations
  extend ActiveSupport::Concern

  included do
    def verify_user_presence
      if @user_id.nil?
        render json: { error: "No user!" }, status: :unauthorized
        return false
      end
      return true
    end

    def verify_post_owner
      if @user_id != @post[:user_id]
        render json: { error: "Passed user can't modify this post!"}, status: :forbidden
        return false
      end
      return true
    end  
  end
end