module Wild.Frontend.Wild.Lexer.Token.ValueToken;

import Wild.Frontend.Wild.Lexer.Token;

enum ValueType {
	Null,
	String,
	Command //|
}

class ValueToken : Token {
public:
	this(Lexer lexer, size_t start, size_t end, size_t column, ValueType type) {
		super(lexer, start, end, column);
		this.type = type;
	}

	@property ValueType Type() {
		return type;
	}

	T Extra(T)() {
		import std.conv;
		static if (is(typeof(T) == string)) {
			if (type == ValueType.String || type == ValueType.Command)
				return lexer.Data[start .. end];
			else
				assert(0, "Invalid output type!");
		} else
			assert(0, "Unknown type!");
	}

	bool isType(ValueType type) {
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
	ValueType type;
}