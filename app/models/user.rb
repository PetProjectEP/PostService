class User < ApplicationRecord
  has_many :sessions
  
  validates_length_of :nickname, in: 6..32, message: "The nickname must be between 6 and 32 characters long"
  validates_uniqueness_of :nickname, on: :create, message: "This nickname is already taken"

  has_secure_password validations: false
  validates_length_of :password, in: 6..32, message: "The password must be between 6 and 32 characters long"
  validates_confirmation_of :password, message: "Password should match confirmation"

  validates_length_of :name, within: 1..32, message: "The name must be between 1 and 32 characters long"
  validates_length_of :surname, within: 1..32, message: "The surname must be between 1 and 32 characters long"
end
