proc possible_moves {game} {
	if {[check_game_over $game] ne "_"} return
	set moves [list]
	set b [next_board $game]
	if {$b==-1} {
		for {set b 0} {$b<9} {incr b} {
			if {[check_win [lindex $game 2 $b]] ne "_"} continue
			for {set s 0} {$s<9} {incr s} {
				if {[lindex $game 2 $b $s]=="_"} {
					lappend moves [list $b $s]
				}
			}
		}
	} else {
		for {set s 0} {$s<9} {incr s} {
			if {[lindex $game 2 $b $s]=="_"} {
				lappend moves [list $b $s]
			}
		}
	}
	return $moves
}
proc random_move {game} {
	set moves [possible_moves $game]
	return [lindex $moves [expr {int(rand()*[llength $moves])}]]
}
