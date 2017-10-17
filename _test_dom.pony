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
		test(_TestGenerateDominatorsLarger)

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

	fun assert_arrays_eq[N](h: TestHelper, expected: Array[N], actual: Array[N]): Bool =>
		// test array equality
		let esize: USize = expected.size()
		let asize: USize = actual.size()
		h.assert_eq[USize](esize, asize, "Array sizes differ")
		var eq = esize == asize
		let si = Iter[N](actual.values())
		let xi = Iter[N](expected.values())
		for (s,x) in si.zip[N](xi) do
			if s isnt x then
				match (s,x)
				| (let s': Stringable, let x': Stringable) =>
					h.fail("Expected " + x'.string() + " but was " + s'.string())
				else
					h.fail("Expected element and actual element differ")
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

class iso _TestGenerateDominatorsDiamond is UnitTest
	"""Tests building a dominator tree."""

	fun name(): String => "graph:domtree:diamond"

	fun ref apply(h: TestHelper) ? =>

		// build predecessors in postorder
		let pre: Array[Array[USize] val] val = recover val
			[as Array[USize] val:
				recover val [as USize: 1;2 ] end // d = 0
				recover val [as USize: 3   ] end // c = 1
				recover val [as USize: 3   ] end // b = 2
				recover val [as USize:     ] end // a = 3
			]
		end
		ArrayHelper.assert_arrays_eq[USize](h, [as USize: 3;3;3;3]
			, Dominators.gendom(pre)?)

class iso _TestGenerateDominatorsLarger is UnitTest
	"""Tests building a dominator tree."""

	fun name(): String => "graph:domtree:larger"

	fun ref apply(h: TestHelper) ? =>

		// build predecessors in reverse post order
		let pre: Array[Array[USize] val] val = recover val
			[as Array[USize] val:
				recover val [as USize: 1;10;9;8 ] end // I ; 0  ; K F G J ; 1 10 9 8
				recover val [as USize: 3;0      ] end // K ; 1  ; H I     ; 3 0
				recover val [as USize: 7;3      ] end // E ; 2  ; B H     ; 7 3
				recover val [as USize: 2;4      ] end // H ; 3  ; E L     ; 2 4
				recover val [as USize: 5        ] end // L ; 4  ; D       ; 5
				recover val [as USize: 7;6      ] end // D ; 5  ; A B     ; 7 6
				recover val [as USize: 7;12     ] end // A ; 6  ; B R     ; 7 12
				recover val [as USize: 12       ] end // B ; 7  ; R       ; 12
				recover val [as USize: 9        ] end // J ; 8  ; G       ; 9
				recover val [as USize: 11       ] end // G ; 9  ; C       ; 11
				recover val [as USize: 11       ] end // F ; 10 ; C       ; 11
				recover val [as USize: 12       ] end // C ; 11 ; R       ; 12
				recover val [as USize: 1        ] end // R ; 12 ; K       ; 1
			]
		end

		let doms: Array[USize] = Dominators.gendom(pre)?
		ArrayHelper.array_print(h.env, doms, "doms")
		ArrayHelper.assert_arrays_eq[USize](h,
				//         0  1  2  3  4  5  6  7  8  9  10 11 12
				[as USize: 12;12;12;12; 5;12;12;12; 9;11;11;12;12]
			, doms)

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
