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

set :environment, app_env

get '/' do
  haml :index
end
