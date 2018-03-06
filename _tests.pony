/**
 * Pony Graph Library
 * Copyright (c) 2017 - Stewart Gebbie. Licensed under the MIT licence.
 * vim: set ts=2 sw=0:
 */
use "ponytest"
use "itertools"

actor Main is TestList
	new create(env: Env) =>
		try
			if (env.args.size() == 2) and (env.args(1)? == "demo") then
				let demo = DomDemo(env)
			else
				PonyTest(env, this)
			end
		else
			env.err.print("Bad command line arguments")
			env.exitcode(1)
		end

	new make() =>
		None

	fun tag tests(test: PonyTest) =>
		DominatorTests.make().tests(test)
		FrontierTests.make().tests(test)

// -- demo

actor DomDemo

	new create(env: Env) => None

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
