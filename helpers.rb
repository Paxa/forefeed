helpers do
  def domain(tld_length = 1)
    'localhost:4567'
  end

  def asset_url(path, tld_length = 1)
    '/' + path
  end
  
  def javascript url
    {:type => 'text/javascript', :src => url}
  end
  
  def css url
    {:type => 'text/css', :href => url, :media => 'screen', :rel => 'stylesheet'}
  end
end


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

def at_for user
  OAuth::AccessToken.new $con, user.oauth_token, user.oauth_secret
end

def get_feeds connection
  connection.get 'http://www.google.com/reader/api/0/subscription/list'
end