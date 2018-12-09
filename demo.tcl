#!/usr/bin/tclsh
source tictac.tcl
update
handle_move [random_move $game_state]
lassign $argv x o
while {[set winner [check_game_over $game_state]] eq "_"} {
	handle_move [think $game_state $o]
	handle_move [think $game_state $x]
}
puts "Winner: $winner"
if {[llength $argv]>2} {after 2500; exit}
