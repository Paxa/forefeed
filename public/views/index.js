var Index = {
  main: function(){
    return ['.index_page',
      ['.feed_input',
        ['%p', 'Input rss feed name'],
        ['%input#feed_url'],
        ['%a', {clk: Feed.onLoadClk.bind(Feed)}, 'Load']
      ],
      
      ['.load_from_reader',
        ['%a', 'Load from google reader']
      ]
    ];
  }
};