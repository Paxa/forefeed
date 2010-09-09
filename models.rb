require 'datamapper'

DataMapper::setup(:default, ENV['DATABASE_URL'] || "mysql://root:123@localhost/forefeed")

class User
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :email, String
  property :oauth_token, String
  property :oauth_secret, String
  
  def cookie_hash
    Digest::MD5.hexdigest "#{oauth_token}-#{oauth_secret}-#{email}ХУЙ"
  end
  
  def authorize
    session = $cont.session
    session[:user_id] = id
    $cont.set_cookie 'auth_id', id
    $cont.set_cookie 'auth_hash', cookie_hash
  end
end

DataMapper::AutoMigrator.auto_upgrade