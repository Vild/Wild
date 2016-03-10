module Wild.Frontend.Wild.WildFrontend;

import Wild.Frontend.Frontend;
import Wild.Frontend.Wild.Lexer.Lexer;
import Wild.Frontend.Wild.Parser.Parser;

class WildFrontend : Frontend {
public:
	this(string file) {
		import std.file : readText;
		import std.stdio;
		import std.string;

		super();
		string text = readText(file);
		if (text[0 .. 2] == "#!")
			text = text[text.indexOf('\n') .. $];
		Lexer lexer = new Lexer(text);
		scope (exit)
			lexer.destroy;

		File flex = File(file[0 .. $] ~ ".lex.json", "w");
		scope (exit)
			flex.close();
		flex.writeln("[");
		foreach (idx, token; lexer.Tokens)
			flex.write((idx ? ",\n" : "") ~ token.toString);
		flex.writeln("\n]");

		Parser parser = new Parser(lexer);

		File fpar = File(file[0 .. $] ~ ".par.json", "w");
		scope (exit)
			fpar.close();
		fpar.writeln("[");
		foreach (idx, token; parser.Root.List)
			fpar.writeln((idx ? ",\n" : "") ~ token.toString);
		fpar.writeln("\n]");
	}

private:
}
