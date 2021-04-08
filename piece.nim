import tables

const PIECE_VALUES* = {
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
        reach_factor*: float
        moved*: bool

var piece: Piece = Piece()
piece.name = 'P'

method toString*(piece: Piece): string {.base.} =
    return piece.name & $int(piece.color)

method evaluate*(piece: var Piece): float {.base.} =
    piece.value = (PIECE_VALUES.getOrDefault(piece.name) + float(piece.reach) * piece.reach_factor) * float((1 - 2 * int(piece.color)))
    return piece.value

method isEmpty*(piece: Piece): bool {.base.} =
    return piece.name == '\0'

method copy*(p: Piece): Piece {.base.} =
    return Piece(color: p.color, name: p.name, value: p.value, reach: p.reach, reach_factor: p.reach_factor, moved: p.moved)
