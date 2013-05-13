from functools import lru_cache, partial
from itertools import product
from collections import Counter

die_range = range(1, 7)
max_dice = 5
dice_count_range = range(1, max_dice + 1)

@lru_cache(maxsize=None)
def all_rolls(num_dice):
    return Counter(tuple(sorted(a, reverse=True)) for a in product(die_range, repeat=num_dice))

def main():
    from lib import score_rolls
    for ATK in dice_count_range:
        for DEF in dice_count_range:
            wounds = [0]*(ATK+1)
            for atk_roll, atk_roll_freq in all_rolls(ATK).items():
                for def_roll, def_roll_freq in all_rolls(DEF).items():
                    wounds[score_rolls(atk_roll, def_roll)] += atk_roll_freq * def_roll_freq
            n = sum(wounds)
            print("ATK", ATK, "DEF", DEF)
            for w, freq in enumerate(wounds):
                print('%d %2.0f%%' % (w, round(100*freq/n)))

if __name__ == '__main__':
    main()