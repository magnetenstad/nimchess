import tables

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

type
    Piece* = object
        color*: bool
        name*: char
        value*: float
        reach*: int
        moved*: bool

method toString*(piece: Piece): string {.base.} =
    return piece.name & $int(piece.color)

method evaluate*(piece: var Piece): float {.base.} =
    piece.value = float((1 - 2 * int(piece.color))) *
        (pieceValues.getOrDefault(piece.name) + 
        float(piece.reach) * reachFactor[piece.name])
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
