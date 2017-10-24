/**
 * Pony Graph Library
 * Copyright (c) 2017 - Stewart Gebbie. Licensed under the MIT licence.
 * vim: set ts=2 sw=0:
 */
use "ponytest"
use "itertools"

actor DominatorTests is TestList

	new create(env: Env) =>
		PonyTest(env, this)

	new make() =>
		None

	fun tag tests(test: PonyTest) =>
		test(_TestTopologicalSort)
		test(_TestGenerateDominatorsDiamond)
		test(_TestGenerateDominatorsLargerPredecessors)
		test(_TestGenerateDominatorsLargerSuccessors)
		test(_TestGeneratePredecessorsDiamond)
		test(_TestGeneratePredecessorsLarger)

class iso _TestTopologicalSort is UnitTest
	"""Tests sorting a graph topologically. """

	new iso create() => None

	fun name(): String => "graph:tsort"

	fun tear_down(h: TestHelper) => None

	fun ref apply(h: TestHelper) =>
		h.assert_true(true)
		let trv: RTraversal = RTraversal
		let g: DiamondGraph = DiamondGraph
		let sorted: Array[String ref] = trv.tsort[String ref](g)
		let expected: Array[String ref] = [as String ref: g.a; g.c; g.b; g.d]

		// for s in sorted.values() do h.env.out.>write(s.clone()).>write(";") end h.env.out.print("")

		// test array equality
		ArrayHelper.assert_arrays_eq[String ref](h, expected, sorted)

primitive ArrayHelper

	fun assert_arrays_eq[N](h: TestHelper, expected: Array[N], actual: Array[N], loc: SourceLoc = __loc): Bool =>
		// test array equality
		let locs: String = loc.method() + ":" + loc.line().string()
		let esize: USize = expected.size()
		let asize: USize = actual.size()
		h.assert_eq[USize](esize, asize, "Array sizes differ: " + locs)
		var eq = esize == asize
		let si = Iter[N](actual.values())
		let xi = Iter[N](expected.values())
		for (s,x) in si.zip[N](xi) do
			if s isnt x then
				match (s,x)
				| (let s': Stringable, let x': Stringable) =>
					h.fail("Expected " + x'.string() + " but was " + s'.string() + ": " + locs)
				else
					h.fail("Expected object element and actual element differ: " + locs)
				end
				eq = false
				break
			end
		end
		h.assert_true(eq)
		eq

	fun assert_arrays_eqc[N: Any #read](h: TestHelper, expected: Array[N], actual: Array[N], eval: {(TestHelper,N,N): Bool}, loc: SourceLoc = __loc): Bool =>
		// test array equality
		let locs: String = loc.method() + ":" + loc.line().string()
		let esize: USize = expected.size()
		let asize: USize = actual.size()
		h.assert_eq[USize](esize, asize, "Array sizes differ: " + locs)
		var eq = esize == asize
		let si = Iter[N](actual.values())
		let xi = Iter[N](expected.values())
		for (s,x) in si.zip[N](xi) do
			if not eval(h,s,x) then
				match (s,x)
				| (let s': Stringable, let x': Stringable) =>
					h.fail("Expected " + x'.string() + " but was " + s'.string() + ": " + locs)
				else
					h.fail("Expected array element and actual element differ: " + locs)
				end
				eq = false
				break
			end
		end
		h.assert_true(eq)
		eq

	fun array_print(env: Env, doms: Array[USize], label: (String|None) = None) =>
		match label
		| (let l: String) =>
			env.out.>write(l).write(" = [")
		else
			env.out.write("[")
		end
		for d in doms.values() do
			env.out.>write(" ").>write(d.string())
		end
		env.out.print(" ]")

	fun dump(h: TestHelper, dnodes: Array[String ref], dpre: Array[Array[USize]]) =>

		var idx: USize = 0
		h.env.out.write(">> ")
		while idx < dnodes.size() do
			try
				h.env.out.write("(" + idx.string() + " ⇒ " + dnodes(idx)? + ") ")
			end
			idx = idx + 1
		end
		h.env.out.print("<<")

		h.env.out.print("[")
		for p in dpre.values() do
			h.env.out.write("  [ ")
			for n in p.values() do
				h.env.out.>write(n.string()).>write(" ")
			end
			h.env.out.print("]")
		end
		h.env.out.print("]")

class iso _TestGenerateDominatorsDiamond is UnitTest
	"""Tests building a dominator tree."""

	fun name(): String => "graph:domtree:diamond"

	fun ref apply(h: TestHelper) ? =>

		// build predecessors in postorder
		let pre: Array[Array[USize]] =
			[as Array[USize]:
				[as USize: 1;2 ] // d = 0
				[as USize: 3   ] // c = 1
				[as USize: 3   ] // b = 2
				[as USize:     ] // a = 3
			]
		ArrayHelper.assert_arrays_eq[USize](h, [as USize: 3;3;3;3]
			, Dominators.gendom(pre)?)

class iso _TestGenerateDominatorsLargerPredecessors is UnitTest
	"""Tests building a dominator tree from predecessors."""

	fun name(): String => "graph:domtree:larger"

	fun ref apply(h: TestHelper) ? =>

		// build predecessors in reverse post order
		let pre: Array[Array[USize]] =
			[as Array[USize]:
				[as USize: 1;10;9;8 ] // I ; 0  ; K F G J ; 1 10 9 8
				[as USize: 3;0      ] // K ; 1  ; H I     ; 3 0
				[as USize: 7;3      ] // E ; 2  ; B H     ; 7 3
				[as USize: 2;4      ] // H ; 3  ; E L     ; 2 4
				[as USize: 5        ] // L ; 4  ; D       ; 5
				[as USize: 7;6      ] // D ; 5  ; A B     ; 7 6
				[as USize: 7;12     ] // A ; 6  ; B R     ; 7 12
				[as USize: 12       ] // B ; 7  ; R       ; 12
				[as USize: 9        ] // J ; 8  ; G       ; 9
				[as USize: 11       ] // G ; 9  ; C       ; 11
				[as USize: 11       ] // F ; 10 ; C       ; 11
				[as USize: 12       ] // C ; 11 ; R       ; 12
				[as USize: 1        ] // R ; 12 ; K       ; 1
			]

		let doms: Array[USize] = Dominators.gendom(pre)?
		// ArrayHelper.array_print(h.env, doms, "doms")
		ArrayHelper.assert_arrays_eq[USize](h,
				//         0  1  2  3  4  5  6  7  8  9  10 11 12
				//         I  K  E  H  L  D  A  B  J  G  F  C  R
				[as USize: 12;12;12;12; 5;12;12;12; 9;11;11;12;12]
			, doms)

class iso _TestGenerateDominatorsLargerSuccessors is UnitTest
	"""Tests building a dominator tree from a graph described as successors."""

	fun name(): String => "graph:domtree:larger"

	fun ref apply(h: TestHelper) ? =>

		let graph: TanujGraph ref = TanujGraph
		let rpre: RPredecessors ref = RPredecessors
		(let dnodes: Array[String ref], let dpre: Array[Array[USize]]) = rpre.predecessors[String ref](graph)
		// ArrayHelper.dump(h,dnodes,dpre)
		let doms: Array[USize] = Dominators.gendom(dpre)?
		// ArrayHelper.array_print(h.env, doms, "doms")
		ArrayHelper.assert_arrays_eq[USize](h,
				//         0  1  2  3  4  5  6  7  8  9  10 11 12
				//         E  I  K  H  L  D  A  B  F  J  G  C  R
				[as USize: 12;12;12;12; 5;12;12;12;11;10;11;12;12]
			, doms)

class iso _TestGeneratePredecessorsDiamond is UnitTest
	"""Tests building a predecessor map."""

	fun name(): String => "graph:predecessors:diamond"

	fun ref apply(h: TestHelper) =>

		let diamond: DiamondGraph ref = DiamondGraph

		// expected predecessors in postorder
		let pre: Array[Array[USize]] = [as Array[USize]:
				[as USize: 1;2 ] // d = 0
				[as USize: 3   ] // b = 1
				[as USize: 3   ] // c = 2
				[as USize:     ] // a = 3
		]
		// expected node map in postorder
		let nodes: Array[String ref] = [as String ref:
				diamond.d
				diamond.b
				diamond.c
				diamond.a
		]
		let rpre: RPredecessors ref = RPredecessors
		(let dnodes: Array[String ref], let dpre: Array[Array[USize]]) = rpre.predecessors[String ref](diamond)

		// ArrayHelper.dump(h,dnodes,dpre)

		ArrayHelper.assert_arrays_eq[String ref](h, nodes, dnodes)

		// ArrayHelper.assert_arrays_eq[Array[USize]](h, pre, dpre)
		ArrayHelper.assert_arrays_eqc[Array[USize]](h, pre, dpre, {
			(h: TestHelper, lhs: Array[USize], rhs: Array[USize]): Bool =>
				ArrayHelper.assert_arrays_eq[USize](h,lhs,rhs) }
			)

class iso _TestGeneratePredecessorsLarger is UnitTest
	"""Tests building a predecessor map."""

	fun name(): String => "graph:predecessors:larger"

	fun ref apply(h: TestHelper) =>

		let graph: TanujGraph ref = TanujGraph

		// expected predecessors in postorder
		let pre: Array[Array[USize]] = [as Array[USize]:
			[as USize: 3;7 ]
			[as USize: 2;8;9;10 ]
			[as USize: 3;1 ]
			[as USize: 4;0 ]
			[as USize: 5 ]
			[as USize: 6;7 ]
			[as USize: 7;12 ]
			[as USize: 12 ]
			[as USize: 11 ]
			[as USize: 10 ]
			[as USize: 11 ]
			[as USize: 12 ]
			[as USize: 2 ]
		]
		// expected node map in postorder
		let nodes: Array[String ref] = [as String ref:
				graph.e
				graph.i
				graph.k
				graph.h
				graph.l
				graph.d
				graph.a
				graph.b
				graph.f
				graph.j
				graph.g
				graph.c
				graph.r
		]
		let rpre: RPredecessors ref = RPredecessors
		(let dnodes: Array[String ref], let dpre: Array[Array[USize]]) = rpre.predecessors[String ref](graph)

		// ArrayHelper.dump(h,dnodes,dpre)

		ArrayHelper.assert_arrays_eq[String ref](h, nodes, dnodes)

		// ArrayHelper.assert_arrays_eq[Array[USize]](h, pre, dpre)
		ArrayHelper.assert_arrays_eqc[Array[USize]](h, pre, dpre, {
			(h: TestHelper, lhs: Array[USize], rhs: Array[USize]): Bool =>
				ArrayHelper.assert_arrays_eq[USize](h,lhs,rhs) }
			)


class DiamondGraph is RGraph[String ref]

	// A→ B,A→ C,B→ D,C→ D
	// reverse post order: A C B D   or A B C D

	let a: String ref
	let b: String ref
	let c: String ref
	let d: String ref

	new create() =>   // post order numbering
		a = "A".clone() // 3
		b = "B".clone() // 1
		c = "C".clone() // 2
		d = "D".clone() // 0

	fun ref root(): String ref => a

	fun ref succ(n: String ref): Iterator[String ref] =>
		match n
		| a => [as String ref: b;c ].values()
		| b => [as String ref: d   ].values()
		| c => [as String ref: d   ].values()
		| d => [as String ref:     ].values()
		else
			Array[String ref].values()
		end

	fun ref domtreesucc(n: String ref): Iterator[String ref] =>
		match n
		| a => [as String ref: b;c;d].values()
		else
			Array[String ref].values()
		end

class TanujGraph is RGraph[String ref]

	// test data from https://tanujkhattar.wordpress.com/2016/01/11/dominator-tree-of-a-directed-graph/

	let r: String ref
	let a: String ref
	let b: String ref
	let c: String ref
	let d: String ref
	let e: String ref
	let f: String ref
	let g: String ref
	let h: String ref
	let i: String ref
	let j: String ref
	let k: String ref
	let l: String ref

	new create() =>   // post order numbering from 0 ; predecessors
		r = "R".clone() // 12 ; K       ; 1
		a = "A".clone() // 6  ; B R     ; 7 12
		b = "B".clone() // 7  ; R       ; 12
		c = "C".clone() // 11 ; R       ; 12
		d = "D".clone() // 5  ; A B     ; 7 6
		e = "E".clone() // 2  ; B H     ; 7 3
		f = "F".clone() // 10 ; C       ; 11
		g = "G".clone() // 9  ; C       ; 11
		h = "H".clone() // 3  ; E L     ; 2 4
		i = "I".clone() // 0  ; K F G J ; 1 10 9 8
		j = "J".clone() // 8  ; G       ; 9
		k = "K".clone() // 1  ; H I     ; 3 0
		l = "L".clone() // 4  ; D       ; 5

	fun ref root(): String ref => r

	fun ref succ(n: String ref): Iterator[String ref] =>
		match n
		| r => [as String ref: a;b;c  ].values()
		| a => [as String ref: d      ].values()
		| b => [as String ref: a;d;e  ].values()
		| c => [as String ref: f;g    ].values()
		| d => [as String ref: l      ].values()
		| e => [as String ref: h      ].values()
		| f => [as String ref: i      ].values()
		| g => [as String ref: i;j    ].values()
		| h => [as String ref: e;k    ].values()
		| i => [as String ref: k      ].values()
		| j => [as String ref: i      ].values()
		| k => [as String ref: r;i    ].values()
		| l => [as String ref: h      ].values()
		//| n => Array[String ref].values()
		else
			Array[String ref].values()
		end

	fun ref domtreesucc(n: String ref): Iterator[String ref] =>
		match n
		| r => [as String ref: i;k;c;h;e;a;d;b ].values()
		| c => [as String ref: f;g ].values()
		| d => [as String ref: l ].values()
		| g => [as String ref: j ].values()
		else
			Array[String ref].values()
		end
