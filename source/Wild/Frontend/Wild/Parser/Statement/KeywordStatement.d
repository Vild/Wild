module Wild.Frontend.Wild.Parser.Statement.KeywordStatement;
import Wild.Frontend.Wild.Parser.Statement;

class KeywordStatement : Statement {
public:
	this(Parser parser, KeywordToken keyword) {
		super(parser);
		this.keyword = keyword;
	}

	@property KeywordToken Keyword() {
		return keyword;
	}

	override JSONValue toJson() {
		//dfmt off
		return JSONValue([
			"class" : JSONValue(typeof(this).classinfo.name),
			"super" : super.toJson,
			"keyword" : keyword.toJson
		]);
		//dfmt on
	}

private:
	KeywordToken keyword;
}
