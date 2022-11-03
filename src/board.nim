import piece
import std/tables
import std/sets
import sequtils

var evaluations: Table[string, float] = {"": 0.0}.toTable
var positions: HashSet[string] = [""].toHashSet

const icons = {
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

type Pos = array[2, int]

type Board*[width, height: static[int], T] = object
    data*: array[width * height, T]

proc `[]`*(board: Board, x, y: int): board.T {.inline.} =
    board.data[x * board.height + y]

proc `[]`*(board: Board, pos: Pos): board.T {.inline.} =
    board[pos[0], pos[1]]

proc `[]=`*(board: var Board, x, y: int, item: board.T) {.inline.} =
    board.data[x * board.height + y] = item

proc `[]=`*(board: var Board, pos: Pos, item: board.T) {.inline.} =
    board[pos[0], pos[1]] = item

proc boardCreate*(): Board[8, 8, Piece] =
    var board: Board[8, 8, Piece]

    for i in 0 .. 1:
        let color = bool(i)
        board[0, i*7] = Piece(color: color, name: 'R')
        board[1, i*7] = Piece(color: color, name: 'N')
        board[2, i*7] = Piece(color: color, name: 'B')
        board[3, i*7] = Piece(color: color, name: 'Q')
        board[4, i*7] = Piece(color: color, name: 'K')
        board[5, i*7] = Piece(color: color, name: 'B')
        board[6, i*7] = Piece(color: color, name: 'N')
        board[7, i*7] = Piece(color: color, name: 'R')

        for j in 0 ..< 8:
            board[j, 1 + i*5] = Piece(color: color, name: 'P')

    return board

proc draw*(board: Board): string =
    for y in countdown(board.height-1, 0):
        result &= $(y + 1) & " "
        for x in 0 ..< board.width:
            let piece: Piece = board[x, y]
            if piece.name == '\0':
                result &= "  "
            else:
                result &= icons[piece.toString]
        result &= "\n"
    result &= "  A B C D E F G H\n"

proc toString(board: Board): string = 
    for x in 0 ..< board.width:
        for y in 0 ..< board.height:
            result &= board[x, y].toString()

proc movePiece*(board: var Board, a: Pos, b: Pos) = 
    var pieceA: Piece = board[a]
    var pieceB: Piece = board[b]
    pieceA.moved = true
    board[b] = pieceA
    pieceB.name = '\0'
    board[a] = pieceB
    if pieceA.name == 'P' and (b[1] == 0 or b[1] == 7):
        pieceA.name = 'Q'

proc notPawnGetMoves(board: Board, pos: Pos, color: bool, dx: array, dy: array, dlen: int, len: int): seq =
    var moves = newSeq[Pos]()

    for i in 0 ..< dlen:
        for j in 1 .. len:
            let newPos: Pos = [pos[0] + dx[i] * j, pos[1] + dy[i] * j]

            if newPos[0] < 0 or 8 <= newPos[0]: break
            if newPos[1] < 0 or 8 <= newPos[1]: break

            let piece = board[newPos]
            
            if piece.isEmpty() or piece.color != color:
                moves.add(newPos)
            
            if not piece.isEmpty(): break
    return moves
    
proc getMoves*(board: Board, pos: Pos): seq =
    var moves = newSeq[Pos]()
    var piece: Piece = board[pos]
    
    case piece.name
    of 'P':
        let x = pos[0]
        let y = pos[1]

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
        moves = notPawnGetMoves(board, pos, piece.color, 
            [-1, 1, 2, 2, 1, -1, -2, -2], [-2, -2, -1, 1, 2, 2, 1, -1], 
            8, 1)
    of 'B':
        moves = notPawnGetMoves(board, pos, piece.color, 
            [-1, -1, 1, 1], [-1, 1, -1, 1], 4, 7)
    of 'R':
        moves = notPawnGetMoves(board, pos, piece.color, 
            [-1, 1, 0, 0], [0, 0, -1, 1], 4, 7)
    of 'Q':
        moves = notPawnGetMoves(board, pos, piece.color, 
            [-1, -1, 1, 1, -1, 1, 0, 0], [-1, 1, -1, 1, 0, 0, -1, 1], 8, 7)
    of 'K':
        moves = notPawnGetMoves(board, pos, piece.color, 
            [-1, -1, 1, 1, -1, 1, 0, 0], [-1, 1, -1, 1, 0, 0, -1, 1], 8, 1)
    else:
        discard
    
    piece.reach = moves.len
    return moves

proc evaluatePiece(board: Board, pos: Pos): float = 
    var piece: Piece = board[pos]
    if piece.isEmpty():
        return 0
    piece.reach = getMoves(board, pos).len
    return piece.evaluate()

proc evaluate*(board: Board): float =
    let boardString = board.toString()
    if boardString in positions:
        return 0
    if boardString in evaluations:
        return evaluations[boardString]
    for x in 0 ..< board.width:
        for y in 0 ..< board.height:
            result += evaluatePiece(board, [x, y]);
    evaluations[boardString] = result
    # echo boardString

type
    Evaluation* = object
        moveFrom*: Pos
        moveTo*: Pos
        eval*: float

method isEmpty*(evaluation: Evaluation): bool {.base.} =
    return evaluation.moveFrom == evaluation.moveTo

proc evaluate*(board: var Board, depth: int, blackToMove: bool, a: float, b: float): Evaluation =
    if depth == 0:
        return Evaluation(eval: evaluate(board))
    result = if blackToMove: Evaluation(eval: Inf) else: Evaluation(eval: -Inf)
    var a = a
    var b = b
    let upEight     = toSeq(countup(0, board.height-1, 1))
    let downEight   = toSeq(countdown(board.height-1, 0, 1))
    for y in (if not blackToMove: downEight else: upEight):
        for x in 0 ..< board.width:
            let pos = [x, y]
            var piece: Piece = board[pos]
            
            if (not piece.isEmpty() and piece.color == blackToMove):
                let moves = getMoves(board, pos)
                
                let pieceCopy = piece.copy()
                for move in moves:
                    let otherPiece: Piece = board[move]
                    let otherPieceCopy = otherPiece.copy()

                    movePiece(board, pos, move)

                    if otherPiece.name == 'K':
                        board[pos] = pieceCopy
                        board[move] = otherPieceCopy

                        return Evaluation(
                            moveFrom: pos, moveTo: move,
                            eval: (if blackToMove: -999999 else: 999999)
                        )

                    let evaluation = Evaluation(
                        moveFrom: pos, moveTo: move, eval: (
                        if board.toString() in positions:
                            0.0
                        else:
                            evaluate(
                                board, depth - 1, not blackToMove, a, b).eval
                    ))
                    
                    # move back
                    board[pos] = pieceCopy
                    board[move] = otherPieceCopy
                    
                    if blackToMove:
                        if evaluation.eval < result.eval:
                            result = evaluation
                        if result.eval <= a:
                            return result # Alpha pruning
                        b = min(b, result.eval)
                    else:
                        if evaluation.eval > result.eval:
                            result = evaluation
                        if result.eval >= b:
                            return result # Beta pruning
                        a = max(a, result.eval)
                    
proc evaluate*(board: var Board, depth: int, blackToMove: bool): Evaluation =
    var a: float = -Inf
    var b: float = Inf
    clear(evaluations)
    let boardString = board.toString()
    positions.incl(boardString)
    if (boardString.count('K') < 2):
        return Evaluation()
    evaluate(board, depth, blackToMove, a, b)
