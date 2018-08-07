#!/usr/bin/tclsh
source tictac.tcl
update
toplevel .client
wm resizable .client 0 0
wm title .client "Tic-Tac-Tcl Client"
proc start {} {
	client_start [.client.entry get]
	destroy .client
}
ttk::button .client.button -text "Connect" -command start
ttk::entry .client.entry
bind .client.entry <Return> start
grid .client.entry -column 0 -row 0
grid .client.button -column 0 -row 1
grab set .client
focus .client.entry
