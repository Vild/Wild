module wild.frontend.frontend;

abstract class Frontend {
public:
  this() {
  }

  string ResolveString(string str) {
    import std.stdio : write, writeln;
    string finalStr;
    import std.string : indexOf;
    size_t pos = str.indexOf("${");
    size_t end = str.indexOf('}');
    while (pos != -1) {
      size_t start = pos + 2;
      string name = str[start .. end];

      finalStr ~= str[0 .. pos];
      if (auto var = name in variables)
        finalStr ~= ResolveString(var.value);
      else {
        writeln(name, " could not be found!");
        assert(0);
      }

      str = str[end+1 .. $];
      pos = str.indexOf("${");
      end = str.indexOf('}');
    }

    finalStr ~= str;
    return finalStr;
  }

  ref T Resolve(T)(return ref T type) if (is(T == Variable) || is(T == Processor) || is(T == Target)){
    string add(T)() {
      string ret = "";
      foreach(name; __traits(derivedMembers, T))
        ret ~= "type."~name~" = ResolveString(type."~name~");\n";
      return ret;
    }

    mixin(add!T);
    return type;
  }

  @property Variable[string] Variables() { return variables; }
  @property Processor[string] Processors() { return processors; }
  @property Target[string] Targets() { return targets; }
  @property string[] Build() { return build; }

protected:
  Variable[string] variables;
  Processor[string] processors;
  Target[string] targets;
  string[] build;

  void AddVariable(string name, string value) {
    variables[name] = Variable(name, value);
  }

  void AddProcessor(string name, string command, string arguments) {
    name = ResolveString(name);
    command = ResolveString(command);
    arguments = ResolveString(arguments);
    processors[name] = Processor(name, command, arguments);
  }

  void AddTarget(string processor, string output, string input, bool always, string extra) {
    processor = ResolveString(processor);
    output = ResolveString(output);
    input = ResolveString(input);
    extra = ResolveString(extra);
    targets[output] = Target(processor, output, input, always, extra);
  }

  void ToBuild(string target) {
    build ~= ResolveString(target);
  }

  void ResolveVariables() {
    foreach (string name, Variable v; variables)
      v.value = ResolveString(v.value);
  }
}

struct Variable {
  string name;
  string value;
}

struct Processor {
  string name;
  string command;
  string arguments;
}

struct Target {
  string processor;
  string output;
  string input;
  bool always;
  string extra;
}
