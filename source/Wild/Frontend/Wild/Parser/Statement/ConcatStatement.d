module Wild.Frontend.Wild.Parser.Statement.ConcatStatement;
import Wild.Frontend.Wild.Parser.Statement;
import std.variant;

//Don't forget to update the ast.util.json.toJson function!
alias ConcatData = Algebraic!(KeywordToken, ValueToken);

class ConcatStatement : Statement {
public:
	this(Parser parser, ConcatData[] value) {
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
	ConcatData[] value;
}
