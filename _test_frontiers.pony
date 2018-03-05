/**
 * Pony Graph Library
 * Copyright (c) 2018 - Stewart Gebbie. Licensed under the MIT licence.
 * vim: set ts=2 sw=0:
 */
use "ponytest"
use "itertools"

actor FrontierTests is TestList

	new create(env: Env) =>
		PonyTest(env, this)

	new make() =>
		None

	fun tag tests(test: PonyTest) =>
		test(_TestFrontiers)

class iso _TestFrontiers is UnitTest
	"""Tests building a dominance frontier."""

	fun name(): String => "graph:domfront"

	fun ref apply(h: TestHelper) ? =>
		let graph: TanujGraph ref = TanujGraph
		(let dnodes: Array[String ref], let dpre: Array[Array[USize]]) = RPredecessors.predecessors[String ref](graph)
		let doms: Array[USize] = Dominators.gendom(dpre)?
		let frontiers: Array[Array[USize]] = Frontiers.genfront(dpre, doms)?
		// TODO test result
