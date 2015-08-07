module wild.frontend.jsonfrontend;

import std.json;
import wild.frontend.frontend;
import std.string;
import std.file;
import std.stdio;

class JsonFrontend : Frontend {
public:
  this(string file) {
    super();
    load(file);
    process();
  }

private:
  string[] sources;
  Rule[] rules;
  string[] outputedFiles;

  void load(string file) {
    JSONValue root = parseJSON(readText(file));
    foreach(string key, JSONValue val; root["variables"].object) {
      assert(val.type == JSON_TYPE.STRING);
      AddVariable(key, val.str);
    }

    ResolveVariables();

    foreach(JSONValue val; root["sources"].array) {
      assert(val.type == JSON_TYPE.STRING);
      sources ~= val.str;
    }

    foreach(string key, JSONValue val; root["processors"].object) {
      assert(val.type == JSON_TYPE.OBJECT);
      JSONValue command = val["command"];
      JSONValue arguments = val["arguments"];
      assert(command.type == JSON_TYPE.STRING);
      assert(arguments.type == JSON_TYPE.STRING);

      AddProcessor(key, command.str, arguments.str);
    }

    foreach(string key, JSONValue val; root["phonies"].object) {
      assert(val.type == JSON_TYPE.OBJECT);
      JSONValue processor = val["processor"];
      JSONValue input = val["input"];
      assert(processor.type == JSON_TYPE.STRING);
      assert(input.type == JSON_TYPE.STRING);

      AddTarget(processor.str, key, input.str, true);
      ToBuild(key);
      outputedFiles ~= key;
    }

    foreach(string key, JSONValue val; root["missing"].object) {
      assert(val.type == JSON_TYPE.OBJECT);
      JSONValue processor = val["processor"];
      JSONValue input = val["input"];
      assert(processor.type == JSON_TYPE.STRING);
      assert(input.type == JSON_TYPE.STRING);

      AddTarget(processor.str, key, input.str);
      ToBuild(key);
      outputedFiles ~= key;
    }

    foreach(string key, JSONValue val; root["rules"].object) {
      assert(val.type == JSON_TYPE.OBJECT);
      JSONValue processor = val["processor"];
      JSONValue input = val["input"];
      assert(processor.type == JSON_TYPE.STRING);
      assert(input.type == JSON_TYPE.STRING);

      rules ~= Rule(key, processor.str, input.str);
    }

    foreach(JSONValue val; root["targets"].array) {
      assert(val.type == JSON_TYPE.STRING);
      ToBuild(val.str);
      outputedFiles ~= val.str;
    }

    root.destroy;
  }

  void process() {
    //Rule run #1 - Existing files
    foreach (Rule val; rules) {
      const bool multipleInput = val.input.indexOf('*') != -1;
      const bool multipleOutput = val.name.indexOf('*') != -1;

      if (multipleInput && multipleOutput) {
        const string[] in_ = val.input.split("*");
        assert(in_.length == 2);
        const string inputBasePath = in_[0];
        const string inputExtension = in_[1];

        const string[] out_ = val.name.split("*");
        assert(out_.length == 2);
        const string outputBasePath = out_[0];
        const string outputExtension = out_[1];

        try {
          auto inFiles = dirEntries(inputBasePath, "*" ~ inputExtension, SpanMode.breadth);
          foreach(file; inFiles) {
            const string inFile = file.name;
            const string outFile = outputBasePath ~ inFile[inputBasePath.length .. $ - inputExtension.length] ~ outputExtension;
            AddTarget(val.processor, outFile, inFile);
            outputedFiles ~= outFile;
          }
        } catch (Exception e) {}
      } else if (multipleInput && !multipleOutput) {
        const string[] in_ = val.input.split("*");
        assert(in_.length == 2);
        const string inputBasePath = in_[0];
        const string inputExtension = in_[1];

        try {
          auto inFiles = dirEntries(inputBasePath, "*" ~ inputExtension, SpanMode.breadth);
          string files = "";
          foreach(file; inFiles)
            files ~= " " ~ file.name;
          AddTarget(val.processor, val.name, files);
          outputedFiles ~= val.name;
        } catch (Exception e) {}
      } else if (!multipleInput && !multipleOutput) {
        AddTarget(val.processor, val.name, val.input);
        outputedFiles ~= val.name;
      } else
        assert(0 < 1, "You can't have multiple output for one input!");
    }

    //Rule run #2 - Generated files
    foreach (Rule val; rules) {
      const bool multipleInput = val.input.indexOf('*') != -1;
      const bool multipleOutput = val.name.indexOf('*') != -1;

      if (multipleInput && multipleOutput) {
        const string[] in_ = val.input.split("*");
        assert(in_.length == 2);
        const string inputBasePath = in_[0];
        const string inputExtension = in_[1];

        const string[] out_ = val.name.split("*");
        assert(out_.length == 2);
        const string outputBasePath = out_[0];
        const string outputExtension = out_[1];

        foreach(file; outputedFiles) {
          if (!file.startsWith(inputBasePath) || !file.endsWith(inputExtension))
            continue;
          const string inFile = file;
          const string outFile = outputBasePath ~ inFile[inputBasePath.length .. $ - inputExtension.length] ~ outputExtension;
          AddTarget(val.processor, outFile, inFile);
          outputedFiles ~= outFile;
        }
      } else if (multipleInput && !multipleOutput) {
        const string[] in_ = val.input.split("*");
        assert(in_.length == 2);
        const string inputBasePath = in_[0];
        const string inputExtension = in_[1];

        string files = "";
        foreach(file; outputedFiles) {
          if (!file.startsWith(inputBasePath) || !file.endsWith(inputExtension))
            continue;
          files ~= " " ~ file;
        }
        AddTarget(val.processor, val.name, files);
        outputedFiles ~= val.name;
      }
    }
  }
}

struct Rule {
  string name;
  string processor;
  string input;
}
