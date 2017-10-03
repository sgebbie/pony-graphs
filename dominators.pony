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
 * Reverse post order products a topological sort of the graph.
 */

interface Graph[N]
	fun root(): N
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
		visited.add(curr)
		for n in g.succ(curr) do
			_depth_first_tsort[N](g,n,visited,sorted)
		end
		// post order visit with push (pending later reverse)
		sorted.push(curr)


primitive Dominators

	fun gendom(
		predecessors_by_reverse_postorder: Array[Array[USize] val] val
		/* index 0 contains the predecessors of node 0, where node 0
		 * is the first node when sorting nodes in reverse postorder */
	)? =>

		let node_count: USize = predecessors_by_reverse_postorder.size()

		/* initialize the dominators array to undefined */
		let undef: USize = USize.max_value() /* we use max_value rather than (USize | None) in order to avoid building an array copy in order to return Array[USize] */
		let doms: Array[USize] = Array[USize](node_count)
		var d: USize = 0
		while d < node_count do doms(d)? = undef end

		// initialise the dominators for the start node
		let start_node: USize = 0
		doms(start_node)? = start_node

		// build the dominator tree
		var changed: Bool = true
		while changed do
			changed = false
			var b: USize = 0
			while b < node_count do
				// Traverse nodes in reverse postorder.
				// But because the predecessors are already sorted by reverse post order,
				// this means we simply count from 0 to node_count.

				if b == start_node then continue end

				let predecessors: Array[USize] val = predecessors_by_reverse_postorder(b)?
				var new_idom: USize = predecessors(0)? /* pick any one - at least one must exist since this is not the start node */
				var j: USize = 1 /* for all other predecessors, p, of b */
				while j < predecessors.size() do
					let p: USize = predecessors(j)?
					match doms(p)?
					| (let dp: USize) => /* i.e., if doms[p] already calculated */
						new_idom = _intersect(doms, p, new_idom)?
					end
				end
				if doms(b)? != new_idom then
					doms(b)? = new_idom
					changed = true
				end
			end

			// simple move to the next reverse postorder index
			b = b + 1
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
