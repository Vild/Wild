module Wild.Frontend.Lexer.Token.ValueToken;

import Wild.Frontend.Lexer.Token;

enum ValueType {
	Null,
	String,
	ExpandableString,
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

		static if (is(T == string)) {
			if (type == ValueType.String)
				return lexer.Data[start + 1 .. end - 1];
			else if (type == ValueType.ExpandableString)
				return lexer.Data[start + 2 .. end - 1];
			else if (type == ValueType.Command)
				return lexer.Data[start + 1 .. end];
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
