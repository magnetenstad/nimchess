
type Pos* = array[2, int]

type Board*[width, height: static[int], T] = object
    data*: array[width * height, T]

type
    Piece* = object
        color*: bool
        name*: char
        value*: float
        reach*: int
        moved*: bool
