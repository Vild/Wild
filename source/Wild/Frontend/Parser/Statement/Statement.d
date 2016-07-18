module Wild.Frontend.Parser.Statement.Statement;
import Wild.Frontend.Parser.Statement;

class Statement {
public:
	this(Parser parser) {
		this.parser = parser;
	}

	@property Parser TheParser() {
		return parser;
	}

	@property bool NeedEndToken() {
		return true;
	}

	JSONValue toJson() {
		//dfmt off
		return JSONValue([
			"class" : JSONValue(typeof(this).classinfo.name)
		]);
		//dfmt on
	}

	override string toString() {
		return toJson.toString;
	}

protected:
	Parser parser;
}
