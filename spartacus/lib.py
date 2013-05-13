import itertools

def _def_iter(rolls):
    '''return the rolls then an infinite sequence of 2s to emulate unopposed attack dice'''
    yield from rolls
    yield from itertools.repeat(2)

def score_rolls(attacker, defender):
    '''the arguments are assumed to be sorted in descending order'''
    return sum(1 for a in filter(
        lambda a: a[0] > a[1],
        zip(attacker, _def_iter(defender))
    ))

import unittest

class Test_score_rolls(unittest.TestCase):
    def test_more_attack(self):
        self.assertEqual(score_rolls([6, 3, 2], iter([3])), 2)
    def test_more_defense(self):
        self.assertEqual(score_rolls([4, 1], [6, 3, 2]), 0)
    def test_no_attack(self):
        self.assertEqual(score_rolls(iter([]), iter([1, 2])), 0)
    def test_no_defense(self):
        self.assertEqual(score_rolls([4, 6, 1, 3], []), 3)
    def test_no_dice(self):
        self.assertEqual(score_rolls([], []), 0)

