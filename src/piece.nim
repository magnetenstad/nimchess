import tables

const pieceValues* = {
    'P': 1.0,
    'N': 3.0,
    'B': 3.0,
    'R': 5.0,
    'Q': 10.0,
    'K': 999.0
}.toTable()

type
    Piece* = object
        color*: bool
        name*: char
        value*: float
        reach*: int
        reachFactor*: float
        moved*: bool

method toString*(piece: Piece): string {.base.} =
    return piece.name & $int(piece.color)

method evaluate*(piece: var Piece): float {.base.} =
    piece.value = float((1 - 2 * int(piece.color))) *
        (pieceValues.getOrDefault(piece.name) + 
        float(piece.reach) * piece.reachFactor)
    return piece.value

method isEmpty*(piece: Piece): bool {.base.} =
    return piece.name == '\0'

method copy*(piece: Piece): Piece {.base.} =
    return Piece(
        color:  piece.color,
        name:   piece.name,
        value:  piece.value,
        reach:  piece.reach,
        reachFactor: piece.reachFactor, 
        moved:  piece.moved
    )
