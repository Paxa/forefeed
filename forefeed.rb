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

get '/' do
  @google_key = google_key
  haml :index
end

get '/login' do
  cookies = request.cookies
  if cookies['user_id'] && cookies['auth_hash']
    user = User.get(cookies['user_id'])
    if user.cookie_hash == cookie['auth_hash']
      session['user_id'] == user.id
    end
  else
    $rt = $con.get_request_token({:oauth_callback => "http://localhost:4567/oauth_get"}, {:scope => 'https://www.google.com/m8/feeds/'})
    redirect $rt.authorize_url
  end
end

get '/oauth_get' do 
  cookies = request.cookies
  at = $rt.get_access_token(:oauth_verifier => params[:oauth_verifier])
  data = at.get("https://www.google.com/m8/feeds/contacts/default/full/").body
  xml = Hpricot::XML data
  author = xml/:author
  
  user = User.new(
    :name => (author/:name)[0].innerHTML, 
    :email => (author/:email)[0].innerHTML, 
    :oauth_token => at.token,
    :oauth_secret => at.secret
  )
  
  if user.save
    session[:user_id] = user.id
    set_cookie 'auth_id', user.id
    set_cookie 'auth_hash', user.cookie_hash
  end
  
  redirect '/'
end

def at_for user
  OAuth::AccessToken.new $con, user.oauth_token, user.oauth_secret
end

def current_user
  @@_current_user || User.get(session[:user_id])
end