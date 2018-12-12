package require Thread
if {[info procs think] eq ""} {
	source ai.tcl
}
proc think {game {level 10}} { ;# Multithreaded
	package require Thread
	set moves [possible_moves $game]
	if {$level<=0} {
		return [randelt $moves]
	}
	set player [turn $game]
	set opponent [next_turn $player]
	set wincounts [list]
	puts "\nTurn: $player\nLevel: $level"
	for {set i 0} {$i<$level} {incr i} {
		set thread($i) [thread::create]
		thread::send -async $thread($i) {
			source backend.tcl
			source ai.tcl
		} result
	}
	for {set i 0} {$i<$level} {incr i} {
		vwait result
	}
	tsv::set ai game $game
	set ::ai_progress 0
	foreach move $moves {
		tsv::set ai move $move
		tsv::set ai wins 0
		puts -nonewline "\t$move: "; flush stdout
		for {set i 0} {$i<$level} {incr i} {
			thread::send -async $thread($i) {
				set tmp [tsv::get ai game]
				set player [turn $tmp]
				set opponent [next_turn $player]
				make_move tmp {*}[tsv::get ai move]
				finish_game tmp
				switch [check_game_over $tmp] \
					$player {tsv::incr ai wins} \
					$opponent {tsv::incr ai wins -1}
			} result
		}
		for {set i 0} {$i<$level} {incr i} {
			vwait result
		}
		lappend wincounts [tsv::get ai wins]
		puts "[lindex $wincounts end]"
		set ::ai_progress [expr {$::ai_progress+100.0/[llength $moves]}]
	}
	unset ::ai_progress
	tsv::unset ai
	for {set i 0} {$i<$level} {incr i} {
		thread::release $thread($i)
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
