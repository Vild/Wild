module Wild.Frontend.Parser.Statement.SymbolStatement;
import Wild.Frontend.Parser.Statement;

class SymbolStatement : Statement {
public:
	this(Parser parser, SymbolToken symbol) {
		super(parser);
		this.symbol = symbol;
	}

	@property SymbolToken Symbol() {
		return symbol;
	}

	override JSONValue toJson() {
		//dfmt off
		return JSONValue([
			"class": JSONValue(typeof(this).classinfo.name),
			"super": super.toJson,
			"symbol": symbol.toJson
		]);
		//dfmt on
	}

private:
	SymbolToken symbol;
}
