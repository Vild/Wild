module Wild.Frontend.Lexer.Token.EndToken;

import Wild.Frontend.Lexer.Token;

class EndToken : Token {
public:
	this(Lexer lexer, size_t start, size_t end, size_t column) {
		super(lexer, start, end, column);
	}

	override JSONValue toJson() {
		//dfmt off
		return JSONValue([
			"class" : JSONValue(typeof(this).classinfo.name),
			"super" : JSONValue(super.toJson)
		]);
		//dfmt on
	}
}
