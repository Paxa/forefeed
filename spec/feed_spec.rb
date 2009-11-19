require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Feed do
  it 'should load posts from google' do
    feed = Feed.create :url => 'http://feeds.feedburner.com/37signals/beMH', :title => '37test'
    feed.load_posts
    feed.posts.all.size.should >= 35
  end
end