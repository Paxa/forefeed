helpers do
  # replace each file with it's Dir.glob
  def populate_paths paths, location
    paths.map do |path| 
      if path[0, 1] == '/'
        Dir.glob(File.join(location, path)).map {|f| f[location.size, f.size - location.size] }
      else
        path
      end
    end.flatten
  end
  
  def javascripts *paths
    capture_haml do
      for path in populate_paths(paths, 'public')
        haml_tag :script, {:type => 'text/javascript', :src => path }
      end
    end
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
  res = connection.get 'http://www.google.com/reader/api/0/subscription/list'
  if res.is_a? Net::HTTPUnauthorized
    false
  else
    res
  end
end