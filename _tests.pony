/**
 * Pony Graph Library
 * Copyright (c) 2017 - Stewart Gebbie. Licensed under the MIT licence.
 * vim: set ts=2 sw=0:
 */
use "ponytest"

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
