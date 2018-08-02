#!/usr/bin/tclsh

##### Board structures
proc new_board {} {lrepeat 9 0}
proc new_nested_board {} {lrepeat 9 [new_board]}
##### Turn taking/Move making
global turn
set turn x
proc linear_index {x y} {expr $x+$y*3}
proc 2d_index {l} {list [expr {$l%3}] [expr {$l/3}]}
proc next_turn {} {
	global turn
	case $turn {
		o {set turn x}
		x {set turn o}
	}
}
proc make_move {board x y} {
	global turn
	set lin [linear_index $x $y]
	if {[lindex $board $lin] ne "0"} {
		error "Occupied"
	}
	lset board $lin $turn
	return $board
}
##### Win Conditions
global wins
set wins [list \
	[list 0 1 2] [list 3 4 5] [list 6 7 8] \
	[list 0 3 6] [list 1 4 7] [list 2 5 8] \
	[list 0 4 8] [list 2 4 6] \
]
proc free_space {board} {
	return [expr [lsearch $board "0"]!=-1]
}
proc check_win {board} {
	global wins
	foreach win $wins {
		set moves [lmap s $win {lindex $board $s}]
		if {[tcl::mathop::eq {*}$moves]&&($moves ne "0 0 0")&&($moves ne "1 1 1")} {
			return [lindex $moves 0]
		}
	}
	return "0"
}
proc check_global_win {board} {
	check_win [lmap b $board {check_win $b}]
}

##### Frontend
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

global masterboard
set masterboard [new_nested_board]
global next_board
set next_board -1
global legality_square
proc player_color {player} {
	case $player {
		x {return blue}
		o {return red}
		default {return black}
	}
}
proc update_legality_square {} {
	global legality_square
	global next_board
	global masterboard
	global turn
	catch {.board delete $legality_square}
	set color [player_color $turn]
	if {$next_board==-1||![free_space [lindex $masterboard $next_board]]} {
		set next_board -1
		set legality_square [.board create rectangle 10 10 590 590 -outline $color]
	} else {
		lassign [2d_index $next_board] x y
		set x1 [expr {30+186*$x}]
		set x2 [expr {196+186*$x}]
		set y1 [expr {30+186*$y}]
		set y2 [expr {196+186*$y}]
		set legality_square [.board create rectangle $x1 $y1 $x2 $y2 -outline $color]
	}
}
proc game_coords {x y} {
	set x [expr {$x-20}]
	set y [expr {$y-20}]
	set bx [expr {$x/186}]
	if {$bx<0||$bx>2} {error "Out of bounds"}
	set by [expr {$y/186}]
	if {$by<0||$by>2} {error "Out of bounds"}
	set sx [expr {(($x%186)-20)/48}]
	if {$sx<0||$sx>2} {error "Out of bounds"}
	set sy [expr {(($y%186)-20)/48}]
	if {$sy<0||$sy>2} {error "Out of bounds"}
	list [linear_index $bx $by] [linear_index $sx $sy]
}
proc cell_root {bl sl} {
	lassign [2d_index $bl] bx by
	lassign [2d_index $sl] sx sy
	set x [expr {20+186*$bx+20+48*$sx}]
	set y [expr {20+186*$by+20+48*$sy}]
	list $x $y
}
proc handle_move {bl sl} {
	global masterboard
	global next_board
	global turn
	global legality_square
	if {$next_board!=-1&&$bl!=$next_board} {error "Illegal move"}
	lassign [2d_index $sl] sx sy
	if [catch {lset masterboard $bl [make_move [lindex $masterboard $bl] $sx $sy]} err] {
		error $err
		return
	}
	set next_board $sl
	draw_$turn .board {*}[cell_root $bl $sl] 48 48 5
	set win [check_win [lindex $masterboard $bl]]
	if {$win ne "0"} {
		draw_$win .board {*}[cell_root $bl 0] 146 146 -10
		lset masterboard $bl [string map "0 1" [lindex $masterboard $bl]]
		set win [check_global_win $masterboard]
		if {$win ne "0"} {
			draw_$win .board 0 0 600 600 10
			.board delete $legality_square
			set next_board -2
			.board configure -state disabled
			return
		}
	}
	next_turn
	update_legality_square
}

##### GUI Setup
package require Tk
canvas .board -width 600 -height 600 -background white
bind .board <1> {
	handle_move {*}[game_coords %x %y]
}
draw_board .board 0 0 600 600 20
for {set x 0} {$x<3} {incr x} {
for {set y 0} {$y<3} {incr y} {
	draw_board .board [expr {20+$x*186}] [expr {20+$y*186}] 186 186 20
}}
update_legality_square
grid .board
