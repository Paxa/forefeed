require 'sinatra'
require 'spec/interop/test'
require 'sinatra/test/unit'

describe 'Hello World' do

  specify "should render hello at /" do
    get_it '/'
    @response.should be_ok
  end

end