import pytest
from vpf.game_category import classify_game


@pytest.mark.parametrize("game,expected", [
    ("NLH",                           "nlh"),
    ("NLH Bounty",                    "nlh"),
    ("NLH Seniors",                   "nlh"),
    ("NLH Mystery Bounty",            "nlh"),
    ("PLO",                           "plo"),
    ("PLO Bounty ($200)",             "plo"),
    ("PL Big-O",                      "plo"),
    ("O/8",                           "plo"),
    ("Mixed Triple Draw Lowball",     "mixed"),
    ("HORSE",                         "mixed"),
    ("TORSE",                         "mixed"),
    ("8-game",                        "mixed"),
    ("2-7 NL / PL Dbl. draw / Triple Draw", "draw"),
    ("Badugi",                        "draw"),
    ("Triple Triple Draw",            "draw"),
    ("Stud",                          "stud"),
    ("Stud Hi-Lo",                    "stud"),
    ("",                              "other"),
    (None,                            "other"),
    ("Random Promo",                  "other"),
])
def test_classify_game(game, expected):
    assert classify_game(game) == expected
