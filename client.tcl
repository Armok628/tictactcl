#!/usr/bin/tclsh
package require Tk
update
toplevel .client
ttk::entry .client.entry
ttk::button .client.button -command {
	source tictac.tcl
	client_start [.client.entry get]
	destroy .client
}
grid .client.entry -column 0 -row 0
grid .client.button -column 0 -row 1
grab set .client
