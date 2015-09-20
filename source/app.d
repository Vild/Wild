import std.stdio;
import utils.getopt;
import std.typetuple;

import wild.frontend.frontend;
import wild.frontend.jsonfrontend;
import wild.parser.dependencytree;
import wild.build.buildmanager;
import wild.cache.cache;

uint verbose;
bool showVersion;
bool clean;
bool forceClean;

string[] args;

enum runState {
	BUILD,
	CLEAN,
	CONFIG,
	HIERARCHY
}

int main(string[] args_) {
	import backtrace : install, PrintOptions;
	install(stderr, PrintOptions(2, true, 3, 3, true));

	args = args_;
	runState state = runState.BUILD;

	auto result = getopt(args,
		config.bundling,
		config.passThrough,
		"v|verbose+", "Sets verbose level", &verbose,
		"version", "Shows the verson", &showVersion,
		"c|clean", "Clean after build", &clean,
		"f|force", "Forces clean", &forceClean
		);

	if (result.helpWanted) {
		defaultGetoptPrinter(args[0]~": [build|clean|config]", result.options);
		return 0;
	} else if (showVersion) {
		writeln(args[0], " Version ALPHA!");
		return 0;
	}

	if (args.length > 1) {
		bool changed = false;
		if (args[1] == "build") {
			state = runState.BUILD;
			changed = true;
		} else if (args[1] == "clean") {
			state = runState.CLEAN;
			changed = true;
		} else if (args[1] == "config") {
			state = runState.CONFIG;
			changed = true;
		} else if (args[1] == "hierarchy") {
			state = runState.HIERARCHY;
			changed = true;
		}

		if (changed) {
			if (args.length > 2)
				args = args[0..1] ~ args[2 .. $];
			else
				args = args[0..1];
		}
	}

	string[] inputs = args[1..$];

	if (state == runState.BUILD)
		return buildState(inputs);
	else if (state == runState.CLEAN)
		return cleanState(inputs);
	else if (state == runState.CONFIG)
		return configState(inputs);
	else if (state == runState.HIERARCHY)
		return hierarchyState(inputs);
	assert(0);
}

int buildState(string[] inputs) {
	assert(inputs.length, "You need a build file");
	writefln("Building project...");
	Cache cache = new Cache(".wild-cache");
	Frontend frontend = new JsonFrontend(inputs[0]);
	DependencyTree depTree = new DependencyTree(frontend);
	BuildManager mgr = new BuildManager(depTree, cache, frontend.Build);
	depTree.MakeDotGraph("test.dot");
	mgr.Build();
	cache.Save();
	return 0;
}

int cleanState(string[] inputs) {
	writefln("Clean up project...");
	return 0;
}

int configState(string[] inputs) {
	return -1;
}

int hierarchyState(string[] inputs) {
	assert(inputs.length, "You need a build file");
	Frontend frontend = new JsonFrontend(inputs[0]);
	DependencyTree depTree = new DependencyTree(frontend);
	depTree.MakeDotGraph("test.dot");
	import std.process: spawnProcess, wait;
	wait(spawnProcess(["dot", "-Tx11", "test.dot"]));
	return 0;
}
