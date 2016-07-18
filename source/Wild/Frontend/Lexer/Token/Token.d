module Wild.Frontend.Lexer.Token.Token;

import Wild.Frontend.Lexer.Token;
import std.range.primitives;
import std.string;

class Token {
public:
	this(Lexer lexer, size_t start, size_t end, size_t column) {
		this.lexer = lexer;
		this.start = start;
		this.end = end;
		this.column = column;
		this.length = lexer.Data[start .. end].walkLength;
	}

	@property Lexer TheLexer() {
		return lexer;
	}

	@property size_t Start() {
		return start;
	}

	@property size_t End() {
		return end;
	}

	@property size_t Column() {
		return column;
	}

	@property size_t Length() {
		return length;
	}

	JSONValue toJson() {
		//dfmt off
		return JSONValue([
			"class" : JSONValue(typeof(this).classinfo.name),
			"start" : JSONValue(start),
			"end" : JSONValue(end),
			"column" : JSONValue(column),
			"length" : JSONValue(length),
			"data" : JSONValue(lexer.Data[start .. end])
		]);
		//dfmt on
	}

	override string toString() {
		return toJson.toString;
	}

protected:
	Lexer lexer;
	size_t start, end;
	size_t column;
	size_t length;
}
