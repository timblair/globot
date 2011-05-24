# Globot TODOs

* Documentation
  * README, including information on creating new plugins
  * Basic project page (GH pages?)
  * Published, detailed Rocco docs
* Plugin management
  * Some way of enabling/disabling specific plugins
  * Provide a mechanism for a plugin to deactivate itself on error
* Plugin storage
  * Some way of bootstrapping specifc plugin data into the store on first run
* Daemonisation
  * Actually complete the daemonisation side of things
* Message handling
  * Better way of dealing with message types: maybe `Message#enter?` or similar?

## Known Issues

* Bot has a bad habit of disappearing from rooms after long periods of inactivity.  In fact, it's not just inactivity: sometimes it seems to drop out of the room for no reason, and with no error...
