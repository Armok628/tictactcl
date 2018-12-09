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
proc randelt {list} {
	lindex $list [expr {int(rand()*[llength $list])}]
}
proc random_move {game} {
	randelt [possible_moves $game]
}
proc finish_game {game_var} {
	upvar $game_var game
	while {[set move [random_move $game]] ne ""} {
		make_move game {*}$move
	}
}
proc think {game {level 10}} {
	set player [turn $game]
	set opponent [next_turn $player]
	set moves [possible_moves $game]
	set wincounts [list]
	puts "\nTurn: $player\nLevel: $level";
	foreach move $moves {
		set wins 0
		puts -nonewline "\t$move: "; flush stdout;
		for {set i 0} {$i<$level} {incr i} {
			set tmp $game
			make_move tmp {*}$move
			finish_game tmp
			switch [check_game_over $tmp] \
				$player {incr wins} \
				$opponent {incr wins -1}
		}
		puts [format "\t%2d" $wins];
		lappend wincounts $wins
	}
	set choices [list [lindex $moves 0]]
	set maxwins [lindex $wincounts 0]
	foreach move $moves wins $wincounts {
		if {$wins>$maxwins} {
			set choices [list]
			lappend choices $move
			set maxwins $wins
		} elseif {$wins==$maxwins} {
			lappend choices $move
		}
	}
	set choice [randelt $choices]
	puts "Chose $choice ($maxwins)\n"
	return $choice
}
