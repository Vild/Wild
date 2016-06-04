module Wild.Frontend.Wild.Parser.Statement.SymbolCallStatement;
import Wild.Frontend.Wild.Parser.Statement;

class SymbolCallStatement : Statement {
public:
	this(Parser parser, SymbolToken symbol, Statement[] arguments) {
		super(parser);
		this.symbol = symbol;
		this.arguments = arguments;
	}

	@property SymbolToken Symbol() {
		return symbol;
	}

	@property Statement[] Arguments() {
		return arguments;
	}

	override JSONValue toJson() {
		//dfmt off
		return JSONValue([
			"class" : JSONValue(typeof(this).classinfo.name),
			"super" : super.toJson,
			"symbol" : symbol.toJson,
			"arguments" : arguments.toJson
		]);
		//dfmt on
	}

private:
	SymbolToken symbol;
	Statement[] arguments;
}
