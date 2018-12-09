proc new_game {} {
	list x -1 [lrepeat 9 [lrepeat 9 "_"]]
}
proc turn {game} {lindex $game 0}
proc next_board {game} {lindex $game 1}
proc board {game} {lindex $game 2}
proc next_turn {turn} {
	switch $turn {
	x {return o}
	o {return x}
	default {error "Invalid turn"}
	}
}
global win_methods
set win_methods [list \
	[list 0 1 2] [list 3 4 5] [list 6 7 8] \
	[list 0 3 6] [list 1 4 7] [list 2 5 8] \
	[list 0 4 8] [list 2 4 6]]
proc check_win {board} {
	global win_methods
	foreach win $win_methods {
		set m [lmap i $win {lindex $board $i}]
		switch $m {x x x} {return x} {o o o} {return o}
	}
	return [expr [lsearch $board "_"]==-1?"tie":"_"]
}
proc check_game_over {game} {
	set board [board $game]
	set wins [lmap b $board {check_win $b}]
	return [check_win $wins]
}
proc make_move {game_var b s} {
	upvar $game_var game
	set nb [next_board $game]
	set t [turn $game]
	if {[check_game_over $game] ne "_"} {
		return -code 1 "Illegal move ($t => $b, $s); Game over"
	} elseif {$b!=$nb&&$nb!=-1} {
		return -code 1 "Illegal move ($t => $b, $s); Out of bounds"
	} elseif {[check_win [lindex $game 2 $b]] ne "_"} {
		return -code 1 "Illegal move ($t => $b, $s); Board won"
	} elseif {[lindex $game 2 $b $s] ne "_"} {
		return -code 1 "Illegal move ($t => $b, $s); Occupied"
	}
	lset game 2 $b $s $t
	set nb [lindex $game 2 $s]
	lset game 1 [expr {[check_win $nb] ne "_"?-1:$s}]
	lset game 0 [next_turn $t]
}
