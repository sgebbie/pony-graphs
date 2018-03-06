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

		// output the results
		/*
		h.env.out.print("dnodes.size() = " + dnodes.size().string())
		h.env.out.print("dpre.size() = " + dpre.size().string())
		h.env.out.print("doms.size() = " + doms.size().string())
		h.env.out.print("frontiers.size() = " + frontiers.size().string())
		ArrayHelper.dump(h, dnodes, frontiers)
		*/

		// expected frontiers
		let front: Array[Array[USize]] = [as Array[USize]:
			[as USize: 3 ]     // 0=E H
			[as USize: 2 ]     // 1=I K
			[as USize: 1 ]     // 2=K I
			[as USize: 0;2 ]   // 3=H E;K
			[as USize: 3 ]     // 4=L H
			[as USize: 3 ]     // 5=D H
			[as USize: 5 ]     // 6=A D
			[as USize: 0;5;6 ] // 7=B E;D;A
			[as USize: 1 ]     // 8=F I
			[as USize: 1 ]     // 9=J I
			[as USize: 1 ]     // 10=G I
			[as USize: 1 ]     // 11=C I
			[as USize: ]       // 12=R
		]

		ArrayHelper.assert_arrays_eqc[Array[USize]](h, front, frontiers, {
			(h: TestHelper, lhs: Array[USize], rhs: Array[USize]): Bool =>
				ArrayHelper.assert_arrays_eq[USize](h,lhs,rhs) }
			)
