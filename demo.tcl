#!/usr/bin/tclsh
source tictac.tcl
handle_move [random_move $game_state]
lassign $argv x o
while {[check_game_over $game_state] eq "_"} {
	catch {handle_move [think $game_state $o]}
	catch {handle_move [think $game_state $x]}
}
puts "Winner: [check_game_over $game_state]"
if {[llength $argv]>2} {after 2500; exit}
