import std.stdio;
import utils.getopt;
import std.typetuple;

uint verbose;
bool showVersion;
bool clean;
bool forceClean;

string[] args;

enum runState {
	BUILD,
	CLEAN,
	CONFIG
}

int main(string[] args_) {
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
		}

		if (changed) {
			if (args.length > 2)
				args = args[0..1] ~ args[2 .. $];
			else
				args = args[0..1];
		}
	}

	if (state == runState.BUILD)
		return buildState();
	else if (state == runState.CLEAN)
		return cleanState();
	else if (state == runState.CONFIG)
		return configState();
	else
		assert(0, "UNKNOWN RUNSTATE!");
}

int buildState() {
	writeln("Building project...");

	import wild.io.wildparser : RunTest;
	RunTest();

	if (clean)
		writeln("Cleaning build files...");
	return 0;
}

int cleanState() {
	writeln("Clean up project...");
	return 0;
}

int configState() {
	return -1;
}