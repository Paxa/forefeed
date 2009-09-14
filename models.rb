require 'datamapper'

DataMapper::setup(:default, ENV['DATABASE_URL'] || "mysql://root:123@localhost/forefeed")


class Feed
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :url, Text, :length => (12..300)
  has n, :Feeds_users

end


class User
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :email, String
  property :oauth_token, String
  property :oauth_secret, String

  has n, :Feeds_users
  def cookie_hash
    Digest::MD5.hexdigest "#{oauth_token}-#{oauth_secret}-#{email}ХУЙ"
  end
  
  def authorize
    session = $cont.session
    session[:user_id] = id
    $cont.response.set_cookie "auth_id", { :value => id, :expires => Time.now + 100 * 3600 * 24 }
    $cont.response.set_cookie "auth_hash", { :value => cookie_hash, :expires => Time.now + 100 * 3600 * 24 }
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

  belongs_to :user, :child_key => [:user_id]
  belongs_to :feed, :child_key => [:feed_id]
end

DataMapper::AutoMigrator.auto_upgrade