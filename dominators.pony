use "collections"

/*
  // see A Simple, Fast Dominance Algorithm by Keith D. Cooper, Timothy J. Harvey, and Ken Kennedy
	// http://www.hipersoft.rice.edu/grads/publications/dom14.pdf

	for all nodes, b /* initialize the dominators array */
		doms[b] ← Undefined
	doms[start node] ← start node
	Changed ← true
	while (Changed)
		Changed ← false
		for all nodes, b, in reverse postorder (except start node)
			new idom ← first (processed) predecessor of b /* (pick one) */
			for all other predecessors, p, of b
				if doms[p] ≠ Undefined /* i.e., if doms[p] already calculated */
					new idom ← intersect(p, new idom)
			if doms[b] ≠ new idom
				doms[b] ← new idom
				Changed ← true

	function intersect(b1, b2) returns node
		finger1 ← b1
		finger2 ← b2
		while (finger1 ≠ finger2)
			while (finger1 < finger2)
				finger1 = doms[finger1]
			while (finger2 < finger1)
				finger2 = doms[finger2]
		return finger1
 */

/*
	Dominator frontier

	for all nodes, b
		if the number of predecessors of b ≥ 2
			for all predecessors, p, of b
			runner ← p
			while runner ≠ doms[b]
				add b to runner’s dominance frontier set
				runner = doms[runner]
*/

/*
 * Reverse post order: https://en.wikipedia.org/wiki/Depth-first_search#Vertex_orderings
 * Reverse post order produces a topological sort of the graph.
 */

interface Graph[N]
	fun root(): this->N
	fun succ(n: N): Iterator[this->N]

primitive Traversal

	fun nop[N]():{(N)} iso^=> {(n:N) => None} iso

	fun depth_first[N: Any #share](g: Graph[N] box
		, pre: {(N)} = {(n:N) => None} ref
		, post: {(N)} = {(n:N) => None} ref
	) =>
		let visited: SetIs[N] = SetIs[N]
		_depth_first[N](g,g.root(),visited,pre,post)

	fun _depth_first[N: Any #share](g: Graph[N] box
		, curr: N
		, visited: SetIs[N]
		, pre: {(N)}
		, post: {(N)}
	) =>
		if visited.contains(curr) then return end // skip if visisted
		visited.add(curr)
		pre(curr)
		for n in g.succ(curr) do
			_depth_first[N](g,n,visited,pre,post)
		end
		post(curr)

	fun tsort[N: Any #share](g: Graph[N] val): Array[N] iso^ =>
		recover iso
			let visited: SetIs[N] = SetIs[N]
			let t: Array[N] ref = Array[N]
			_depth_first_tsort[N](g, g.root(), visited, t)
			// we perform an explicit in place reverse, rather than repeated 'unshift' that will probably cause a memcpy
			t.reverse()
		end

	fun _depth_first_tsort[N: Any #share](g: Graph[N] box
		, curr: N
		, visited: SetIs[N]
		, sorted: Array[N]
	) =>
		if visited.contains(curr) then return end // skip if visisted
		visited.set(curr)
		for n in g.succ(curr) do
			_depth_first_tsort[N](g,n,visited,sorted)
		end
		// post order visit with push (pending later reverse)
		sorted.push(curr)

interface RGraph[N: Any ref]
	fun ref root(): N
	fun ref succ(n: N): Iterator[N]

interface RIndexable
	fun ref id(): USize => 0
	fun ref index(i: USize): USize => 0

class RTraversal

	fun ref tsort[N: Any ref](g: RGraph[N], reverse: Bool = false): Array[N] =>
		let visited: SetIs[N] = SetIs[N]
		let t: Array[N] = Array[N]
		_depth_first_tsort[N](g, g.root(), visited, t)
		// we perform an explicit in place reverse, rather than repeated 'unshift' that will probably cause a memcpy
		if reverse then t else t.reverse() end

	fun ref _depth_first_tsort[N: Any ref](g: RGraph[N]
		, curr: N
		, visited: SetIs[N]
		, sorted: Array[N]
	) =>
		if visited.contains(curr) then return end // skip if visisted
		visited.set(curr)
		for n in g.succ(curr) do
			_depth_first_tsort[N](g,n,visited,sorted)
		end
		// post order visit with push (pending later reverse)
		sorted.push(curr)

class RPredecessors

	fun ref predecessors[N: Any ref](g: RGraph[N]): (Array[N], Array[Array[USize]]) =>
		"""
		Takes a graph and produces an ordered mapping to the predecessors indexed in post order.
		"""
		let nodes: Array[N] = Array[N](0)
		let pre: Array[Array[USize]] = Array[Array[USize]](0)
		let root: N = g.root()
		match root
		| (let r: RIndexable) =>
			""" Use node local storage for indicies if available. """
			let loops: Array[(N,USize)] = Array[(N,USize)]
			_pre_indexable[N](g, root, 0, nodes, pre, loops)
		| (let r: N) =>
			""" Use a visited map if the nodes can not hold indicies. """
			let visited: MapIs[N,(USize|None)] = MapIs[N,(USize|None)]
			let loops: Array[(N,USize)] = Array[(N,USize)]
			_pre_visisted[N](g, root, nodes, pre, visited, loops)
			// now fix loops
			for (to_n,from_idx) in loops.values() do
				try
					match visited(to_n)?
					| (let to_idx: USize) =>
						pre(to_idx)?.push(from_idx)
					else
						None // hmmm, we should have resolved indicies for all nodes.
					end
				else
					None // hmmm, we should have visited all nodes, so acces to 'visited' and 'pre' should not fail
				end
			end
		end
		(nodes,pre)

	fun ref _pre_indexable[N: Any ref](g: RGraph[N]
		, curr: N
		, index: USize
		, nodes: Array[N]
		, pre: Array[Array[USize]]
		, loops: Array[(N,USize)]
	): (None | USize) =>
		""" Walks the graph, keeping track of visits nodes themselves. """
		// TODO
		None

	fun ref _pre_visisted[N: Any ref](g: RGraph[N]
		, curr: N
		, nodes: Array[N]
		, pre: Array[Array[USize]]
		, visited: MapIs[N,(USize|None)]
		, loops: Array[(N,USize)]
		): (None | USize) =>
		""" Walks the graph, keeping track of visits in a seperate set. """
		try
			// skip if visited
			return visited(curr)?
		end

		visited.update(curr, None) // mark as visited (but we don't know the index yet)
		// visit the successors and keep track of their indicies
		let posti: Array[USize] = Array[USize]
		let postn: Array[N] = Array[N]
		for n in g.succ(curr) do
			match _pre_visisted[N](g,n,nodes,pre,visited,loops)
			| (let idx: USize) =>
				// record the index of the visited dependency so that
				// its predecessor list can be update later on
				posti.push(idx)
			| None =>
				// darn, we detected a loop. That is, we have reached a node that
				// has already been visited, but it has not yet been assigned an index
				postn.push(n)
			end
		end
		// this node will claim the next available index
		let index = nodes.size()
		// record the actual index for this node now that we know the value
		visited.update(curr, index)
		// record the mapping from the index to this node
		nodes.push(curr)
		// create an empty predecessor list for this node
		pre.push(Array[USize](1))
		// now that we know the index of this node, we can
		// update the predecessors list in the successors of this node
		for n in posti.values() do
			try
				// all successors have been visited and would have created
				// their predecessor arrays already.
				let p: Array[USize] = pre(n)? // so, this should not fail
				p.push(index)
			end
		end
		for n in postn.values() do
			// we will need to resolve this loop afterwards
			loops.push((n, index))
		end
		// return this nodes assigned index
		index

primitive Dominators

	fun gendom(predecessors_by_postorder: Array[Array[USize]] box): Array[USize] ? =>
		"""
		Calculate the dominator tree for a graph based on post order predecessors.

		Index `i` contains the predecessors of node `i`
		Nodes are number in post order i.e.:
		- node `0` is the first leaf node reached,
		- and node `n-1` is the root node where `n` is the total number of nodes.

		In order to traverse the nodes in reverse order we then simply start from n-1.

		The function may throw an error if the predecessor is inconsistent.
		"""

		let node_count: USize = predecessors_by_postorder.size()

		// initialize the dominators array to undefined
		// we use max_value rather than (USize | None) in order to avoid copying the array in order to return Array[USize]
		let undef: USize = USize.max_value()
		let doms: Array[USize] = Array[USize].init(undef, node_count)

		// initialise the dominators for the start node
		let start_node: USize = node_count - 1
		doms(start_node)? = start_node

		// build the dominator tree
		var pass: USize = 0
		var changed: Bool = true
		while changed do
			changed = false
			// Traverse nodes in reverse postorder, which means starting at node node_count and working backwards
			var b: USize = node_count
			repeat
				// simple move to the next reverse postorder index
				b = b - 1

				// skip processing of the start node
				if b == start_node then continue end

				let predecessors: Array[USize] box = predecessors_by_postorder(b)?
				// Now pick any predecessor that has already been processed in this change iteration.
				// Because b is following a reverse postorder there must be at least one predecessor that was already visited.
				// But this does not imply that all predecessors have already been visited, so find one with a greater index
				// value than the node, b, we are currently considering.
				// (we can improve the performance by requiring that predecessors are reverse sorted - and then pick the first
				// one)
				let predecessors_count = predecessors.size()
				var k: USize = 0
				var new_idom: USize = 0
				while k < predecessors_count do
					new_idom = predecessors(k)?
					if new_idom > b then break end // yay, found a preprocessed predecessor
					k = k + 1
				end

				// for all other predecessors, p, of b
				var j: USize = 0
				while j < predecessors.size() do
					if j == k then j = j + 1; continue end // skip the predecessor that was used when initialising new_idom
					let p: USize = predecessors(j)?
					let dp = doms(p)?
					if (dp != undef) then
						// i.e., if doms[p] already calculated
						new_idom = _intersect(doms, p, new_idom, undef)?
					end

					j = j + 1
				end
				if doms(b)? != new_idom then
					doms(b)? = new_idom
					changed = true
				end

			until b == 0 end // use repeat-until to avoid accidental wrap-around on 0-1 = USize.max_value()
		end
		doms

	fun _intersect(doms: Array[USize], b1: USize, b2: USize, undef: USize): USize ? =>
		var finger1 = b1
		var finger2 = b2
		while (finger1 != finger2) do
			while (finger1 < finger2) do
				finger1 = doms(finger1)?
				if finger1 == undef then error end // stop loop - probably bad predecessor data
			end
			while (finger2 < finger1) do
				finger2 = doms(finger2)?
				if finger2 == undef then error end // stop loop - probably bad predecessor data
			end
		end
		finger1
