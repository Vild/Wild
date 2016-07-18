import std.stdio;
import std.getopt;
import std.typetuple;

import Wild.Frontend.Frontend;
import Wild.Parser.DependencyTree;
import Wild.Build.BuildManager;
import Wild.Cache.Cache;

uint verbose;
bool showVersion;
bool clean;
bool force;

enum runState {
	BUILD,
	CLEAN,
	CONFIG,
	HIERARCHY
}

int main(string[] args) {
	runState state = runState.BUILD;

	auto result = getopt(args, config.bundling, config.passThrough, "v|verbose+", "Sets verbose level", &verbose,
			"version", "Shows the version", &showVersion, "c|clean", "Clean after build", &clean, "f|force",
			"Forces the current command", &force);

	if (result.helpWanted) {
		defaultGetoptPrinter(args[0] ~ ": [build|clean|config|hierarchy]", result.options);
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
				args = args[0 .. 1] ~ args[2 .. $];
			else
				args = args[0 .. 1];
		}
	}

	string[] inputs = args[1 .. $];

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
	Frontend frontend = new Frontend(inputs[0]);
	/*DependencyTree depTree = new DependencyTree(frontend);
	BuildManager mgr = new BuildManager(depTree, cache, frontend.Build);
	bool rebuild = cache.Changed(inputs[0]) || force;
	mgr.Build(rebuild);

	if (rebuild)
		cache.Update(inputs[0]);
	cache.Save();*/
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
	Frontend frontend = new Frontend(inputs[0]);
/*	DependencyTree depTree = new DependencyTree(frontend);
	depTree.MakeDotGraph(inputs[0] ~ ".dot");
	import std.process : spawnProcess, wait;

	wait(spawnProcess(["dot", "-Tx11", inputs[0] ~ ".dot"]));*/
	return 0;
}
