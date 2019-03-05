#!/usr/bin/tclsh
source tictac.tcl
update
set n [expr {$argc>0?[lindex $argv 0]:18}]
for {set i 0} {$i<$n} {incr i} {
	handle_move [random_move $game_state]
}
