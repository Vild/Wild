module Wild.Frontend.Parser.Statement.PropertyAddAssignStatement;
import Wild.Frontend.Parser.Statement;

class PropertyAddAssignStatement : Statement {
public:
	this(Parser parser, PropertyToken property, Statement value) {
		super(parser);
		this.property = property;
		this.value = value;
	}

	@property PropertyToken Property() {
		return property;
	}

	@property Statement Value() {
		return value;
	}

	override JSONValue toJson() {
		//dfmt off
		return JSONValue([
			"class" : JSONValue(typeof(this).classinfo.name),
			"super" : super.toJson,
			"property" : property.toJson,
			"value" : value.toJson
		]);
		//dfmt on
	}

private:
	PropertyToken property;
	Statement value;
}
