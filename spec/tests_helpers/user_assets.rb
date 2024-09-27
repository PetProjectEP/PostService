module UserAssets
  def self.ensure_valid_user(
    nickname: "Nickname",                                
    name: "John",
    surname: "Doe",
    password: "qwerty123",
    password_confirmation: "qwerty123"
  )
    user = User.find_by(nickname: "Nickname")
    user ||= User.create(user_params)
    return user
  end
end