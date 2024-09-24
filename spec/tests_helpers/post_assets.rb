module PostAssets
  def self.ensure_valid_posts(user_id, count: 12)
    posts = Array.new(count) do |i|
      post = Post.find_by("title = ?", "Title #{i}")
      post ||= Post.create({ title: "Title #{i}", text: "Text #{i}", user_id: user_id })
      post
    end
  end
end