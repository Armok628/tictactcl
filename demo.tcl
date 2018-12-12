#!/usr/bin/tclsh
source tictac.tcl
update
set smt 0
set quit 0
lassign $argv x o
foreach arg [lrange $argv 2 end] {
	switch $arg {
		-smt {set smt 1}
		-quit {set quit 1}
	}
}
if {$smt} {
	source smtai.tcl
}
handle_move [random_move $game_state]
while {1} {
	if {[set winner [check_game_over $game_state]] ne "_"} break
	handle_move [think $game_state $o]
	if {[set winner [check_game_over $game_state]] ne "_"} break
	handle_move [think $game_state $x]
}
puts "Winner: $winner"
if {$quit} {
	after 2500
	exit
}
