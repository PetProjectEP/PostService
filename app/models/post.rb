class Post < ApplicationRecord
  belongs_to :user

  validates_length_of :title, in: 1..64, message: "The title must be between 1 and 64 characters long"
  validates_length_of :text, within: 1..2048, message: "The post must be between 1 and 2048 characters long"
end
