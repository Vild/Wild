module wild.build.buildmanager;

import std.parallelism;
import wild.parser.dependencytree;
import wild.frontend.frontend;
import relationlist;
import std.process;
import std.stdio;
import std.c.stdlib : exit;


class BuildManager {
public:
  this(DependencyTree depTree, string[] targets, size_t workers = totalCPUs - 1) {
    this.depTree = depTree;
    this.targets = targets;
    writeln("TARGETS: ", targets);
  }

  void Build() {
    foreach (target; targets)
      build(target);
  }

private:
  DependencyTree depTree;
  string[] targets;
  bool[RelationEntry!Node] hasBuilt;
  bool[string] scriptRun;

  void build(string target) {
    bool traverse(RelationEntry!Node node, bool rebuild = false) {
      if (node in hasBuilt)
        return false;
      else if (auto t = node.Value.peek!Target)
        if (t.input in scriptRun)
          return false;
      if (!rebuild) {
        if (auto f = node.Value.peek!FileNode)
          rebuild = f.always;
        else if (auto t = node.Value.peek!Target)
          rebuild = t.always;
      }

      Processor * p;

      foreach (child; /*parallel*/(node.Children)) {
        if (auto tmp = child.Value.peek!Processor) //Should only have one child
          p = tmp;                                 //That is a processor
        if (traverse(child, rebuild))
          rebuild = true;
      }

      rebuild = true; //TODO: Implements cache check

      if (rebuild)
        if (auto t = node.Value.peek!Target) {
          import std.array : replace, split;
          import std.range: chain;
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
          }

          string extra = t.extra.replace("$in", t.input).replace("$out", t.output);
          writefln("\t\t %s", extra);
          proc = executeShell(extra);
          if (proc.status != 0) {
            writeln("\x1b[31;1m", proc.output, "\x1b[0m");
            exit(0);
          }

          hasBuilt[node] = true;
          if (t.command == "script" || t.command == "shell")
            scriptRun[t.input] = true;
        }

      return rebuild;
    }
    auto root = depTree.GetTarget(target);
    assert(root, "Target '"~target~"' not found!");
    writefln("Starting traversing...");
    traverse(root);
    writefln("Done traversing!");
    //pool.finish(true);
  }
}
