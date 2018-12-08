#!/usr/bin/tclsh
source backend.tcl
set game [new_game]
puts $game
make_move game [list 4 0]
puts $game
make_move game [list 0 4]
puts $game
make_move game [list 4 1]
puts $game
make_move game [list 1 4]
puts $game
make_move game [list 4 2]
puts $game
make_move game [list 2 4]
puts $game
puts "\nNext move should cause an error"
catch {make_move game [list 4 4]} msg
puts $msg
