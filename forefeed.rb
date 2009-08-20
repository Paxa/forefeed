require 'rubygems'
require 'sinatra'
require 'sinatra-helpers'
require 'helpers'
require 'haml'


set :sessions, true
set :logging, true
set :dump_errors, true
set :public, File.join(File.dirname(__FILE__), 'public')

app_env ||= :development
google_key ||= 'ABQIAAAAHzDsf62yQb-dc6oxj8T3ZRSmbtbI58sJnUq1AueY0BvTVoVv3BS2gClpGsuN2juf8fL55w8oRKfwgw'
set :environment, app_env

get '/' do
  @google_key = google_key
  haml :index
end
