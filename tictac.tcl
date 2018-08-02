#!/usr/bin/tclsh

##### Board structures
proc new_board {} {lrepeat 9 0}
proc new_nested_board {} {lrepeat 9 [new_board]}
##### Turn taking/Move making
global turn
set turn x
proc linear_index {x y} {expr $x+$y*3}
proc next_turn {} {
	global turn
	case $turn {
		o {set turn x}
		x {set turn o}
	}
}
proc make_move {boardname x y} {
	global turn
	upvar $boardname board
	set lin [linear_index $x $y]
	if {[lindex $board $lin] ne "0"} {error "Occupied"}
	lset board $lin $turn
	next_turn
}
##### Win Conditions
global wins
set wins [list \
	[list 0 1 2] [list 3 4 5] [list 6 7 8] \
	[list 0 3 6] [list 1 4 7] [list 2 5 8] \
	[list 0 4 8] [list 2 4 6] \
]
proc check_stalemate {board} {
	return [expr [lsearch $board "0"]==-1]
}
proc check_win {board} {
	global wins
	foreach win $wins {
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
		return $winner
	}
	if [check_stalemate $board] {
		draw_board $board
		puts "Stalemate"
		return "0"
	}
	tailcall tictactoe $board
}

##### Frontend
package require Tk
proc pad_coords {xn yn wn hn p} {
	if $p {
		upvar $xn x
		upvar $yn y
		upvar $wn w
		upvar $hn h
		set x [expr {$x+$p}]
		set y [expr {$y+$p}]
		set w [expr {$w-2*$p}]
		set h [expr {$h-2*$p}]
	}
}
proc draw_board {c x0 y0 w h {p 0}} {
	pad_coords x0 y0 w h $p
	foreach n [list 0 1 2 3] {
		set x($n) [expr {$x0+$n*$w/3}]
		set y($n) [expr {$y0+$n*$h/3}]
	}
	$c create line $x(1) $y(0) $x(1) $y(3)
	$c create line $x(2) $y(0) $x(2) $y(3)
	$c create line $x(0) $y(1) $x(3) $y(1)
	$c create line $x(0) $y(2) $x(3) $y(2)
}
proc draw_x {c x y w h {p 0}} {
	pad_coords x y w h $p
	set x2 [expr {$x+$w}]
	set y2 [expr {$y+$h}]
	$c create line $x $y $x2 $y2 -fill blue
	$c create line $x $y2 $x2 $y -fill blue
}
proc draw_o {c x y w h {p 0}} {
	pad_coords x y w h $p
	set x2 [expr {$x+$w}]
	set y2 [expr {$y+$h}]
	$c create oval $x $y $x2 $y2 -outline red
}
proc board_canvas {path {w 200} {h 200} {p 20}} {
	canvas $path -width $w -height $h
	draw_board $path 0 0 $w $h $p
	return $path
}
grid [board_canvas .b 200 200 20]
