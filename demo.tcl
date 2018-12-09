#!/usr/bin/tclsh
source tictac.tcl
handle_move [random_move $game_state]
while {[check_game_over $game_state] eq "_"} {
	catch {handle_move [think $game_state 5]}
	catch {handle_move [think $game_state 25]}
}
puts "Winner: [check_game_over $game_state]"
if {[llength $argv]} {after 2500; exit}
