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
	""" Utility for computing the dominance frontiers of elements in a directed graph. """

	fun genfront(
		  predecessors_by_postorder: Array[Array[USize]] box
		, dominators_by_postorder: Array[USize]): Array[Array[USize]] ? =>
		"""
		Calculate the dominator tree for a graph based on post order predecessors and using
		the previously computed dominators.

		Where the predecessor array is populated as follows:
			- Index `i` contains the predecessors of node `i`
			- Nodes are numbered in post order i.e.:
				- node `0` is the first leaf node reached,
				- and node `n-1` is the root node where `n` is the total number of nodes.
		And the dominator is populated as:
			- Entries are numbered in post order
			- Entry `i` contains the post order index of the immediate dominator of node `i`

		The function may throw an error if the predecessors are inconsistent, or the dominators are inconsisent.

		The output is an array for every node that contains the indecies of the elements in the dominator frontier
		of the corresponding element.
		"""

		let frontiers: Array[Array[USize]] = Array[Array[USize]](predecessors_by_postorder.size())

		// create empty frontier sets
		var f: USize = 0
		while f < dominators_by_postorder.size() do
			frontiers.push(Array[USize](0))
			f = f + 1
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
						// (note, we need to check for duplicates)
						let r: Array[USize] = frontiers(runner)?
						if not r.contains(b) then r.push(b) end
						// move along
						runner = dominators_by_postorder(runner)?
					end
					pi = pi + 1
				end
			end
			b = b + 1
		end
		frontiers
