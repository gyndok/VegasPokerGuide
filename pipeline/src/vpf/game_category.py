from typing import Literal, Optional

GameCategory = Literal["nlh", "plo", "mixed", "stud", "draw", "other"]


def classify_game(game: Optional[str]) -> GameCategory:
    if not game:
        return "other"
    g = game.upper()
    # Mixed games (check before NLH/PLO since names can contain those tokens)
    if any(tok in g for tok in ("HORSE", "TORSE", "8-GAME", "8 GAME", "MIXED")):
        return "mixed"
    # Draw games
    if any(tok in g for tok in ("BADUGI", "TRIPLE DRAW", "DBL. DRAW", "DBL DRAW", "2-7")):
        return "draw"
    # Stud
    if "STUD" in g:
        return "stud"
    # PLO / Omaha family
    if any(tok in g for tok in ("PLO", "OMAHA", "O/8", "O8", "BIG-O", "BIG O", "PL ")):
        return "plo"
    # NLH last (most permissive)
    if "NLH" in g or "NO LIMIT" in g or g.startswith("NL "):
        return "nlh"
    return "other"
