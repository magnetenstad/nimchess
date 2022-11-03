import board
import piece
import tables
import strutils
import times
import std/os

const minTurnSeconds = 1
let depth = 4

proc play*(): void =
    let letters = ["a", "b", "c", "d", "e", "f", "g", "h"]
    let numbers = ["1", "2", "3", "4", "5", "6", "7", "8"]
    var blackToMove = false

    var board = boardCreate()

    echo "\n"
    echo draw(board)
    echo "Current evaluation: ", evaluate(board), "\n"

    while true:
        var a: array[2, int]
        var b: array[2, int]
        var input: seq[string]
        
        while true:
            try:
                # echo "\n" & ["white", "black"][int(blackToMove)] & " to move:"
                let i = "\n"#readline(stdin)

                if i.contains(" "):
                    input = split(i, " ")
                else:
                    break
                
                if input[0] == "exit":
                    break
                a = [find(letters, $input[0][0]), find(numbers, $input[0][1])]
                if input.len == 1:
                    echo board[a[0], a[1]].value
                b = [find(letters, $input[1][0]), find(numbers, $input[1][1])]
                break
            except:
                echo "Try again :)"
  
        let t = cpuTime()
        if input.len == 0:
            # echo "thinking.."
            let evaluation: Evaluation = evaluate(board, depth, blackToMove)
            echo evaluation
            if not evaluation.isEmpty():
                movePiece(board, evaluation.moveFrom, evaluation.moveTo)
                blackToMove = not blackToMove
                echo "Computer played:", letters[evaluation.moveFrom[0]],  numbers[evaluation.moveFrom[1]], letters[evaluation.moveTo[0]],  numbers[evaluation.moveTo[1]]
                echo "Eval: ", evaluation.eval
            else:
                echo "No legal moves."
            
        else:
            if input[0] == "exit":
                break
            var moves = getMoves(board, a)
            if not moves.contains(b):
                echo "Not a legal move."
            movePiece(board, a, b)
            blackToMove = not blackToMove
        echo "Current evaluation: ", evaluate(board), "\n"

        let dt = cpuTime() - t
        echo "Time: ", dt
        echo draw(board)
        if dt < minTurnSeconds:
            sleep(int((minTurnSeconds - dt) * 1000))
