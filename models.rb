require 'datamapper'
DataMapper::setup(:default, "mysql://root:123@localhost/forefeed")

class Feed
    include DataMapper::Resource
    property :id, Serial
    property :title, String
    property :url, Text
    property :views, DateTime
end

# automatically create the post table
Feed.auto_migrate!