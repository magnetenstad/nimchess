import chess
import chess.pgn
import os

dirname = "output/"
for filename in os.listdir(dirname):
  if filename.endswith(".pgn"): continue
  path = dirname + filename
  game = chess.pgn.Game()
  with open(path, "r") as ucifile:
    uci_text = ucifile.read().strip()
    node = game
    for move in uci_text.split(' '):
      node = node.add_variation(chess.Move.from_uci(move))
    with open(path.replace(".an", ".pgn"), "w") as sanfile:
      sanfile.write(str(game))
