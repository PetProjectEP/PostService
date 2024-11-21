module UserServiceReqs
  extend ActiveSupport::Concern

  require "http"

  USER_SERVICE_URL = ENV['USER_SERVICE_URL']
  SESSIONS_PATH = ENV['USER_SERVICE_SESSIONS_PATH']
  
  included do
    def get_user_by_session(token)
      response = HTTP.get(USER_SERVICE_URL + SESSIONS_PATH + '/' + token)

      # 0-idx is here because of how HTTP-gem parser works
      return eval(response.body.to_a[0]) 
    end    
  end
end