module Wild.Frontend.Wild.Parser.Statement.ImportStatement;
import Wild.Frontend.Wild.Parser.Statement;

class ImportStatement : Statement {
public:
	this(Parser parser, KeywordToken keyword, ValueToken value) {
		super(parser);
		this.keyword = keyword;
		this.value = value;
	}

	@property KeywordToken Keyword() {
		return keyword;
	}

	@property ValueToken Value() {
		return value;
	}

	override JSONValue toJson() {
		//dfmt off
		return JSONValue([
			"class" : JSONValue(typeof(this).classinfo.name),
			"super" : super.toJson,
			"keyword" : keyword.toJson,
			"value" : value.toJson
		]);
		//dfmt on
	}

private:
	KeywordToken keyword;
	ValueToken value;
}
