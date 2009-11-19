app_env ||= :development

require 'rubygems'
require 'sinatra'
require 'sinatra-helpers'
require 'helpers'
require 'net/http'
require 'open-uri'
require 'haml'
require 'hpricot'
require 'oauth'
require 'json/ext'
require 'digest/md5'
require 'models'
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
  User.current_user = nil
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

get '/open_feed' do
  feed = Feed.first :url => params[:url].strip
  if !feed
    feed = Feed.create :url => params[:url].strip, :title => params[:title]
  end
  feed.load_posts

  User.store_feed feed

  content_type :json
  res = {:title => feed.title, :id => feed.id, :posts => []}
  feed.posts.all(:limit => 35).each do |post|
    res[:posts] << {:id => post.id, :title => post.title, :date => post.pub_date, :short => post.short}
  end
  res.to_json
end

get '/posts/:id' do
  post = post.get params[:id]
  User.store_post post

  content_type :json
  post.to_json
end

get '/user/:id' do
  @user = User.get params[:id]
  @feeds = @user.personal_stat
  haml :user
end