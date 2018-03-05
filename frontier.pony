use "collections"

/*
	Dominator frontier:
		The set of all cfg nodes, y, such that b dominates a predecessor of y but does not strictly dominate y.

	for all nodes, b
		if the number of predecessors of b ≥ 2
			for all predecessors, p, of b
			runner ← p
			while runner ≠ doms[b]
				add b to runner’s dominance frontier set
				runner = doms[runner]
*/

primitive Frontiers
