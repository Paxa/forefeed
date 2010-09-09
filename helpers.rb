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


def md5 str
  Digest::MD5.hexdigest str
end

def at_for user
  OAuth::AccessToken.new $con, user.oauth_token, user.oauth_secret
end

def get_feeds connection
  connection.get 'http://www.google.com/reader/api/0/subscription/list'
end