require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe User do

  before :each do
    User.all.each { |u| u.destroy }
    @user = User.new(
      :name => 'belka',
      :email => 'belka@gmail.com',
      :oauth_token => 'asdasda',
      :oauth_secret => '23d23'
    )
    @user.save
    get '/'
  end

  it 'should authorize selected user' do
    @user.authorize
    User.current.id.should == @user.id
  end

  it 'should store feed opening by existen user' do
    @feed = Feed.create :url => 'http://example.com', :title => 'example.com'
    @user.authorize
    User.store_feed @feed
    @user.feed_stat[0].nil?.should == false
    @user.feed_stat[0].id.should == @feed.id
    @user.feed_stat[0].count.should == 1
  end

  it 'should store post openint' do
    @feed = Feed.create :url => 'http://example.com', :title => 'example.com'
    @post = Post.new :feed_id => @feed.id, :title => 'hello', :short => 'hello world', :content => 'hello world', :pub_date => DateTime.now

    User.store_post @post
  end
end
