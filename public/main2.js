window.addEvent('domready', function () {

  $('left_border').setStyle('position', 'fixed');
  $('left_border').setStyle('left', 42);
  $('left_border').setStyle('top', 0);

  $('right_border').setStyle('position', 'fixed');
  $('right_border').setStyle('right', 42);
  $('right_border').setStyle('top', 0);

  var start = {
    content: $('content'),
    left_mover: $('left_border').getStyle('left').toInt() - 5,
    right_mover: $('right_border').getStyle('left').toInt() + 5,
    left: $('content').getStyle('margin-left').toInt(),
    right: $('content').getStyle('margin-right').toInt()
  };


  $('left_border').makeDraggable({
      snap: 1,
      modifiers: {'x': 'left', 'y': 'margin-right'},
      onDrag: function(ob){
        start.content.style.marginLeft = (start.left - start.left_mover + ob.style.left.toInt()) + 'px';
      },

      onComplete: function (ob) {
        start.content.style.marginLeft = (start.left - start.left_mover + ob.style.left.toInt()) + 'px';
      }
  });

  $('right_border').makeDraggable({
      snap: 1,
      modifiers: {'x': 'left', 'y': 'margin-right'},
      onDrag: function(ob){
        start.content.style.marginRight = (start.right - start.right_mover + ob.style.left.toInt()) + 'px';
      },

      onComplete: function (ob) {
        start.content.style.marginRight = (start.right - start.right_mover + ob.style.left.toInt()) + 'px';
      }
  });
});