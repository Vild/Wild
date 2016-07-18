module Wild.Frontend.Parser.Statement.BlockStatement;
import Wild.Frontend.Parser.Statement;

class BlockStatement : Statement {
public:
	this(Parser parser, TypeToken type) {
		super(parser);
		this.type = type;
	}

	@property ref Statement[] List() {
		return list;
	}

	override JSONValue toJson() {
		//dfmt off
		return JSONValue([
			"class": JSONValue(typeof(this).classinfo.name),
			"super": super.toJson,
			"type": type.toJson,
			"list": list.toJson
		]);
		//dfmt on
	}

private:
	TypeToken type;
	Statement[] list;
}
