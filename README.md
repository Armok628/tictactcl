# tictactcl
A nested tic-tac-toe game in Tcl/Tk

The rules are simple. The cell you move in (relative to its board) represents the corresponding board (relative to the game) the next move must be played in.
If the board is full or has been won already, they may move in any other board.
The game ends when three boards have been won in a row.

A square is drawn to keep track of whose turn it is and where they must move next.

AI will make a move with middle-click, or by pressing F1 and enabling auto-move (and then moving).
Also in the F1 window, you may change the AI's level, i.e. how thoroughly the AI considers each possible move.

The AI algorithm is a variation on the Monte Carlo tree search, and is optionally multi-threaded for performance.

![Example game](https://i.imgur.com/BPO24fI.png)
