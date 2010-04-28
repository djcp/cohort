ActsAsFreetaggable
==================
About AAF
--------
Acts as Freetaggable (AaF) aims to provide tagging to the models it decorates in a way unlike other tagging plugins provide. Where normal tagging plugins provide tagging in a flat model AaF provides tagging based on a hierarchical model. Take myself as an example:

I belong in the Berkman Institutes hierarchy as an Intern, in a flat model I might be tagged as follows:

    (Berkman) (Intern)
    
or

    (Berkman Intern)
    
Add in `(Harvard)` as a parent to Berkman and I'd either need to be tagged, again, or have another tag created to represent that hierarchy.

While this is OK for a few people, once you throw in 10s or 100s more tags and tagged objects things can quickly get out of hand. Drilling down a hierarchy objects need only be tagged once, by their deepest association. After this tagging has been made objects are by hierarchy tagged by all parents.

Should I be tagged by the `(Harvard → Berkman → Intern)`'s `(Intern)` tag I would then be associated with all of `(Intern)`'s parents `(Harvard)` and `(Berkman)`


*Acts as Freetaggable has not been tested on Windows*
 
Installation
-----
Acts as Freetaggable is quite easy to use. All you need to do is install the plugin with

    script/plugin install git://github.com/rkneufeld/acts_as_freetaggable

During the installation process AAF will copy a DB migration (uniquely named) into #{RAILS\_ROOT}/db/migrations and symlink its own plugins into #{RAILS\_ROOT}/vendor/plugins (unless they already exist)

You will need to

    rake db:migrate
    
the new migration into your DB. *You may need to rename the copied migration to be newer than any you already have.*

Usage
--------

After this initial setup you need only call 

    acts_as_freetaggable

on any model you want to be taggable. At the moment the plugin only supplies model-level functionality, so you'll have to throw together your own views/controllers, or you can use the ones supplied with acts\_as\_category. For example:

    class Contact
      acts_as_freetaggable
      
      # ... Other fancy stuff
    end
    
Now we can call a multitude of different methods on both Contacts and Tags. 

On a contact we can do:

    contact.tags

And on Tag and Tags we can do a whole lot more. Here are a few examples. More are listed [here](http://github.com/funkensturm/acts_as_category/tree/master).

    Tag.roots
    tag.children
    tag.contacts # if Contact acts_as_freetaggable
    tag.siblings
    tag.parent
    
Any combination will do, your imagination is the limit...

Testing
-------

`rake freetaggable:specs` from RAILS_ROOT should work.

*Currently 8 tests are failing under postgreSQL in tag\_ordering\_spec.rb and have previously passed. This is something I am working on correcting*

Copyright (c) 2009 Ryan Neufeld, released under the MIT license
