
document.observe("dom:loaded", function() {
  deal_with_flyouts();
});

function deal_with_flyouts(){
 $('main').select('[id*="flyout"]').each(
 function(el){
    if(el.hasClassName('toggle-target')){
      if(el.hasClassName('defaultopen')){
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
		el.removeClassName('hidden');
		el.addClassName('shown');
	}
	else {
		el.addClassName('hidden');
		el.removeClassName('shown');
	}
      }
      );
    }
  }
 );
 
}

