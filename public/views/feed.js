var Feed = {
  onLoadClk: function(e) {
    var url = $('feed_url').value;
    url = this.formatUrl(url);
    $('feed_url').value = url;
    this.laod(url);
  },
  
  laod: function(url){
    console.log('loading feed:', url);
  },
  
  formatUrl: function(url){
    url = url.clean();
    if (!url.match(/^https?:\/\//)) {
      url = 'http://' + url;
    }
    return url;
  }
};