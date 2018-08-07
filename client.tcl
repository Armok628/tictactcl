#!/usr/bin/tclsh
source tictac.tcl
wm title . "Tic-Tac-Tcl Client"
update
toplevel .client
wm title .client "Connection"
wm resizable .client 0 0
proc start {} {
	client_init $::address
	destroy .client
	switch $::first {
		client {}
		server {client_send -1}
	}
}
ttk::checkbutton .client.first -text "Server moves first" \
	-variable first -onvalue "server" -offvalue "client"
set first "client"
ttk::button .client.button -text "Connect" -command start
ttk::entry .client.entry -textvariable address
set address "Address"
bind .client.entry <Return> start
bind .client.entry <KP_Enter> start
grid .client.entry -column 0 -row 0
grid .client.first -column 0 -row 1
grid .client.button -column 0 -row 2
grab set .client
focus .client.entry
.client.entry selection range 0 end
