module Wild.Frontend.Parser.Exception;

import Wild.Frontend.Lexer.Token;
import Wild.Frontend.Parser.Parser;
import std.string;
import Wild.Frontend.Lexer.Lexer;
import std.range;
import std.conv;
import std.path;

/+
pointer = to!string(' '.repeat.take(format("Line %d: ", endPos[0]).length));
			pointer ~= to!string(' '.repeat.take(endPos[1] - 2));
			pointer ~= "^";
+/

abstract class ParserException : Exception {
public:
	this(Parser parser, string file, Token[] tokens, size_t idx, string error, string f = __FILE__, size_t l = __LINE__,
			bool endtoken = false) {
		super("", f, l);

		string linePointer = "";

		if (endtoken) {
			Token token = tokens[idx - 1];
			Lexer lexer = token.TheLexer;
			size_t[2] startPos = lexer.GetLinePos(token.Start);

			size_t lineStart = lexer.GetDataPos([startPos[0], 0]);
			size_t lineEnd = lexer.GetDataPos([startPos[0] + 1, 0]) - 1;
			if (lineStart != 0 && lineEnd == -1)
				lineEnd = lexer.Data.length - 1;

			ulong dif = token.Length - 1;
			string line = format("Line %d: ", startPos[0]);
			linePointer ~= line;
			linePointer ~= lexer.Data[lineStart .. lineEnd];
			linePointer ~= "\n";

			linePointer ~= to!string(' '.repeat.take(line.length + token.Column + token.Length));
			linePointer ~= "^";
			/*
			if (dif > 0)
				linePointer ~= to!string('-'.repeat.take(dif - 1));
			if (dif > 1)
				linePointer ~= "^";*/
			linePointer ~= "\n";
		}

		if (idx >= tokens.length) {
			msg = format("\n%s\nEnd of file!", error);
			return;
		}
		Token token = tokens[idx];
		Lexer lexer = token.TheLexer;
		size_t[2] startPos = lexer.GetLinePos(token.Start);

		size_t lineStart = lexer.GetDataPos([startPos[0], 0]);
		size_t lineEnd = lexer.GetDataPos([startPos[0] + 1, 0]) - 1;
		if (lineStart != 0 && lineEnd == -1)
			lineEnd = lexer.Data.length - 1;

		{
			ulong dif = token.Length - 1;
			string line = format("Line %d: ", startPos[0]);
			linePointer ~= line;
			linePointer ~= lexer.Data[lineStart .. lineEnd];
			linePointer ~= "\n";
			linePointer ~= to!string(' '.repeat.take(line.length + token.Column));
			linePointer ~= "^";

			if (dif > 0)
				linePointer ~= to!string('-'.repeat.take(dif - 1));
			if (dif > 1)
				linePointer ~= "^";
		}

		msg = format("\n%s: %s\nStarting at line %d:%d, ending at %d:%d.\nToken: %s\n%s", relativePath(file), error,
				startPos[0], startPos[1], startPos[0] + token.Length, startPos[1], token, linePointer);
	}

private:

}

class UnknownStatementException : ParserException {
public:
	this(Parser parser, string file, Token[] tokens, size_t idx, string f = __FILE__, size_t l = __LINE__) {
		super(parser, file, tokens, idx - 1, "Unknown statement starting with token: ", f, l);
	}
}

class ExpectedException(expected) : ParserException {
public:
	this(Parser parser, string file, Token[] tokens, size_t idx, string f = __FILE__, size_t l = __LINE__) {
		super(parser, file, tokens, idx, "Expected '" ~ expected.stringof ~ "' got " ~ (idx >= tokens.length ? "EOF"
				: tokens[idx].toString), f, l, is(expected == EndToken));
	}
}
