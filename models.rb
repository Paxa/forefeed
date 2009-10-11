require 'datamapper'

DataMapper::setup(:default, ENV['DATABASE_URL'] || "postgres://root:123@localhost/forefeed")


class Feed
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :url, Text, :length => (12..300)
  property :last_load, DateTime
end


class User
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :email, String
  property :oauth_token, String
  property :oauth_secret, String
end

class Feeds_user
  include DataMapper::Resource
  property :id, Serial
  property :user_id, Integer, :key => true
  property :feed_id, Integer, :key => true
  property :created_at, DateTime
end

class Posts_user
  include DataMapper::Resource
  property :id, Serial
  property :user_id, Integer, :key => true
  property :post_id, Integer, :key => true
  property :created_at, DateTime
end

class Post
  include DataMapper::Resource
  property :id, Serial
  property :feed_id, Integer, :key => true
  property :title, Text, :length => (2..300)
  property :content, Text
  property :short, Text
  property :pub_date, DateTime
end

DataMapper.auto_upgrade!



class Feed
  has n, :feeds_users
  has n, :posts

  def load_posts
    uri_params = {:q => url, :v => '1.0', :num => 35, :scoring => 'h'}.to_url_params
    uri = URI.parse "http://ajax.googleapis.com/ajax/services/feed/load?#{uri_params}"
    data = uri.read "Referer" => "http://www.ruby-lang.org/"
    data.gsub! "\t", "  "
    posts = JSON.parse(data)['responseData']['feed']['entries']

    posts.each do |post_info|
      if post_info['publishedDate'].blank?
        date = DateTime.now
      else
        date = DateTime.parse post_info['publishedDate']
      end

      Post.new :feed_id => id, :title => post_info['title'], :short => post_info['contentSnippet'], :content => post_info['content'], :pub_date => date

      #post.errors.each {|e| p e} if !post.save
    end

    self.title = JSON.parse(data)['responseData']['feed']['title']
    self.last_load = DateTime.now
    save

    posts.size
  end
end


class Post
   belongs_to :feed
end

class User
  has n, :Feeds_users
  has n, :Posts_users

  class << self; attr_accessor :current_user; end

  def cookie_hash
    Digest::MD5.hexdigest "#{oauth_token}-#{oauth_secret}-#{email}ХУЙ"
  end

  def self.current
    if self.current_user
      return self.current_user
    else
      cookies = $cont.request.cookies
      if cookies['auth_id'] && cookies['auth_hash']
        user = get(cookies['auth_id'].to_i)
        if user && user.cookie_hash == cookies['auth_hash']
          self.current_user = user
          return user
        end
      end
      nil
    end
  end

  def authorize
    session = $cont.session
    session[:user_id] = id
    $cont.response.set_cookie "auth_id", { :value => id, :expires => Time.now + 100 * 3600 * 24 }
    $cont.response.set_cookie "auth_hash", { :value => cookie_hash, :expires => Time.now + 100 * 3600 * 24 }
    self.class.current_user = self
  end

  def self.store_feed feed
    feed_id = feed.class == Feed ? feed.id : feed.to_i
    Feeds_user.create :feed_id => feed_id, :user_id => (current ? current.id : 0)
  end

  def self.store_post post
    post_id = post.class == Post ? post.id : post.to_i
    Posts_user.create :post_id => post_id, :user_id => (current ? current.id : 0)
  end

  def feed_stat
    DataMapper.repository(:default).adapter.query('
      SELECT feeds.*,
        (select count(*) FROM feeds_users fu2 where fu2.user_id = fu.user_id and fu2.feed_id = fu.feed_id ) as count
      from feeds_users fu, feeds
      WHERE user_id = ? and feeds.id = fu.feed_id
      group by feed_id, feeds.id, feeds.title, feeds.url, fu.user_id, feeds.last_load order by count desc', id)
  end
end

class Feeds_user
  belongs_to :user, :child_key => [:user_id]
  belongs_to :feed, :child_key => [:feed_id]

  before :create do
    created_at = DateTime.now
  end
end


class Posts_user
  belongs_to :user, :child_key => [:user_id]
  belongs_to :post, :child_key => [:post_id]

  before :create do
    created_at = DateTime.now
  end
end