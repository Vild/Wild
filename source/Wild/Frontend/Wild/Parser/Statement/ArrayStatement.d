module Wild.Frontend.Wild.Parser.Statement.ArrayStatement;
import Wild.Frontend.Wild.Parser.Statement;

class ArrayStatement : Statement {
public:
	this(Parser parser) {
		super(parser);
	}

	@property ref Statement[] List() {
		return list;
	}

	override JSONValue toJson() {
		//dfmt off
		return JSONValue([
			"class": JSONValue(typeof(this).classinfo.name),
			"super": super.toJson,
			"list": list.toJson
		]);
		//dfmt on
	}

private:
	Statement[] list;
}