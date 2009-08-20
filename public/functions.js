
function getSelText() {
   var wnd = (window.name=='send_frame')?parent:window;
  var sel_text = null;
  if(wnd.getSelection) err_text=wnd.getSelection();
  else
    if(wnd.document.getSelection) err_text=wnd.document.getSelection();
    else sel_text = wnd.document.selection;

  if(sel_text) {
    err_text = sel_text.createRange().text;
  }

  return err_text;
}