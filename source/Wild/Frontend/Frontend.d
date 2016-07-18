module Wild.Frontend.Frontend;

import Wild.Frontend.Lexer.Lexer;
import Wild.Frontend.Parser.Parser;
import std.path;

class Frontend {
public:
	this(string file) {
		lexAndParse(absolutePath(file));
	}

	~this() {
		foreach (p; parsers)
			p.destroy;
		foreach (l; lexers)
			l.destroy;
	}

private:
	Lexer[string] lexers;
	Parser[string] parsers;
	void lexAndParse(string file) {
		import std.stdio;
		import std.string;
		import std.file : readText;

		if (file in lexers)
			return;

		writeln("[LEXER] Reading: ", file);
		string text = readText(file);
		if (text.length > 2 && text[0 .. 2] == "#!") {
			ptrdiff_t off = text.indexOf('\n');
			if (off >= 0)
				text = text[off .. $];
			else
				text = "";
		}

		writeln("[LEXER] Lexing: ", file);
		Lexer lexer = new Lexer(file, text);
		lexers[file] = lexer;

		/*File flex = File(file ~ ".lex.json", "w");
		scope (exit)
			flex.close();
		flex.writeln("[");
		foreach (idx, token; lexer.Tokens)
			flex.write((idx ? ",\n" : "") ~ token.toString);
		flex.writeln("\n]");*/

		writeln("[PARSER] Parsing: ", file);
		Parser parser = new Parser(file, lexer);
		parsers[file] = parser;

		/*File fpar = File(file ~ ".par.json", "w");
		scope (exit)
			fpar.close();
		fpar.writeln("[");
		foreach (idx, stmt; parser.Root.List)
			fpar.writeln((idx ? ",\n" : "") ~ stmt.toString);
		fpar.writeln("\n]");*/

		import Wild.Frontend.Parser.Statement.ImportStatement;

		foreach (stmt; parser.Root.List)
			if (auto importStmt = cast(ImportStatement)stmt)
				lexAndParse(buildNormalizedPath(dirName(file), importStmt.Value.Extra!string));
	}

}
