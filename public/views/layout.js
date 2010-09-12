var Layout = {
  _container: function(){
    return ['.wrap',
      ['#menu', {bindAt: 'menuBox'},
        ['.home', {clk: Menu.home}],
        ['.get_feeds', {clk: Menu.getFeeds}],
        ['.lang_select', {clk: Menu.langSelect}],
        ['.key_help', {clk: Menu.keyHelp}]
      ],
      ['#sidebar'],
      ['#content', {bindAt: 'contentBox'}]
    ];
  },
  
  init: function(attribute){
    if (this.contentBox) return;
    this.render(this._container).inject(document.body);
  },
  
  setContent: function(content){
    var box = this.contentBox;
    [Haml.render(content())].flatten().each(function(el) {
      el.inject(box);
    });
    return this;
  }
};

$extend(Layout, HamlEngine);