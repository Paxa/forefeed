google.load("feeds", "1");
google.load("language", "1");

window.addEvent('domready', function () {
  $('feed_name').addEvent('keyup', function (e) {
    if (e.key == 'enter') {
      load_feed(e.target.value);
    }
  });

  $('feed_name').addEvent('focus', function () {
    if ($('feed_name').value == 'paste feed url here') {
      $('feed_name').value = '';
    }
  })

  $('content').addEvent('click', function () {
    var text = getSelText() + '';
    if (text.trim().length < 2) {
      $$('.suggest').destroy();
    }
  });
  
  $('right_col').addEvent('mouseup', on_mouseup);

  $('post_toggle').addEvent('click', function () {
    if ($('post_list').shown == true) {
      hide_posts();
    } else {
      show_posts();
    }
  });
  $('post_list').set('tween', {duration: 400, transition: Fx.Transitions.Circ.easeOut});


});


var current_feed = {};

function load_feed (url) {
  var feed = new google.feeds.Feed(url);
  feed.setNumEntries(35);
  feed.load(function(result) {
    if (!result.error) {
      $('posts').empty();
      current_feed = result;
      result.feed.entries.each(function (entry, num) {
        var date = new Date(entry.publishedDate);
        var date_title = date.format('%b %d');
        var li = new Element('li', {events: {
          click: function () {show_post(num)}
        }}).inject($('posts'));
        new Element('span', {'class': 'post-date', text: date_title}).inject(li);
        new Element('span', {'class': 'post-title', text: entry.title}).inject(li);
      })
      show_posts();
    }
  });
}

function on_mouseup (e) {
  $$('.suggest').destroy();
  var text = getSelText() + '';
  if (text.trim().length > 1) {
    make_tr_button(e, text);
  }
}

function show_post(num) {
  hide_posts();
  $$('.suggest').destroy();
  $('right_col').set('html', current_feed.feed.entries[num].content);
  $('current_title').set('html', current_feed.feed.entries[num].title);
}

function hide_posts() {
  $('post_list').tween('height', 19);
  $('post_list').shown = false;
}

function show_posts() {
  $('post_list').tween('height', $('posts').getStyle('height').toInt() + 6);
  $('post_list').shown = true;
}


function make_tr_button(e, text) {
  var box = new Element('div', {'class': 'tr_btn suggest'}).inject(document.body);
  new Element('a', {text: 'x', 'class': 'del-tr', events: {
      click: box.destroy.bind(box)
  }}).inject(box);
  var textbox = new Element('span', {text: 'Перевести'}).inject(box);

  box.setStyle('top', e.page.y.toInt() - 25);
  box.setStyle('left', e.page.x.toInt());

  textbox.addEvent('click', function () {
    box.removeClass('suggest');
    textbox.set('text', 'перевожу...');
    textbox.removeEvents('click');
    google.language.translate(text, 'en', 'ru', function(result) {
      textbox.set('text', result.translation);
    });
  });

}


