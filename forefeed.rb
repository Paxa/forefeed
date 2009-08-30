app_env ||= :development

require 'rubygems'
require 'sinatra'
require 'sinatra-helpers'
require 'helpers'
require 'models'
require 'haml'
require 'hpricot'
require 'oauth'
require 'json'
require 'digest/md5'

set :sessions, true
set :logging, true
set :dump_errors, true
set :public, File.join(File.dirname(__FILE__), 'public')
set :environment, app_env

google_key ||= 'ABQIAAAAHzDsf62yQb-dc6oxj8T3ZRSmbtbI58sJnUq1AueY0BvTVoVv3BS2gClpGsuN2juf8fL55w8oRKfwgw'

$con = OAuth::Consumer.new("forefeed.heroku.com", "aWzRgfbuew+WVoQdnoZyuqHv",
   {:site => 'https://www.google.com',
    :request_token_path => '/accounts/OAuthGetRequestToken',
    :access_token_path => '/accounts/OAuthGetAccessToken',
    :authorize_path => '/accounts/OAuthAuthorizeToken'})

before do
  $cont = self
  $user = nil
end

get '/' do
  p request
  @google_key = google_key
  haml :index
end

get '/login' do
  if try_auth
    redirect '/'
  else
    $rt = $con.get_request_token({:oauth_callback => "http://#{request.env['HTTP_HOST']}/oauth_get"}, {:scope => 'https://www.google.com/m8/feeds/'})
    redirect $rt.authorize_url
  end
end

get '/oauth_get' do 
  at = $rt.get_access_token(:oauth_verifier => params[:oauth_verifier])
  data = at.get("https://www.google.com/m8/feeds/contacts/default/full/").body
  xml = Hpricot::XML data
  author = xml/:author
  
  user = User.first :email => (author/:email)[0].innerHTML
  
  if user
    user.authorize
  else
    new_user = User.new(
      :name => (author/:name)[0].innerHTML, 
      :email => (author/:email)[0].innerHTML, 
      :oauth_token => at.token,
      :oauth_secret => at.secret
    )
  
    if new_user.save
      new_user.authorize
    end
  end
  redirect '/'
end

get '/store_feed' do
  user = try_auth
  feed = Feed.first :url => params[:url].strip
  if !feed
    feed = Feed.create :url => params[:url].strip, :title => params[:title]
  end

  fu = Feeds_user.new :feed_id => feed.id, :user_id => (user ? user.id : 0)
  fu.save

  content_type :json
  {:status => 'ok'}.to_json
end

get '/user/:id' do
  @user = User.get params[:id]
  @feeds = DataMapper.repository(:default).adapter.query('
    SELECT feeds.*,
      (select count(*) FROM feeds_users fu2 where fu2.user_id = fu.user_id and fu2.feed_id = fu.feed_id) as count 
    from feeds_users fu, feeds WHERE user_id = ? and feeds.id = fu.feed_id group by feed_id, feeds.id order by count desc', params[:id])
  haml :user
end