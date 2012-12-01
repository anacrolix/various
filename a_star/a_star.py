def a_star(start, goal, neighbour_nodes, heuristic_cost_estimate, dist_between):
	closedset = set()
	openset = {start}
	came_from = {}

	g_score = {start: 0}
	f_score = {start: g_score[start] + heuristic_cost_estimate(start, goal)}

	while openset:
		current = min((f_score[node], node) for node in openset)[1]
		if current == goal:
			return reconstruct_path(came_from, goal)

		openset.remove(current)
		closedset.add(current)
		for neighbour in neighbour_nodes(current):
			if neighbour in closedset:
				continue
			tentative_g_score = g_score[current] + dist_between(current, neighbour)
			if neighbour not in openset or tentative_g_score <= g_score[neighbour]:
				came_from[neighbour] = current
				g_score[neighbour] = tentative_g_score
				f_score[neighbour] = g_score[neighbour] + heuristic_cost_estimate(neighbour, goal)
				if neighbour not in openset:
					openset.add(neighbour)

def reconstruct_path(came_from, current_node):
	if current_node in came_from:
		for node in reconstruct_path(came_from, came_from[current_node]):
			yield node
	yield current_node
