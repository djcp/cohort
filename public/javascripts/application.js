// inspired by http://gorondowtl.sourceforge.net/wiki/Cookie
// Modified by DJCP to support setting a path.
var Cookie = {
  set: function(name, value, daysToExpire, path) {
    var expire = '';
    if (daysToExpire != undefined) {
      var d = new Date();
      d.setTime(d.getTime() + (86400000 * parseFloat(daysToExpire)));
      expire = '; expires=' + d.toGMTString();
    }
    return (document.cookie = escape(name) + '=' + escape(value || '') + expire + '; path=' + ((path) ? escape(path) : '/') ) ;
  },
  get: function(name) {
    var cookie = document.cookie.match(new RegExp('(^|;)\\s*' + escape(name) + '=([^;\\s]*)'));
    return (cookie ? unescape(cookie[2]) : null);
  },
  erase: function(name) {
    var cookie = Cookie.get(name) || true;
    Cookie.set(name, '', -1);
    return cookie;
  },
  accept: function() {
    if (typeof navigator.cookieEnabled == 'boolean') {
      return navigator.cookieEnabled;
    }
    Cookie.set('_test', '1');
    return (Cookie.erase('_test') === '1');
  }
};

document.observe("dom:loaded", function() {
  deal_with_flyouts();
});

function toggle_tag_container(id){
  $('manage-tags-' + id).toggle();
  $('parent-tag-count-' + id).update($('tag-count-count-' + id ).innerHTML);
}

function toggle_notes_container(id){
  $('add-new-note-' + id).toggle();
  $('parent-note-count-' +id).update($('note-count-' + id).innerHTML);
}

function remove_tag(id){
  $('tag-' + id).remove();
}

function deal_with_flyouts(){
  // find all elements with an ID that contains 'flyout'
 $('main').select('[id*="flyout"]').each(
 function(el){
    if(el.hasClassName('toggle-target')){
    // This is a container that gets closed when the toggle is clicked. 
    // Check for cookie-based visibility overrides first, then implement the 
    // default, hard-coded behavior.
      var vizCookieVal = Cookie.get(el.id + '-visibility');
      var toggleContainer = el.id.replace('-actions','');
      if(vizCookieVal == 'show'){
        el.show();
        $(toggleContainer).removeClassName('hidden');
        $(toggleContainer).addClassName('shown');
      }
      else if(vizCookieVal == 'hide'){
        el.hide();
        $(toggleContainer).removeClassName('shown');
        $(toggleContainer).addClassName('hidden');
      } 
      else if(el.hasClassName('defaultopen')){
        el.show();
      }
      else {
        el.hide();
      }
    }
    else {

    el.observe('click',function(){
      target = $(el.id + '-actions');
      target.toggle();
      if(target.visible()){
        Cookie.set(el.id + '-actions-visibility', 'show', 10000);
        el.removeClassName('hidden');
        el.addClassName('shown');
      }
      else {
        Cookie.set(el.id + '-actions-visibility', 'hide', 10000);
        el.addClassName('hidden');
        el.removeClassName('shown');
      }
    });

  }
});
 
}

