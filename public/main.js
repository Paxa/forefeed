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
  feed.setNumEntries(25);
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
  var text = getSelText() + '';
  if (text.trim().length < 2) {
    $$('.suggest').destroy();
  } else {
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



function getSelText()
{
   var wnd = (window.name=='send_frame')?parent:window;
  var sel_text = null;
  if(wnd.getSelection) err_text=wnd.getSelection();
  else
    if(wnd.document.getSelection) err_text=wnd.document.getSelection();
    else sel_text = wnd.document.selection;

  if(sel_text) {
    err_text = sel_text.createRange().text;
    var b_text= sel_text.createRange();
    var a_text= sel_text.createRange();
    sel_text = err_text;
    b_text.moveStart("word",-10);
    b_text.moveEnd("character",-err_text.length);
    a_text.moveStart("character",err_text.length);
    a_text.moveEnd("word",10);
    sel_text = b_text.text+' ##'+err_text+'## '+a_text.text;
  }
  else {
    if (window.document.body != undefined) {
      if (wnd.document.body.innerText != undefined)
        sel_text=wnd.document.body.innerText;
      else
        sel_text=wnd.document.body.innerHTML;

      var nn=sel_text.indexOf(err_text);
      if (nn != -1){
        var tmp_str=err_text+"";
        sel_text = sel_text.substring(nn-70, nn)+' ##'+err_text+'## '+sel_text.substring(nn+tmp_str.length, nn+tmp_str.length+70);
      }
      else sel_text ;// = ' ##'+err_text+'## ';
    }
    else sel_text = ' ##'+err_text+'## ';
  }

  return err_text;
}