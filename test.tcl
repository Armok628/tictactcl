#!/usr/bin/tclsh
source tictac.tcl
handle_move {*}[random_move $game_state]
while {[check_game_over $game_state] eq "_"} {
	set ai_difficulty 5
	catch {handle_move {*}[think $game_state]}
	set ai_difficulty 20
	catch {handle_move {*}[think $game_state]}
}
after 2500
exit
