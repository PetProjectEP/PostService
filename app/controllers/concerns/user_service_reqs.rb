module UserServiceReqs
  extend ActiveSupport::Concern

  require "http"
  require "yaml"

  SESSIONS_URL = YAML.load_file(Rails.root.join("config", "external_urls.yml"))["sessions_urls"]
  
  included do
    def get_user_by_session(token)
      response = HTTP.get(SESSIONS_URL + token)

      # 0-idx is here because of how HTTP-gem parser works
      return eval(response.body.to_a[0]) 
    end    
  end
end