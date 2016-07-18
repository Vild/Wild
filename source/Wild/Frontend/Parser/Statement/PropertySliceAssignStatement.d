module Wild.Frontend.Parser.Statement.PropertySliceAssignStatement;
import Wild.Frontend.Parser.Statement;

class PropertySliceAssignStatement : Statement {
public:
	this(Parser parser, PropertyToken property, ValueToken id, Statement value) {
		super(parser);
		this.property = property;
		this.id = id;
		this.value = value;
	}

	@property PropertyToken Property() {
		return property;
	}

	@property ValueToken ID() {
		return id;
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
			"id" : id.toJson,
			"value" : value.toJson
		]);
		//dfmt on
	}

private:
	PropertyToken property;
	ValueToken id;
	Statement value;
}
