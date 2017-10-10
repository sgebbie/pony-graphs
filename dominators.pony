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


primitive Dominators

	fun gendom(predecessors_by_postorder: Array[Array[USize] val] val
		/* Index i contains the predecessors of node i
		 * Nodes are number in post order i.e.:
		 *   - node 0 is the first leaf node reached,
		 *   - and node n-1 is the root node where n is the total number of nodes.
		 *
		 * In order to traverse the nodes in reverse order we then simply start from 0.
		 */
	): Array[USize] ? =>

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
			// Traverse nodes in reverse postorder, when means starting at node node_count and working backwards
			var b: USize = node_count
			repeat
				// simple move to the next reverse postorder index
				b = b - 1

				// But because the predecessors are already sorted by reverse post order,
				// this means we simply count from 0 to node_count.

				if b == start_node then continue end // (except for the start node)

				let predecessors: Array[USize] val = predecessors_by_postorder(b)?
				// Now pick any predecessor that has already been processed in this change iteration.
				// Because we b is following a reverse postorder there must be a predecessor that was already visited,
				// but this will not necessarily hold true for all predecessors, so find one with a greater index value.
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
					if j == k then j = j + 1; continue end // skip the predecessor used when initialising new_idom
					let p: USize = predecessors(j)?
					let dp = doms(p)?
					if (dp != undef) then
						// i.e., if doms[p] already calculated
						new_idom = _intersect(doms, p, new_idom)?
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

	fun _intersect(doms: Array[USize], b1: USize, b2: USize): USize ? =>
		var finger1 = b1
		var finger2 = b2
		while (finger1 != finger2) do
			while (finger1 < finger2) do
				finger1 = doms(finger1)?
			end
			while (finger2 < finger1) do
				finger2 = doms(finger2)?
			end
		end
		finger1
