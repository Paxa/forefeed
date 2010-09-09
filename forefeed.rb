app_env ||= :development

require 'rubygems'
require 'sinatra'
require 'helpers'
require 'haml'
require 'oauth'

set :sessions, true
set :logging, true
set :dump_errors, true
set :public, File.join(File.dirname(__FILE__), 'public')
set :environment, app_env

class Store
  class << self
    attr_accessor :clients, :consumer, :google_key
  end
end

Store.clients = []
Store.consumer = OAuth::Consumer.new("forefeed.heroku.com", "aWzRgfbuew+WVoQdnoZyuqHv",
   {:site => 'https://www.google.com',
    :request_token_path => '/accounts/OAuthGetRequestToken',
    :access_token_path => '/accounts/OAuthGetAccessToken',
    :authorize_path => '/accounts/OAuthAuthorizeToken'})

Store.google_key ||= 'ABQIAAAAHzDsf62yQb-dc6oxj8T3ZRSmbtbI58sJnUq1AueY0BvTVoV' + 
  'v3BS2gClpGsuN2juf8fL55w8oRKfwgw'

# временно
Store.clients << {}

before do
  $client = Store.clients.last
  $client[:connection] = OAuth::AccessToken.new Store.consumer, 
    session[:ac_token], session[:ac_secret]
end
##

get '/' do
  if @feeds = get_feeds($client[:connection])
    @logged = true
    haml :index
  else  
    $client[:rt] = Store.consumer.get_request_token({:oauth_callback => "http://localhost:4567/oauth_get"}, 
      {:scope => 'http://www.google.com/reader/api/0/subscription/list'})
    redirect $client[:rt].authorize_url
  end
end

get '/oauth_get' do 
  $client[:at] = $client[:rt].get_access_token(:oauth_verifier => params[:oauth_verifier])
  
  #data = at.get("http://www.google.com/reader/api/0/subscription/list").body
  
  session[:ac_token]  = at.token
  session[:ac_secret] = at.secret
  redirect '/'
end
