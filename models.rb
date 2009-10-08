require 'datamapper'

DataMapper::setup(:default, ENV['DATABASE_URL'] || "postgres://root:123@localhost/forefeed")


class Feed
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :url, Text, :length => (12..300)
  property :anounce, Text
  property :body, Text

end


class User
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :email, String
  property :oauth_token, String
  property :oauth_secret, String

  def cookie_hash
    Digest::MD5.hexdigest "#{oauth_token}-#{oauth_secret}-#{email}ХУЙ"
  end
  
  def authorize
    session = $cont.session
    session[:user_id] = id
    $cont.set_cookie 'auth_id', id
    $cont.set_cookie 'auth_hash', cookie_hash
  end

  def self.current

  end
end

class Feeds_user
  include DataMapper::Resource
  property :id, Serial
  property :user_id, Integer, :key => true
  property :feed_id, Integer, :key => true
  property :created_at, DateTime

  before :create do
    created_at = DateTime.now
  end

end

DataMapper.auto_upgrade!


class Feeds_user
  belongs_to :user, :child_key => [:user_id]
  belongs_to :feed, :child_key => [:feed_id]
end


class User
  has n, :Feeds_users
end


class Feed
  has n, :Feeds_users
end
