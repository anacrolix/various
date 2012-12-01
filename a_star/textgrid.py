#!/usr/bin/env python3

import a_star
import argparse
import math
import operator
import sys

def main():
	parser = argparse.ArgumentParser()
	optns = parser.parse_args()
	start = None
	goal = None
	lines = []
	for y, line in enumerate(line.rstrip('\n') for line in sys.stdin):
		for x, char in enumerate(line):
			pos = x, y
			if char == 'G':
				goal = pos
			elif char == 'S':
				start = pos
		lines.append(line)
	def neighbours(pos):
		for x in range(pos[0]-1, pos[0]+2):
			for y in range(pos[1]-1, pos[1]+2):
				if (x, y) == pos:
					continue
				if y not in range(len(lines)):
					continue
				if x not in range(len(lines[y])):
					continue
				if lines[y][x] not in '. SG':
					continue
				yield x, y
	def estimate_cost(pos, goal):
		return math.sqrt((pos[0]-goal[0])**2 + (pos[1]-goal[1])**2)
	def dist(a, b):
		assert max(map(abs, map(operator.sub, a, b))) == 1
		ret = estimate_cost(a, b)
		if lines[b[1]][b[0]] != '.':
			ret *= 2
		return ret
	path = set(a_star.a_star(start, goal, neighbours, estimate_cost, dist))
	for y, line in enumerate(lines):
		for x, char in enumerate(line):
			print('X' if (x, y) in path and char not in 'SG' else char, end='')
		print()

main()