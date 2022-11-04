import tables
import types

const pieceValues = {
    'P': 1.0,
    'N': 3.0,
    'B': 3.0,
    'R': 5.0,
    'Q': 10.0,
    'K': 9999.0
}.toTable()

const reachFactor = {
    'P': 0.00,
    'N': 0.10,
    'B': 0.08,
    'R': 0.08,
    'Q': 0.03,
    'K': 0.08
}.toTable()

method toString*(piece: Piece): string {.base.} =
    return piece.name & $int(piece.color)

proc evaluate*(piece: var Piece, board: Board, pos: Pos): float =
    piece.value = pieceValues.getOrDefault(piece.name, 0)
    piece.value += float(piece.reach) * reachFactor[piece.name]
    
    case piece.name
    
    of 'P':
        piece.value += float(abs(pos[1] - (if piece.color: 6 else: 1))) * 0.05
    
    of 'K':
        for x in countup(max(pos[0] - 1, 0), min(pos[0] + 1, board.width - 1)):
            for y in countup(max(pos[1] - 1, 0), min(pos[1] + 1, board.height - 1)):
                if x == y: continue
                let other = board[x, y]
                if not other.isEmpty and other.color == piece.color:
                    piece.value += (if other.name == 'P': 0.2 else: 0.1)
    else:
        discard

    piece.value *= float((1 - 2 * int(piece.color)))
    return piece.value

method isEmpty*(piece: Piece): bool {.base.} =
    return piece.name == '\0'

method copy*(piece: Piece): Piece {.base.} =
    return Piece(
        color:  piece.color,
        name:   piece.name,
        value:  piece.value,
        reach:  piece.reach,
        moved:  piece.moved
    )
