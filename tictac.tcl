#!/usr/bin/tclsh
source backend.tcl
global game_state
set game_state [new_game]
##### Frontend
proc linear_index {x y} {expr $x+$y*3}
proc 2d_index {l} {list [expr {$l%3}] [expr {$l/3}]}
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
proc player_color {player} {
	switch $player {
		x {return blue}
		o {return red}
		default {return black}
	}
}
global legality_square
proc update_legality_square {} {
	global game_state
	global legality_square
	set nb [next_board $game_state]
	catch {.board delete $legality_square}
	set color [player_color [turn $game_state]]
	if {$nb==-1} {
		set legality_square [.board create rectangle 10 10 590 590 -outline $color]
	} else {
		lassign [2d_index $nb] x y
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
	if {$bx<0||$bx>2} {error "Click occurred out of bounds"}
	set by [expr {$y/186}]
	if {$by<0||$by>2} {error "Click occurred out of bounds"}
	set sx [expr {(($x%186)-20)/48}]
	if {$sx<0||$sx>2} {error "Click occurred out of bounds"}
	set sy [expr {(($y%186)-20)/48}]
	if {$sy<0||$sy>2} {error "Click occurred out of bounds"}
	list [linear_index $bx $by] [linear_index $sx $sy]
}
proc cell_root {bl sl} {
	lassign [2d_index $bl] bx by
	lassign [2d_index $sl] sx sy
	set x [expr {20+186*$bx+20+48*$sx}]
	set y [expr {20+186*$by+20+48*$sy}]
	list $x $y
}

proc handle_move {b s} {
	global game_state
	global legality_square
	set t [turn $game_state]
	if {[catch {make_move game_state $b $s} err]} {
		error $err
	}
	draw_$t .board {*}[cell_root $b $s] 48 48 5
	set winner [check_win [lindex [board $game_state] $b]]
	if {$winner ne "_"&&$winner ne "tie"} {
		draw_$winner .board {*}[cell_root $b 0] 146 146 -10
	}
	set winner [check_game_over $game_state]
	if {$winner ne "_"} {
		.board delete $legality_square
		if {$winner ne "tie"} {
			draw_$winner .board 0 0 600 600 10
		}
	} else {
		update_legality_square
	}
	update
}

##### Network
global client
global server_addr
proc send_move {channel coords} {
	fileevent $channel writable {set ready 1}
	vwait ready
	puts "Sending: $coords"
	puts $channel $coords
	flush $channel
}
proc receive_move {channel} {
	catch {destroy .wait}
	fileevent $channel readable {set ready 1}
	vwait ready
	set coords [gets $channel]
	flush $channel
	puts "Received: $coords"
	if {[llength $coords]==2} {
		handle_move {*}$coords
	}
}
proc wait_screen {} {
	if [catch {toplevel .wait}] return
	wm title .wait "Wait"
	grid [ttk::label .wait.l -text "Waiting for opponent..."] -padx 10 -pady 10
	update
	grab set .wait
}
proc receive_client {channel addr port} {
	global client
	set client $channel
	receive_move $client
}
proc server_init {} {
	socket -server receive_client 62899
	update
	wait_screen
}
proc client_init {addr} {
	global server_addr
	set server_addr $addr
}
proc server_send {coords} {
	global client
	send_move $client $coords
	close $client
	unset client
#	wait_screen
}
proc client_send {coords} {
	global server_addr
	update
	set channel [socket $server_addr 62899]
	send_move $channel $coords
#	wait_screen
	receive_move $channel
	close $channel
}
##### GUI Setup
package require Tk
wm title . "Tic-Tac-Tcl"
wm resizable . 0 0
canvas .board -width 600 -height 600 -background white
bind .board <1> {
	set coords [game_coords %x %y]
	handle_move {*}$coords
	if [info exists client] {
		server_send $coords
	} elseif [info exists server_addr] {
		client_send $coords
	}
}
draw_board .board 0 0 600 600 20
for {set x 0} {$x<3} {incr x} {
for {set y 0} {$y<3} {incr y} {
	draw_board .board [expr {20+$x*186}] [expr {20+$y*186}] 186 186 20
}}
update_legality_square
grid .board
########################
source ai.tcl
bind .board <3> {
	handle_move {*}[random_move $game_state]
}
bind .board <2> {
	handle_move {*}[think $game_state]
}
