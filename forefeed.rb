app_env ||= :development

require 'rubygems'
require 'sinatra'
require 'sinatra-helpers'
require 'helpers'
require 'models'
require 'haml'
require 'oauth'

set :sessions, true
set :logging, true
set :dump_errors, true
set :public, File.join(File.dirname(__FILE__), 'public')
set :environment, app_env

google_key ||= 'ABQIAAAAHzDsf62yQb-dc6oxj8T3ZRSmbtbI58sJnUq1AueY0BvTVoVv3BS2gClpGsuN2juf8fL55w8oRKfwgw'

get '/' do
  @google_key = google_key
  haml :index
end

get '/login' do
  @consumer=OAuth::Consumer.new( "forefeed.heroku.com"," 	aWzRgfbuew+WVoQdnoZyuqHv", {
      :site=>"https://www.google.com"
  })
  @request_token=@consumer.get_request_token
  session[:request_token] = @request_token
  redirect @request_token.authorize_url
end

