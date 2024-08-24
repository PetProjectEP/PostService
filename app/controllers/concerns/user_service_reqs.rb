module UserServiceReqs
  extend ActiveSupport::Concern
  require "http" 

  GET_USER_BY_SESSION_URL = "http://localhost:3000/sessions/"

  public
  included do
    def get_user_by_session(token)
      response = HTTP.get(GET_USER_BY_SESSION_URL + token)

      # 0-idx here because of how HTTP-gem parser works
      return eval(response.body.to_a[0]) 
    end    
  end
end