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
		test(_TestGenerateDominators)
		test(_TestTopologicalSort)

class iso _TestGenerateDominators is UnitTest
	"""Tests building a dominator tree."""

	new iso create() => None

	fun name(): String => "graph:domtree"

	fun tear_down(h: TestHelper) => None

	fun ref apply(h: TestHelper) =>
		h.assert_true(true)

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
		assert_arrays_eq[String ref](h, expected, sorted)

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


class DiamondGraph is RGraph[String ref]

	// A→ B,A→ C,B→ D,C→ D

	let a: String ref
	let b: String ref
	let c: String ref
	let d: String ref

	new create() =>
		a = "A".clone()
		b = "B".clone()
		c = "C".clone()
		d = "D".clone()

	fun ref root(): String ref => a

	fun ref succ(n: String ref): Iterator[String ref] =>
		match n
		| a => [as String ref: b;c].values()
		| b => [as String ref: d].values()
		| c => [as String ref: d].values()
		| d => Array[String ref].values()
		else
			Array[String ref].values()
		end
