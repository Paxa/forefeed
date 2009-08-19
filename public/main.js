google.load("feeds", "1");



var current_feed = {};

function load_feed (url) {
  var feed = new google.feeds.Feed(url);
  feed.setNumEntries(25);
  feed.load(function(result) {
    if (!result.error) {
      $('posts').empty();
      current_feed = result;
      result.feed.entries.each(function (entry, num) {
        new Element('li', {text: entry.title, events: {
          click: function () {show_post(num)}
        }}).inject($('posts'));
      })
      console.log(result);
    }
  });
}


function show_post(num) {
  $('right_col').set('html', current_feed.feed.entries[num].content);
}

window.addEvent('domready', function () {
  $('feed_name').addEvent('keyup', function (e) {
    if (e.key == 'enter') {
      load_feed(e.target.value);
    }
  })
});