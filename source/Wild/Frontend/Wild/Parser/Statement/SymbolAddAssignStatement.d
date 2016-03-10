module Wild.Frontend.Wild.Parser.Statement.SymbolAddAssignStatement;
import Wild.Frontend.Wild.Parser.Statement;

class SymbolAddAssignStatement : Statement {
public:
	this(Parser parser, SymbolToken symbol, Statement value) {
		super(parser);
		this.symbol = symbol;
		this.value = value;
	}

	@property SymbolToken Symbol() {
		return symbol;
	}

	@property Statement Value() {
		return value;
	}

	override JSONValue toJson() {
		//dfmt off
		return JSONValue([
			"class" : JSONValue(typeof(this).classinfo.name),
			"super" : super.toJson,
			"symbol" : symbol.toJson,
			"value" : value.toJson
		]);
		//dfmt on
	}

private:
	SymbolToken symbol;
	Statement value;
}