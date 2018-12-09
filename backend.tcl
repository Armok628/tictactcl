#!/usr/bin/tclsh
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
	return "_"
}
proc no_space {board} {
	if {[llength [lindex $board 0]]==1} {
		return [expr {[check_win $board] ne "_"||[lsearch $board "_"]==-1}]
	} else {
		foreach b $board {
			if {![no_space $b]} {
				return 0
			}
		}
		return 1
	}
}
proc check_game_over {board} {
	set winner [check_win [lmap b $board {check_win $b}]]
	if {$winner ne "_"} {
		return $winner
	} elseif {[no_space $board]} {
		return "#"
	} else {
		return "_"
	}
}
proc make_move {game_name b s} {
	upvar $game_name game
	set nb [next_board $game]
	set t [turn $game]
	if {[check_game_over [board $game]] ne "_"} {
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
	lset game 1 [expr {[no_space $nb]||[check_win $nb] ne "_"?-1:$s}]
	lset game 0 [next_turn $t]
}
