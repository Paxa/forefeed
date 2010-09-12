var Menu = {
  home: function(){
    Layout.setContent(Index.main);
  },
  
  getFeeds: function(attribute){
    console.log('get_feeds');
  },
  
  langSelect: function(attribute){
    console.log('lang select');
  },
  
  keyHelp: function(attribute){
    console.log('key help');
  },
  
  feedList: function(attribute){
    console.log('feed list');
  }
};