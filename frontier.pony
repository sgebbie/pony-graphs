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

	fun genfront(
		  predecessors_by_postorder: Array[Array[USize]] box
		, dominators_by_postorder: Array[USize]): Array[Array[USize]] ? =>
			let frontiers: Array[Array[USize]] = Array[Array[USize]](predecessors_by_postorder.size())

			// create empty frontier sets
			var f: USize = 0
			while f < frontiers.size() do
				frontiers.push(Array[USize](0))
			end

			// for all nodes, b
			var b: USize = 0
			while b < frontiers.size() do
				let pre: Array[USize] box = predecessors_by_postorder(b)?
				if pre.size() >= 2 then
					// for all predecessors, p, of b
					var pi: USize = 0
					while pi < pre.size() do
						let p: USize = pre(pi)?
						var runner: USize = p
						while runner != dominators_by_postorder(b)? do
							// add b to the runner's dominance frontier set
							// (hmmm, do we need to check for existance, i.e. will we get duplicates?)
							frontiers(runner)?.push(b)
							// move along
							runner = dominators_by_postorder(runner)?
						end
					end
				end
				b = b + 1
			end
			frontiers