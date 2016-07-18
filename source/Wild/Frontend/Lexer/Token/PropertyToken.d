module Wild.Frontend.Lexer.Token.PropertyToken;

import Wild.Frontend.Lexer.Token;

enum PropertyType {
	Name,
	ENV,
	Output,
	Input,
	Build,
	Behavior,
}

class PropertyToken : Token {
public:
	this(Lexer lexer, size_t start, size_t end, size_t column, PropertyType type) {
		super(lexer, start, end, column);
		this.type = type;
	}

	@property PropertyType Type() {
		return type;
	}

	bool isType(PropertyType type) {
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
	PropertyType type;
}
