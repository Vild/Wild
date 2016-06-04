module Wild.Build.BuildManager;

import std.parallelism;
import Wild.Parser.DependencyTree;
import Wild.Frontend.Frontend;
import Wild.Cache.Cache;
import relationlist;
import std.process;
import std.stdio;
import core.stdc.stdlib : exit;

class BuildManager {
public:
	this(DependencyTree depTree, Cache cache, string[] targets) {
		this.depTree = depTree;
		this.cache = cache;
		this.targets = targets;
	}

	void Build(bool forceRebuild) {
		foreach (target; targets)
			build(target, forceRebuild);
	}

private:
	DependencyTree depTree;
	Cache cache;
	string[] targets;
	bool[RelationEntry!Node] hasBuilt;
	bool[string] scriptRun;

	void build(string target, bool forceRebuild) {
		bool traverse(RelationEntry!Node node, bool rebuild = false) {
			if (node in hasBuilt)
				return false;
			else if (auto t = node.Value.peek!Target)
				if (t.input in scriptRun)
					return false;
			if (auto f = node.Value.peek!FileNode) {
				//if (f.generated)
				//  return false;
				rebuild |= f.always | cache.Changed(f.filename);
			} else if (auto t = node.Value.peek!Target)
				rebuild |= t.always;

			Processor* p = null;

			bool childRebuilt = false;

			foreach (child;  /*parallel*/ (node.Children)) {
				if (auto tmp = child.Value.peek!Processor) //Should only have one child
					p = tmp; //That is a processor
				childRebuilt = traverse(child, rebuild);
			}

			rebuild |= childRebuilt;

			if (rebuild)
				if (auto t = node.Value.peek!Target) {
					import std.array : replace, split;
					import std.range : chain;
					import std.array : array;
					import std.path : dirName;
					import std.file : mkdirRecurse;

					mkdirRecurse(dirName(t.output));
					string args = p.arguments.replace("$in", t.input).replace("$out", t.output);
					writefln("\t %s %s", p.command, args);
					auto proc = executeShell(p.command ~ " " ~ args);
					if (proc.status != 0) {
						writeln("\x1b[31;1m", proc.output, "\x1b[0m");
						exit(0);
					} else
						writeln("\x1b[32;1m", proc.output, "\x1b[0m");

					string extra = t.extra.replace("$in", t.input).replace("$out", t.output);
					writefln("\t\t %s", extra);
					proc = executeShell(extra);
					if (proc.status != 0) {
						writeln("\x1b[31;1m", proc.output, "\x1b[0m");
						exit(0);
					} else
						writeln("\x1b[32;1m", proc.output, "\x1b[0m");

					hasBuilt[node] = true;
					cache.Update(t.output);
					if (t.processor == "script" || t.processor == "shell")
						scriptRun[t.input] = true;
				}

			return rebuild;
		}

		auto root = depTree.GetTarget(target);
		assert(root, "Target '" ~ target ~ "' not found!");
		writefln("Starting traversing...");
		traverse(root, forceRebuild);
		writefln("Done traversing!");
		//pool.finish(true);
	}
}
