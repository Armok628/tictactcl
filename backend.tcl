#!/usr/bin/tclsh
proc new_nested_board {} {
	lrepeat 9 [lrepeat 9 "_"]
}
proc next_turn {turn} {
	switch $turn {
	x {return o}
	o {return x}
	default {error "Invalid turn"}
	}
}
proc turn {game} {lindex $game 0}
proc next_board {game} {lindex $game 1}
proc board {game} {lindex $game 2}
proc new_game {} {
	list x -1 [new_nested_board]
}
global win_methods
set win_methods [list \
	[list 0 1 2] [list 3 4 5] [list 6 7 8] \
	[list 0 3 6] [list 1 4 7] [list 2 5 8] \
	[list 0 4 8] [list 2 4 6]]
proc check_board {board} {
	global win_methods
	foreach win $win_methods {
		set m [lmap i $win {lindex $board $i}]
		switch $m {x x x} {return x} {o o o} {return o}
	}
	return "_"
}
proc make_move {game_name coords} {
	upvar $game_name game
	set nb [next_board $game]
	set t [turn $game]
	set b [lindex $coords 0]
	set s [lindex $coords 1]
	set coords [concat 2 $coords]
	if {[lindex $coords 1]!=$nb&&$nb!=-1} {
		return -code 1 "Illegal move ($t => $b, $s); Outside allowed board"
	} elseif {[check_board [lindex $game 2 $b]] ne "_"} {
		return -code 1 "Illegal move ($t => $b, $s); Board already won"
	} elseif {[lindex $game $coords] ne "_"} {
		return -code 1 "Illegal move ($t => $b, $s); Occupied"
	}
	# Make the move
	lset game $coords $t
	lset game 1 [expr {[check_board [lindex $game 2 $s]] ne "_"?-1:$s}]
	lset game 0 [next_turn $t]
}
