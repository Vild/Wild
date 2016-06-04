module Wild.Frontend.Wild.Lexer.Token.OperatorToken;

import Wild.Frontend.Wild.Lexer.Token;

enum OperatorType {
	CurlyBracketOpen, // {
	CurlyBracketClose, // }
	BracketOpen, // (
	BracketClose, // )
	SquareBracketOpen, // [
	SquareBracketClose, // ]

	AddAssign, //+=
	Assign, //=
	Comma, //,

	Concat, //+
}

class OperatorToken : Token {
public:
	this(Lexer lexer, size_t start, size_t end, size_t column, OperatorType type) {
		super(lexer, start, end, column);
		this.type = type;
	}

	@property OperatorType Type() {
		return type;
	}

	bool isType(OperatorType type) {
		return this.type == type;
	}

	override JSONValue toJson() {
		//dfmt off
		return JSONValue([
			"class" : JSONValue(typeof(this).classinfo.name),
			"super" : super.toJson,
			"type" : type.toJson
		]);
		//dfmt on
	}

private:
	OperatorType type;
}
