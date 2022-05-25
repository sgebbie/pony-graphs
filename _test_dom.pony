/**
 * Pony Graph Library
 * Copyright (c) 2017 - Stewart Gebbie. Licensed under the MIT licence.
 * vim: set ts=2 sw=0:
 */
use "pony_test"
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
		(let dnodes: Array[String ref], let dpre: Array[Array[USize]]) = RPredecessors.predecessors[String ref](graph)
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
		(let dnodes: Array[String ref], let dpre: Array[Array[USize]]) = RPredecessors.predecessors[String ref](diamond)

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
		(let dnodes: Array[String ref], let dpre: Array[Array[USize]]) = RPredecessors.predecessors[String ref](graph)

		// ArrayHelper.dump(h,dnodes,dpre)

		ArrayHelper.assert_arrays_eq[String ref](h, nodes, dnodes)

		// ArrayHelper.assert_arrays_eq[Array[USize]](h, pre, dpre)
		ArrayHelper.assert_arrays_eqc[Array[USize]](h, pre, dpre, {
			(h: TestHelper, lhs: Array[USize], rhs: Array[USize]): Bool =>
				ArrayHelper.assert_arrays_eq[USize](h,lhs,rhs) }
			)

