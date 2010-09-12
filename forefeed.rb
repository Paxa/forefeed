app_env ||= :development

require 'rubygems'
require 'sinatra'
require 'haml'
require 'json'
require 'oauth'
require 'helpers'

set :sessions, true
set :logging, true
set :dump_errors, true
set :public, File.join(File.dirname(__FILE__), 'public')
set :environment, app_env
enable :sessions

# временно
Store.clients << {}

before do
  $client = Store.clients.last
  $client[:connection] = OAuth::AccessToken.new Store.consumer, 
    session[:ac_token], session[:ac_secret]
end

get '/' do
  haml :index
end

get '/feeds' do
  content_type :json  
  if @feeds = get_feeds($client[:connection])
    @feeds
  else
    $client[:rt] = Store.consumer.get_request_token({:oauth_callback => "http://localhost:4567/oauth_get"}, 
      {:scope => 'http://www.google.com/reader/api/0/subscription/list'})
    {:error => 400, :redirect_to => $client[:rt].authorize_url}
  end
end

get '/oauth_get' do 
  $client[:at] = $client[:rt].get_access_token(:oauth_verifier => params[:oauth_verifier])
  
  #data = at.get("http://www.google.com/reader/api/0/subscription/list").body
  
  session[:ac_token]  = $client[:at].token
  session[:ac_secret] = $client[:at].secret
  redirect '/'
end

get '/application.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
  sass :application
end