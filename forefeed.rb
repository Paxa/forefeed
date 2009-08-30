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
  @google_key = google_key
  haml :index
end

get '/login' do
  if try_auth
    redirect '/'
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
