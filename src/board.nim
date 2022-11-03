import piece
import tables

let icons = {
    "P0": "♟ ",
    "N0": "♞ ",
    "B0": "♝ ",
    "R0": "♜ ",
    "Q0": "♛ ",
    "K0": "♚ ",
    "P1": "♙ ",
    "N1": "♘ ",
    "B1": "♗ ",
    "R1": "♖ ",
    "Q1": "♕ ",
    "K1": "♔ "
}.toTable()

type Board*[width, height: static[int], T] = object
    data*: array[width * height, T]

proc `[]`*(m: Board, x, y: int): m.T {.inline.} =
    m.data[x*m.height + y]

proc `[]=`*(m: var Board, x, y: int, z: m.T) {.inline.} =
    m.data[x*m.height + y] = z

type Move = array[2, int]

proc boardCreate*(): Board[8, 8, Piece] =
    var board: Board[8, 8, Piece]

    for i in 0 .. 1:
        board[2, i*7] = Piece(color: bool(i), name: 'B', reachFactor: 0.08)
        board[1, i*7] = Piece(color: bool(i), name: 'N', reachFactor: 0.10)
        board[3, i*7] = Piece(color: bool(i), name: 'Q', reachFactor: 0.03)
        board[0, i*7] = Piece(color: bool(i), name: 'R', reachFactor: 0.08)
        board[4, i*7] = Piece(color: bool(i), name: 'K', reachFactor: 0.08)
        board[5, i*7] = Piece(color: bool(i), name: 'B', reachFactor: 0.08)
        board[6, i*7] = Piece(color: bool(i), name: 'N', reachFactor: 0.08)
        board[7, i*7] = Piece(color: bool(i), name: 'R', reachFactor: 0.08)

        for j in 0 ..< 8:
            board[j, 1 + i*5] = Piece(color: bool(i), name: 'P')

    return board

proc draw*(board: Board): string =
    for y in countdown(board.height-1, 0):
        result &= $(y + 1) & " "
        for x in 0 ..< board.width:
            let p: Piece = board[x, y]
            if p.name == '\0':
                result &= "  "
            else:
                result &= icons[p.toString]
        result &= "\n"
    result &= "  A B C D E F G H\n"

proc toString(board: Board): string = 
    for x in 0 ..< board.width:
        for y in 0 ..< board.height:
            result &= board[x, y].toString()

proc movePiece*(board: var Board, a: Move, b: Move) = 
    var p0: Piece = board[a[0], a[1]]
    var p1: Piece = board[b[0], b[1]]
    p0.moved = true
    board[b[0], b[1]] = p0
    p1.name = '\0'
    board[a[0], a[1]] = p1

proc notPawnGetMoves(board: Board, x: int, y: int, color: bool, dx: array, dy: array, dlen: int, len: int): seq =
    var moves = newSeq[Move]()

    for i in 0 ..< dlen:
        for j in 1 .. len:
            let x1: int = x + dx[i] * j
            let y1: int = y + dy[i] * j

            if x1 < 0 or 8 <= x1: break
            if y1 < 0 or 8 <= y1: break

            let piece = board[x1, y1]
            
            if piece.isEmpty() or piece.color != color:
                moves.add([x1, y1])
            
            if not piece.isEmpty(): break
    return moves
    
proc getMoves*(board: Board, piece: var Piece, x: int, y: int): seq =
        var moves = newSeq[Move]()

        case piece.name
        of 'P':
            let y1 = y + 1 - 2 * int(piece.color)

            if y1 < 0 or 8 <= y1:
                return moves

            if board[x, y1].isEmpty():
                moves.add([x, y1])

                if not piece.color and y == 1 and board[x, 3].isEmpty():
                    moves.add([x, 3])

                if piece.color and y == 6 and board[x, 4].isEmpty():
                    moves.add([x, 4])

            if 0 < x:
                let tileL = board[x - 1, y1]
                if not tileL.isEmpty() and tileL.color != piece.color:
                    moves.add([x - 1, y1])
            if x < 7:
                let tileR = board[x + 1, y1]
                if not tileR.isEmpty() and tileR.color != piece.color:
                    moves.add([x + 1, y1])
        
        of 'N':
            moves = notPawnGetMoves(board, x, y, piece.color, [-1, 1, 2, 2, 1, -1, -2, -2], [-2, -2, -1, 1, 2, 2, 1, -1], 8, 1)
        of 'B':
            moves = notPawnGetMoves(board, x, y, piece.color, [-1, -1, 1, 1], [-1, 1, -1, 1], 4, 7)
        of 'R':
            moves = notPawnGetMoves(board, x, y, piece.color, [-1, 1, 0, 0], [0, 0, -1, 1], 4, 7)
        of 'Q':
            moves = notPawnGetMoves(board, x, y, piece.color, [-1, -1, 1, 1, -1, 1, 0, 0], [-1, 1, -1, 1, 0, 0, -1, 1], 8, 7)
        of 'K':
            moves = notPawnGetMoves(board, x, y, piece.color, [-1, -1, 1, 1, -1, 1, 0, 0], [-1, 1, -1, 1, 0, 0, -1, 1], 8, 1)
        else:
            discard
        
        piece.reach = moves.len
        return moves

proc evaluatePiece(board: var Board, piece: var Piece, x: int, y: int): float = 
    piece.reach = getMoves(board, piece, x, y).len
    return piece.evaluate()

proc evaluate*(board: var Board): float =
    for x in 0 ..< board.width:
        for y in 0 ..< board.height:
            var p: Piece = board[x, y]
            if not p.isEmpty():
                result += evaluatePiece(board, p, x, y) #p.value;

type
    Evaluation* = object
        moveFrom*: Move
        moveTo*: Move
        eval*: float

method isEmpty*(evaluation: Evaluation): bool {.base.} =
    return evaluation.moveFrom == [0, 0] and evaluation.moveTo == [0, 0]

proc evaluateRecursive*(board: var Board, depth: int, turn: bool): Evaluation =
    for x in 0 ..< board.width:
        for y in 0 ..< board.height:
            var piece: Piece = board[x, y]
            
            if (not piece.isEmpty() and piece.color == turn):
                var moves = getMoves(board, piece, x, y)
                
                for move in moves:
                    var tileNew = board[move[0], move[1]]
                    if not tileNew.isEmpty():
                        tileNew = tileNew.copy()

                    movePiece(board, [x, y], move)

                    discard evaluatePiece(board, piece, move[0], move[1])
                    
                    var evaluation: Evaluation

                    if depth > 1:
                        evaluation = evaluateRecursive(board, depth - 1, not turn)
                        if evaluation.isEmpty():
                            evaluation = Evaluation(moveFrom: [x, y], moveTo: move, eval: evaluate(board))
                    else:
                        evaluation = Evaluation(moveFrom: [x, y], moveTo: move, eval: evaluate(board))
                    
                    board[x, y] = piece
                    board[move[0], move[1]] = tileNew

                    if evaluation.isEmpty():
                        continue
                    
                    if result.isEmpty() or (evaluation.eval < result.eval and turn) or (not turn and evaluation.eval > result.eval):
                        result = Evaluation(moveFrom: [x, y], moveTo: move, eval: evaluation.eval)
    
