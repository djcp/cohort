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

function observe_contact_select_toggle(){
  $('toggle-contact-selects').observe('click', function(){
      $$('input.contact-selector').each(function(el){
        if(el.checked == true){
          el.checked = false;
          } else {
          el.checked = true;
          }
        });
      });
}

function count_selected_contacts(formId){
      var select_count = 0;
      $$('input.contact-selector').each(function(el){
        if(el.checked == true){
          select_count++;
          $(formId).insert(new Element('input', {'name' : 'contact_ids[]', 'type' : 'hidden', 'value' : el.getValue() }));
        }         
        });
      return select_count;
}

function bulk_actions_apply_tags(){
  $('apply-tags-form').observe('submit', function(baform){
      var select_count = count_selected_contacts('apply-tags-form');
      
      // This horrible, horrible hack is necessary  because we're using the PrototypeUI autocomplete
      // thing. It mangles the form fields that it observes.
      var tags_values = $F($('apply-tags-form').select('[name*="bulk_apply_tags"]')[0]);
      if(select_count == 0 || tags_values == ''){
        $('flyout-apply-bulk-tags-actions').insert(new Element('p', { 'class' : 'notification'} ).update('Please select a tag and a set of contacts.'));
        Event.stop(baform);
      }
      });
}

function bulk_actions_remove_tags(){
  $('remote-tags-form').observe('submit', function(baform){
      var select_count = count_selected_contacts('remove-tags-form');
      
      // This horrible, horrible hack is necessary  because we're using the PrototypeUI autocomplete
      // thing. It mangles the form fields that it observes.
      var tags_values = $F($('remove-tags-form').select('[name*="bulk_remove_tags"]')[0]);
      if(select_count == 0 || tags_values == ''){
        $('flyout-remove-bulk-tags-actions').insert(new Element('p', { 'class' : 'notification'} ).update('Please select a tag to remove and a set of contacts.'));
        Event.stop(baform);
      }
      });
}

document.observe("dom:loaded", function() {
  deal_with_flyouts();
  observe_contact_select_toggle();
  bulk_actions_apply_tags();
  bulk_actions_remove_tags();
});

function toggle_tag_container(id,json_url){
  var toggle_container = $('manage-tags-' + id);
  toggle_container.toggle();
  if(! toggle_container.visible()){
    // Update the count value. Coarse, I know.
    $('parent-tag-count-' + id).update($('tag-count-count-' + id ).innerHTML);
  } else {
    // Instantiate the new tag observer .. . but only if it hasn't been instantiated already.
    var observed = $('manage-tags-' + id).select('li.pui-autocomplete-input');
    if(observed == ''){
      ac = new UI.AutoComplete('new_tags-' + id,{shadow: "auto_complete", tokens: ',', url: json_url });
      ac.observe('input:empty', function(event) {event.memo.autocomplete.showMessage("Type a tag. New tags should be comma-separated.")})
        .observe('selection:empty', function(event) {event.memo.autocomplete.showMessage("Nothing found")});
    }
  }
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

