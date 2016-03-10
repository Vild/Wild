module Wild.Frontend.Wild.Parser.Statement.CommandStatement;
import Wild.Frontend.Wild.Parser.Statement;

class CommandStatement : Statement {
public:
	this(Parser parser, ValueToken value) {
		super(parser);
		this.value = value;
	}

	@property override bool NeedEndToken() {
		return false;
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
