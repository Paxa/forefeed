module Sinatra
  module Helpers
    module Haml
      module Links
        def domain(tld_length = 1)
          'localhost:4567'
        end

        def asset_url(path, tld_length = 1)
          '/' + path
        end
      end
    end
  end
end


def md5 str
  Digest::MD5.hexdigest str
end

def at_for user
  OAuth::AccessToken.new $con, user.oauth_token, user.oauth_secret
end

class Hash
  def to_url_params
    elements = []
    keys.size.times do |i|
      elements << "#{CGI::escape(keys[i].to_s)}=#{CGI::escape(values[i].to_s)}"
    end
    elements.join('&')
  end
end

#def current_user
#  $user || try_auth
#end
#
#def try_auth
#  cookies = request.cookies
#  if cookies['auth_id'] && cookies['auth_hash']
#    user = User.get(cookies['auth_id'].to_i)
#    if user && user.cookie_hash == cookies['auth_hash']
#      $user = user
#      return user
#    end
#  end
#  return nil
#end