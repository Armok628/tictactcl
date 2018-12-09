#!/usr/bin/tclsh
proc print_game {game} {
	puts "Turn: [turn $game]"
	puts "Next board: [next_board $game]"
	set board [board $game]
	for {set big_row 0} {$big_row<9} {incr big_row 3} {
		for {set small_row 0} {$small_row<9} {incr small_row 3} {
			for {set i $big_row} {$i<$big_row+3} {incr i} {
				for {set j $small_row} {$j<$small_row+3} {incr j} {
					puts -nonewline "[lindex $board $i $j] "
					if {$i+1<$big_row+3&&$j%3==2} {
						puts -nonewline "| "
					}
				}
			}
			puts ""
		}
		if {$big_row<6} {
			puts "------+-------+------"
		}
	}
}
##### Terminal frontend
source backend.tcl
source ai.tcl
set game [new_game]
while {1} {
	print_game $game
	lassign [gets stdin] in1 in2
	if {$in1 eq ""} {
		break
	} elseif {$in1 eq "think"} {
		if {$in2 ne ""} {
			puts [think $game $in2]
		} else {
			puts [think $game]
		}
	} elseif {$in2 ne ""} {
		if {[catch {make_move game $in1 $in2} err]} {
			puts $err
		}
	}
}
