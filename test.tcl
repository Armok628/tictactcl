#!/usr/bin/tclsh
source tictac.tcl
handle_move {*}[random_move $game_state]
while {[check_game_over $game_state] eq "_"} {
	handle_move {*}[random_move $game_state]
	handle_move {*}[think $game_state]
}
# An error will occur if the "thinking" AI loses
