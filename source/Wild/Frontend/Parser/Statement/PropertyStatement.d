module Wild.Frontend.Parser.Statement.PropertyStatement;
import Wild.Frontend.Parser.Statement;

class PropertyStatement : Statement {
public:
	this(Parser parser, PropertyToken property) {
		super(parser);
		this.property = property;
	}

	@property PropertyToken Property() {
		return property;
	}

	override JSONValue toJson() {
		//dfmt off
		return JSONValue([
			"class" : JSONValue(typeof(this).classinfo.name),
			"super" : super.toJson,
			"property" : property.toJson
		]);
		//dfmt on
	}

private:
	PropertyToken property;
}
