class OauthBox

  def self.get_rt_for oauth_provider, path
    case oauth_provider
    when 'google':
      self.google_consumer.get_request_token({:oauth_callback => "http://#{$cont.request.env['HTTP_HOST']}#{path}"},
        {:scope => 'https://www.google.com/m8/feeds/'})
    end
  end

  def self.google_consumer
    OAuth::Consumer.new("forefeed.heroku.com", "aWzRgfbuew+WVoQdnoZyuqHv",
     {:site => 'https://www.google.com',
      :request_token_path => '/accounts/OAuthGetRequestToken',
      :access_token_path => '/accounts/OAuthGetAccessToken',
      :authorize_path => '/accounts/OAuthAuthorizeToken'})
  end

  def self.retrive_rt num
    return @@request_tokens[num]
  end
  def self.store_rt rt
    @@request_tokens ||= []
    @@request_tokens << rt
    @@request_tokens.size - 1
  end

end
