module Wild.Frontend.Wild.Parser.Statement.ValueStatement;
import Wild.Frontend.Wild.Parser.Statement;

class ValueStatement : Statement {
public:
	this(Parser parser, ValueToken value) {
		super(parser);
		this.value = value;
	}

	override JSONValue toJson() {
		//dfmt off
		return JSONValue([
			"class" : JSONValue(typeof(this).classinfo.name),
			"super" : super.toJson,
			"value" : value.toJson
		]);
		//dfmt on
	}

private:
	ValueToken value;
}
