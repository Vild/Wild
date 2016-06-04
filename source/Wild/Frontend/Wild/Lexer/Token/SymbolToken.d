module Wild.Frontend.Wild.Lexer.Token.SymbolToken;

import Wild.Frontend.Wild.Lexer.Token;

class SymbolToken : Token {
public:
	this(Lexer lexer, size_t start, size_t end, size_t column) {
		super(lexer, start, end, column);
	}

	@property string Symbol() {
		return lexer.Data[start .. end];
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
