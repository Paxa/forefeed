var Haml = {
  render: function(template, parentObj){
    if (this.typeOf(template[0]) == 'array') {
      var result = [];
      for(var i in template) {
        if (!template.hasOwnProperty(i)) continue;
        result.push(this.buildLine(template[i], parentObj));
      }
      return result;
    } else {
      return this.buildLine(template, parentObj);
    }
  },
  
  /*
    build DOM element by passed line
  */
  buildLine: function(set, parentObj) {
    var line = set.slice();
    var attributes = this.parseLine(line.shift());
    var content = line;
    
    // merging if second parametr is object
    if (this.typeOf(line[0]) == 'object') {
      attributes = this.mergeAttributes(attributes, line.shift());
    }
    
    // building element
    var element = document.createElement(attributes.tagname);
    for (var attr in attributes) {
      if (!attributes.hasOwnProperty(attr)) continue;
      var value = attributes[attr];
      switch (attr) {
        case 'tagname': break;
        case 'classes':
          for(var c in value) {
            if (!value.hasOwnProperty(c)) continue;
            element.className += ' ' + value[c];
          }
          break;
          
        case 'bind':
          // [this, 'container'] => set this['container'] = element
          value[0][value[1]] = element;
          break;
          
        case 'bindAt':
          parentObj[value] = element;
          break;
          
        case 'clk':
          // add event
          this.bindEvent(element, 'click', value);
          break;
          
        case 'store':
          element[value[0]] = value[1];
          break;
          
        default:
          element.setAttribute(attr, value);
      }
    }
    
    for (var i = 0; i < content.length; i++) {
      if (!content.hasOwnProperty(i)) continue;
      this.appendContent(element, content[i], parentObj);
    }
    
    return element;
  },
  
  // append content at the bottom of element
  // if it's string - append textNode
  // if it's domNode - append it
  // if it's array like ['.box', 'content'] - render and append
  // if it's array of nodes - append all
  appendContent: function(element, content, parentObj){
    if (this.typeOf(content) == 'element') {
      // if content is dom element
      element.appendChild(content);
    } else if (this.typeOf(content) == 'array') {
      if (this.typeOf(content[0]) == 'element') {
        // if content is set of dom elements
        for (var i = 0; i < content.length; i++) {
          element.appendChild(content[i]);
        }
      } else if (this.typeOf(content[0]) == 'string') {
        // if content is our haml template
        element.appendChild(this.render(content, parentObj));
      }
    } else if (content) {
      element.appendChild(document.createTextNode(content));
    }
  },
  
  /*
    split line in to hash of element attributes
  */
  parseLine: function(code){
    var attributes = {
      'tagname': 'div',
      'classes': []
    };
    
    var splitChars = {'.': 1, '%': 'tagname', '#': 'id', '': 1};
    var lastPartPos = 0;
    
    // seek for '.' or '#' or '%' and cut pease of string
    for (var i = 0; i < code.length + 1; i++) {
      // code.charAt(i) == '' means that it's end of line
      if (i > 0 && splitChars[code.charAt(i)]) {
        var part  = code.substr(lastPartPos, i - lastPartPos);
        var value = part.substr(1);
          
        if (part.charAt(0) == '.') {
          attributes.classes.push(value);
        } else {
          attributes[splitChars[part.charAt(0)]] = value;
        }
        lastPartPos = i;
      }
    }
    return attributes;
  },

  mergeAttributes: function(destination, source) {
    for (var property in source) {
      if (!source.hasOwnProperty(property)) continue;
      if (this.typeOf(destination[property]) == 'object')
        destination[property] = this.mergeAttributes(destination[property], source[property]);
      else if (this.typeOf(destination[property]) == 'array')
        destination[property].cancat(source[property]);
      else
        destination[property] = source[property];
    }
    return destination;
  },
  
  typeOf: function(item){
  	if (item == null) return 'null';

  	if (item.nodeName){
  		if (item.nodeType == 1) return 'element';
  		if (item.nodeType == 3) return (/\S/).test(item.nodeValue) ? 'textnode' : 'whitespace';
  	} else if (typeof item.length == 'number'){
  		if (item.callee) return 'arguments';
  		if (item.__proto__ && [].__proto__ === item.__proto__) return 'array';
  	}

  	return typeof item;
  },

  // this should be everwriten in order to you favorite framework
  bindEvent: function(element, event, callback) {
    element.addEvent(event, callback);
  }
};