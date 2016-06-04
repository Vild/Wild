module Wild.Frontend.Wild.Lexer.Token.KeywordToken;

import Wild.Frontend.Wild.Lexer.Token;

enum KeywordType {
	Changed,
	Always,

	//TODO: Change this to a foreach with input/output
	In,
	Out,

	Import
}

class KeywordToken : Token {
public:
	this(Lexer lexer, size_t start, size_t end, size_t column, KeywordType type) {
		super(lexer, start, end, column);
		this.type = type;
	}

	@property KeywordType Type() {
		return type;
	}

	bool isType(KeywordType type) {
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
	KeywordType type;
}
