require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe User do

  before :each do
    @user = User.new(
      :name => 'belka',
      :email => 'belka@gmail.com',
      :oauth_token => 'asdasda',
      :oauth_secret => '23d23'
    )
    @user.save
    get '/'
  end

  it 'authorize selected user' do
    @user.authorize
    User.current.id.should == @user.id
  end
end