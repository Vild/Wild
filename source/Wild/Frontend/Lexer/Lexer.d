module Wild.Frontend.Lexer.Lexer;

import Wild.Frontend.Lexer.Exception;
import Wild.Frontend.Lexer.Token;
import std.regex;
import std.array;

class Lexer {
public:
	this(string file, string data) {
		this.file = file;
		this.data = data.replace("\t", " "); //TODO: Fix this silly hack for GetDataPos
		process();
	}

	@property string Data() {
		return data;
	}

	@property Token[] Tokens() {
		return tokens;
	}

	size_t[2] GetLinePos(size_t index) {
		size_t row = 0;
		size_t column = 0;

		if (index >= data.length)
			return [0, 0];

		//Calculate the row and column number for the index
		for (size_t i = 0; i < index; i++)
			if (data[i] == '\n') {
				row++;
				column = 0;
			} else
				column++;

		return [row, column];
	}

	size_t GetDataPos(size_t[2] pos) {
		size_t row = 0;
		size_t column = 0;
		import std.stdio;

		//Calculate the row and column number for the index
		for (size_t i = 0; i < data.length; i++) {
			if (row == pos[0] && column == pos[1])
				return i;
			else if (row > pos[0]) {
				writefln("\nMoved past the point: %s, i: %s, row: %s, column: %s", pos, i, row, column);
				return 0;
			}

			if (data[i] == '\n') {
				row++;
				column = 0;
			} else
				column++;
		}

		writefln("\nPos is out of file: %s", pos);
		return 0;
	}

	string[] Imports() {
		string[] imports;
		for (size_t i = 0; i < tokens.length - 2 /* Needs KeywordToken(KeywordType.Import) ValueToken(ValueType.String) EndToken */ ;
				i++) {
			auto kw = cast(KeywordToken)tokens[i];
			if (!kw || !kw.isType(KeywordType.Import))
				continue;
			i++;

			auto val = cast(ValueToken)tokens[i];
			if (!val || !val.isType(ValueType.String))
				continue;
			i++;

			auto end = cast(EndToken)tokens[i];
			if (!end)
				continue;

			imports ~= val.Extra!string;
		}
		return imports;
	}

private:
	string file;
	string data;
	Token[] tokens;

	size_t current;
	size_t column;

	void process() {
		import std.stdio;

		writeln("Start with lexing!");
		size_t lastCurrent = current;
		while (current < data.length) {
			lastCurrent = current;
			write("\rCurrent token: ", current + 1, " out of ", data.length);
			parseToken();
			if (current == lastCurrent) {
				stderr.writeln("\rFailed to parse token ", current + 1, " --> '", data[current], "'");
				break;
			}
		}
		writeln();
		writeln("End of lexing!");
	}

	void parseToken() {
		if (skipWhitespace()) {
		} else if (skipComments()) {
		} else if (add!(`;`, EndToken)()) {
		} else if (addOperator()) {
		} else if (addValue()) {
		} else if (addKeyword()) {
		} else if (addProperty()) {
		} else if (addType()) {
		} else if (addSymbol()) {
		} else
			throw new InvalidTokenException(this, file, current);
	}

	bool add(alias re, T, args...)(args arg) {
		auto result = matchFirst(data[current .. $], ctRegex!("^" ~ re));
		if (result.empty)
			return false;

		T t = new T(this, current, current + result[0].length, column, arg);
		tokens ~= t;

		current += result[0].length;
		column += t.Length;
		return true;
	}

	bool addKeyword(alias re, T, args...)(string text, args arg) {
		if (text != re)
			return false;

		T t = new T(this, current, current + text.length, column, arg);
		tokens ~= t;
		current += text.length;
		column += t.Length;
		return true;
	}

	bool skipWhitespace() {
		//import core.stdc.ctype : isspace;

		auto isspace = (char c) => c == ' ' || (c - '\t') < 5;

		if (!isspace(data[current]))
			return false;
		while (current < data.length && isspace(data[current])) {
			if (data[current] == '\n')
				column = 0;
			else
				column++;
			current++;
		}
		return true;
	}

	bool skipComments() {
		auto result = matchFirst(data[current .. $], ctRegex!(`^//[^\n]*`));
		if (result.empty) {
			result = matchFirst(data[current .. $], ctRegex!(`^/\*[^(\*/)]*\*/`));
			if (result.empty)
				return false;
		}

		current += result[0].length;
		column += result[0].length;
		return true;
	}

	bool addOperator() {
		if (add!(`\{`, OperatorToken)(OperatorType.CurlyBracketOpen)) {
		} else if (add!(`\}`, OperatorToken)(OperatorType.CurlyBracketClose)) {
		} else if (add!(`\(`, OperatorToken)(OperatorType.BracketOpen)) {
		} else if (add!(`\)`, OperatorToken)(OperatorType.BracketClose)) {
		} else if (add!(`\[`, OperatorToken)(OperatorType.SquareBracketOpen)) {
		} else if (add!(`\]`, OperatorToken)(OperatorType.SquareBracketClose)) {

		} else if (add!(`\+=`, OperatorToken)(OperatorType.AddAssign)) {
		} else if (add!(`=`, OperatorToken)(OperatorType.Assign)) {
		} else if (add!(`,`, OperatorToken)(OperatorType.Comma)) {

		} else if (add!(`\+`, OperatorToken)(OperatorType.Concat)) {
		} else
			return false;
		return true;
	}

	bool addValue() {
		if (add!(`null`, ValueToken)(ValueType.Null)) {
		} else if (add!(`"([^"]|\\")*"`, ValueToken)(ValueType.String)) {
		} else if (add!(`!"([^"]|\\")*"`, ValueToken)(ValueType.ExpandableString)) {
		} else if (add!(`\|[^\n]*`, ValueToken)(ValueType.Command)) {
		} else
			return false;
		return true;
	}

	bool addKeyword() {
		auto result = matchFirst(data[current .. $], ctRegex!(`^[\p{L}_][\p{L}_0123456789]*`));
		if (result.empty)
			return false;
		auto text = result[0];

		if (addKeyword!(`Changed`, KeywordToken)(text, KeywordType.Changed)) {
		} else if (addKeyword!(`Always`, KeywordToken)(text, KeywordType.Always)) {

		} else if (addKeyword!(`In`, KeywordToken)(text, KeywordType.In)) {
		} else if (addKeyword!(`Out`, KeywordToken)(text, KeywordType.Out)) {

		} else if (addKeyword!(`Import`, KeywordToken)(text, KeywordType.Import)) {
		} else
			return false;
		return true;
	}

	bool addProperty() {
		auto result = matchFirst(data[current .. $], ctRegex!(`^[\p{L}_][\p{L}_0123456789]*`));
		if (result.empty)
			return false;
		auto text = result[0];

		if (addKeyword!(`Name`, PropertyToken)(text, PropertyType.Name)) {
		} else if (addKeyword!(`ENV`, PropertyToken)(text, PropertyType.ENV)) {
		} else if (addKeyword!(`Output`, PropertyToken)(text, PropertyType.Output)) {
		} else if (addKeyword!(`Input`, PropertyToken)(text, PropertyType.Input)) {
		} else if (addKeyword!(`Build`, PropertyToken)(text, PropertyType.Build)) {
		} else if (addKeyword!(`Behavior`, PropertyToken)(text, PropertyType.Behavior)) {
		} else
			return false;
		return true;
	}

	bool addType() {
		auto result = matchFirst(data[current .. $], ctRegex!(`^[\p{L}_][\p{L}_0123456789]*`));
		if (result.empty)
			return false;
		auto text = result[0];

		if (addKeyword!(`Project`, TypeToken)(text, TypeType.Project)) {
		} else if (addKeyword!(`Processor`, TypeToken)(text, TypeType.Processor)) {
		} else if (addKeyword!(`Target`, TypeToken)(text, TypeType.Target)) {
		} else if (addKeyword!(`Each`, TypeToken)(text, TypeType.Each)) {
		} else
			return false;
		return true;
	}

	bool addSymbol() {
		auto result = matchFirst(data[current .. $], ctRegex!(`^@[\p{L}\p{So}_][\p{L}\p{So}_0123456789\.]*`));
		if (result.empty)
			return false;
		auto t = new SymbolToken(this, current, current + result[0].length, column);
		tokens ~= t;
		current += result[0].length;
		column += t.Length;
		return true;
	}
}
