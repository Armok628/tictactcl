proc randelt {l} {
	lindex $l [expr {int(rand()*[llength $l])}]
}
proc random_move {game} {
	if {[check_game_over [board $game]] ne "_"} return
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
	return [lindex $moves [expr {int(rand()*[llength $moves])}]]
}
