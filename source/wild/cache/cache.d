module wild.cache.cache;

import std.file;
import std.json;
import std.datetime : SysTime;
import std.c.time : time_t;

class Cache {
public:
  this(string dbFile) {
    this.dbFile = dbFile;
    load();
  }

  bool Changed(string file) {
    import std.stdio: writeln;
    bool a = Changed_(file);
    if (a)
      writeln("File: ", file, " changed!");
    return a;
  }

  bool Changed_(string file) {
    import std.stdio : writeln;
    time_t * cache = file in files;

    DirEntry f;
    try {
      f = DirEntry(file);
    } catch (FileException e) {
      return false; //Is probably a System file. TODO: Better check
    }

    if (cache is null) {
      files[file] = f.timeLastModified.toUnixTime;
      return true;
    }

    return *cache != f.timeLastModified.toUnixTime;

  }

  void Update(string file) {
    try {
      files[file] = DirEntry(file).timeLastModified.toUnixTime;
    } catch (FileException e) {
      return; //Is probably a System file. TODO: Better check
    }
  }

  void Save() {
    JSONValue root = parseJSON("{}");

    foreach (string file, time_t value; files)
      root.object[file] = JSONValue(value);

    write(dbFile, root.toPrettyString);
  }

private:
  string dbFile;
  time_t[string] files;

  void load() {
    try {
      JSONValue root = parseJSON(readText(dbFile));

      foreach (string file, JSONValue value; root.object)
        files[file] = value.integer;
    } catch(FileException e) {}
  }
}
