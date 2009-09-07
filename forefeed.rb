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
require 'oauthbox'

set :sessions, true
set :logging, true
set :dump_errors, true
set :public, File.join(File.dirname(__FILE__), 'public')
set :environment, app_env
enable :sessions

google_key ||= 'ABQIAAAAHzDsf62yQb-dc6oxj8T3ZRSmbtbI58sJnUq1AueY0BvTVoVv3BS2gClpGsuN2juf8fL55w8oRKfwgw'

before do
  $cont = self
  $user = nil
  @google_key = google_key
end

get '/' do
  haml :index
end

get '/login' do
  if try_auth
    redirect '/'
  else
    @rt = OauthBox.get_rt_for 'google', '/oauth_get'
    session['rt_num'] = OauthBox.store_rt @rt
    redirect @rt.authorize_url
  end
end

get '/oauth_get' do
  rt = OauthBox.retrive_rt session['rt_num']
  at = rt.get_access_token(:oauth_verifier => params[:oauth_verifier])
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
      (select count(*) FROM feeds_users fu2 where fu2.user_id = fu.user_id and fu2.feed_id = fu.feed_id ) as count
    from feeds_users fu, feeds WHERE user_id = ? and feeds.id = fu.feed_id group by feed_id, feeds.id, feeds.title, feeds.url, fu.user_id order by count desc', params[:id])
  haml :user
end