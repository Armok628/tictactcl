#!/usr/bin/tclsh
source backend.tcl
set game [new_game]
puts $game
make_move game 4 0
puts $game
make_move game 0 4
puts $game
make_move game 4 1
puts $game
make_move game 1 4
puts $game
make_move game 4 2
puts $game
make_move game 2 4
puts $game
puts "\nNext move should cause an error"
catch {make_move game 4 4} err
puts $err
