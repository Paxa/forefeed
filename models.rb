require 'datamapper'

DataMapper::setup(:default, ENV['DATABASE_URL'] || "mysql://root:123@localhost/forefeed")


class Feed
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :url, Text
  property :views, DateTime
end


class User
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :email, String
  property :oauth_token, String
  property :oauth_secret, String
end

# automatically create the post table
Feed.auto_migrate!
User.auto_migrate!