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
		(let dnodes: Array[String ref], let dpre: Array[Array[USize]]) =
			RPredecessors.predecessors[String ref](graph)
		let doms: Array[USize] = Dominators.gendom(dpre)?
		let frontiers: Array[Array[USize]] = Frontiers.genfront(dpre, doms)?
		h.env.out.print("dnodes.size() = " + dnodes.size().string())
		h.env.out.print("dpre.size() = " + dpre.size().string())
		h.env.out.print("doms.size() = " + doms.size().string())
		h.env.out.print("frontiers.size() = " + frontiers.size().string())
		// TODO test result
		var bi: USize = 0
		while bi < frontiers.size() do
			let b = frontiers(bi)?
			let bn: String ref = dnodes(bi)?
			var fi: USize = 0
			while fi < b.size() do
				let f = b(fi)?
				let fn: String ref = dnodes(f)?
				h.env.out.print(bi.string() +"="+bn.string()+" :: "+f.string()+"="+fn.string())
				fi = fi + 1
			end
			bi = bi + 1
		end
