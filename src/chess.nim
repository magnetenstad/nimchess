import board
import piece
import tables
import strutils
import times

proc main*(): void =
    let letters = ["a", "b", "c", "d", "e", "f", "g", "h"]
    let numbers = ["1", "2", "3", "4", "5", "6", "7", "8"]
    var turn = false

    var chess = boardCreate()

    echo "\n"
    echo draw(chess)
    echo "Current evaluation: ", evaluate(chess), "\n"

    while true:
        var a: array[2, int]
        var b: array[2, int]
        var input: seq[string]
        
        while true:
            try:
                echo "\n" & ["white", "black"][int(turn)] & " to move:"
                let i = "\n"#readline(stdin)

                if i.contains(" "):
                    input = split(i, " ")
                else:
                    break
                
                if input[0] == "exit":
                    break
                a = [find(letters, $input[0][0]), find(numbers, $input[0][1])]
                if input.len == 1:
                    echo chess[a[0], a[1]].value
                b = [find(letters, $input[1][0]), find(numbers, $input[1][1])]
                break
            except:
                echo "Try again :)"
        echo a
        echo b

        if input.len == 0:
            let t = cpuTime()
            echo "thinking.."
            let depth = 3
            let evaluation = evaluateRecursive(chess, depth, turn)
            echo evaluation
            if not evaluation.isEmpty():
                movePiece(chess, evaluation.moveFrom, evaluation.moveTo)
                echo "Computer played:", letters[evaluation.moveFrom[0]],  numbers[evaluation.moveFrom[1]], letters[evaluation.moveTo[0]],  numbers[evaluation.moveTo[1]]
                echo "Eval: ", evaluation.eval
                turn = not turn
            else:
                echo "No legal moves."
            echo "Time: ", cpuTime() - t
        else:
            if input[0] == "exit":
                break
            var piece = chess[a[0], a[1]]
            var moves = getMoves(chess, piece, a[0], a[1])
            if not moves.contains(b):
                echo "Not a legal move."
            movePiece(chess, a, b)
            turn = not turn
        echo "Current evaluation: ", evaluate(chess), "\n"
        echo draw(chess)
