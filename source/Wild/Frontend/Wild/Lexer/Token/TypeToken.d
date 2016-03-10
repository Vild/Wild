module Wild.Frontend.Wild.Lexer.Token.TypeToken;

import Wild.Frontend.Wild.Lexer.Token;

enum TypeType {
	Project,
	Processor,
	Target
}

class TypeToken : Token {
public:
	this(Lexer lexer, size_t start, size_t end, size_t column, TypeType type) {
		super(lexer, start, end, column);
		this.type = type;
	}

	@property TypeType Type() {
		return type;
	}

	bool isType(TypeType type) {
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
	TypeType type;
}
