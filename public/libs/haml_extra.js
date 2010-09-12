// provides 'render' and 'renderCollection' methods to be used for extended other object
// $extend(Page, HamlEngine);
var HamlEngine = {
  render: function(tpl, content){
    if (Haml.typeOf(tpl) == 'function') {
      return Haml.render(tpl.call(this, content), this);
    } else {
      return Haml.render(tpl, this);
    }
  },
  
  renderCollection: function(tpl, contents){
    res = [];
    for(c in contents) {
      if (!contens.hasOwnProperty(c)) continue;
      res.push(this.render(tpl, contents[c]));
    }
    return res;
  }
};