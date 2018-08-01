#!/usr/bin/tclsh
#package require Tk

##### Board structures
proc new_board {} {lrepeat 0 9}
proc new_nested_board {} {lrepeat [new_board] 9}

##### Turn taking/Move making
global turn
set turn x
proc linear_index {x y} {expr $x+$y*3}
proc next_turn {} {case $::turn o {set ::turn x} x {set ::turn o}}
proc make_move {boardname x y} {
	global turn
	upvar $boardname board
	set lin [linear_index $x $y]
	if {[lindex $board $lin] ne "0"} {error "Occupied"}
	lset board $lin $turn
	next_turn
}

##### Win Conditions
set wins [list \
	[list 0 1 2] [list 3 4 5] [list 6 7 8] \
	[list 0 3 6] [list 1 4 7] [list 2 5 8] \
	[list 0 4 8] [list 2 4 6] \
]
proc check_win {board} {
	foreach win $::wins {
		set moves [lmap s $win {lindex $board $s}]
		if {[tcl::mathop::eq {*}$moves]&&($moves ne "0 0 0")} {
			return [lindex $moves 0]
		}
	}
	return "0"
}
proc check_global_win {board} {
	check_win [lmap b $board {check_win $b}]
}

##### Single-Board CLI (Temporary?)
proc draw_board {board} {
	set i 0
	foreach space $board {
		puts -nonewline [expr {($space eq "x")||($space eq "o")?$space:" "}]
		if {!([incr i]%3)} {puts ""}
	}
}
proc tictactoe {{board ""}} {
	if {![llength $board]} {set board [new_board]}
	draw_board $board
	set move [gets stdin]
	if [catch {make_move board {*}$move} err] {puts $err}
	set winner [check_win $board]
	if {$winner ne "0"} {
		draw_board $board
		puts "Winner: $winner"
		exit
	}
	tailcall tictactoe $board
}
