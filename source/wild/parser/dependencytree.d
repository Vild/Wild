module wild.parser.dependencytree;

/+

Processor --> Target         //Processor is compiled before used
Target    --> Processor      //Target needs processor to compile
Target    --> FileNode       //Target need file to compile
FileNode  --> Target         //A target can generate file


+/

import std.variant : Algebraic;
import relationlist;
import wild.frontend.frontend;
import std.string : strip;

alias Node = Algebraic!(Processor, Target, FileNode);
struct FileNode {
  string filename;
  bool always;
}


class DependencyTree {
public:
  this(Frontend frontend) {
    this.frontend = frontend;
    nodes = new RelationList!Node();

    foreach (string name, Target target; frontend.Targets) {
      import std.array : split;
      auto entry = AddTarget(target);

      if (auto child = target.command in frontend.Processors)
        entry.AddChild(AddProcessor(*child), false);
      else
        entry.AddChild(AddFile(FileNode(target.command, false)), false);

      string[] inputs = target.input.strip.split(" ");
      foreach (input; inputs) {
        input = input.strip;
        if (!input.length)
          continue;
        if (auto child = input in frontend.Targets) //Add a file node with a
                                                    //target attached
          entry.AddChild(AddFile(FileNode(input, child.always)).AddChild(AddTarget(*child), false), false);
        else
          entry.AddChild(AddFile(FileNode(input, false)), false);
      }
    }

    foreach (string name, Processor processor; frontend.Processors) {
      import std.array : split;
      auto entry = AddProcessor(processor);

      if (auto child = processor.command in frontend.Targets)
        entry.AddChild(AddTarget(*child), false);
      else
        entry.AddChild(AddFile(FileNode(processor.command, false)), false);
    }


  }

  void MakeDotGraph(string file) {
    import std.stdio : File;
    File fp = File(file, "w");
		fp.writefln("digraph test {");
		fp.writefln("\tfontname=\"Tewi\";");
		foreach(entry; nodes) {
      import std.array : replace;
			fp.writefln("\tL_%s [label=\"%s\"];", entry.ID, entry.Value.toString().replace("\\", "\\\\").replace("\"", "\\\""));
			foreach(parent; entry.GetParents())
				fp.writefln("\tL_%s -> L_%s;", parent.ID, entry.ID);
		}
		fp.writefln("}");
		fp.close();
  }

  RelationEntry!Node GetProcessor(string name) {
    if (auto id = "p_"~name in lookup)
      return nodes.Values[*id];
    return null;
  }
  RelationEntry!Node GetTarget(string name) {
    if (auto id = "t_"~name in lookup)
      return nodes.Values[*id];
    return null;
  }
  RelationEntry!Node GetFile(string name) {
    if (auto id = "f_"~name in lookup)
      return nodes.Values[*id];
    return null;
  }

  @property RelationList!Node Nodes() { return nodes; }

private:
  Frontend frontend;

  RelationList!Node nodes;
  ulong[string] lookup;

  RelationEntry!Node AddFile(FileNode f) {
    if (auto id = "f_"~f.filename in lookup)
      return nodes.Values[*id];

    auto entry = nodes.Add(Node(f));
    lookup["f_"~f.filename] = entry.ID;
    return entry;
  }

  RelationEntry!Node AddTarget(Target t) {
    if (auto id = "t_"~t.output in lookup)
      return nodes.Values[*id];

    auto entry = nodes.Add(Node(t));
    lookup["t_"~t.output] = entry.ID;
    return entry;
  }

  RelationEntry!Node AddProcessor(Processor p) {
    if (auto id = "p_"~p.command in lookup)
      return nodes.Values[*id];

    auto entry = nodes.Add(Node(p));
    lookup["p_"~p.command] = entry.ID;
    return entry;
  }
}
