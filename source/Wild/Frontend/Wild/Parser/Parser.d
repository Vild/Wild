module Wild.Frontend.Wild.Parser.Parser;

import Wild.Frontend.Wild.Lexer.Lexer;
import Wild.Frontend.Wild.Lexer.Token;
import Wild.Frontend.Wild.Parser.Exception;
import Wild.Frontend.Wild.Parser.Statement;
import std.traits : hasMember;
import std.typecons;

class Parser {
public:
	this(string file, Lexer lexer) {
		this.file = file;
		this.lexer = lexer;
		root = new BlockStatement(this, null);
		tokens = lexer.Tokens; //Remove overhead
		run();
		if (!processedAll)
			throw new Exception("\nTODO: haven't processed all tokens");
	}

	@property BlockStatement Root() {
		return root;
	}

private:
	string file;
	Lexer lexer;
	BlockStatement root;
	Token[] tokens;
	bool processedAll = false;

	size_t current = 0;

	void run() {
		import std.stdio;

		writeln("Start with parser!");
		if (!process(root)) {
			stderr.writeln("Failed parsing!");
			return;
		}
		writeln();
		if (current >= tokens.length)
			processedAll = true;

		writeln("End of parser!");
	}

	bool process(BlockStatement curBlockStatement) {
		import std.stdio;

		while (current < tokens.length) {
			write("\rCurrent token: ", current + 1, " out of ", tokens.length);
			Statement stmt = getStatement();
			curBlockStatement.List ~= stmt;
			if (stmt.NeedEndToken)
				match!EndToken;
		}
		return true;
	}

	Statement getStatement() {
		Statement stmt;
		if (auto _ = getBlock())
			stmt = _;
		else if (auto _ = getImport())
			stmt = _;
		else if (auto _ = getConcat())
			stmt = _;
		else if (auto _ = getKeyword())
			stmt = _;
		else if (auto _ = getSymbol())
			stmt = _;
		else if (auto _ = getProperty())
			stmt = _;
		else if (auto _ = getCommand())
			stmt = _;
		else if (auto _ = getValue())
			stmt = _;
		else if (auto _ = getArray())
			stmt = _;
		else
			throw new UnknownStatementException(this, file, tokens, current);

		if (auto _ = getAssignment(stmt))
			stmt = _;
		else if (auto _ = getCall(stmt))
			stmt = _;

		return stmt;
	}

	Statement getBlock() {
		if (!has!TypeToken)
			return null;
		TypeToken type = get!TypeToken[0];

		match!(OperatorToken, OperatorType.CurlyBracketOpen);

		BlockStatement newBlock = new BlockStatement(this, type);

		while (!has!(OperatorToken, OperatorType.CurlyBracketClose)) {
			Statement stmt = getStatement();
			newBlock.List ~= stmt;
			if (stmt.NeedEndToken)
				match!EndToken;
		}

		get!(OperatorToken, OperatorType.CurlyBracketClose);
		return newBlock;
	}

	Statement getImport() {
		if (!has!(KeywordToken, KeywordType.Import))
			return null;

		KeywordToken keyword = get!KeywordToken[0];
		ValueToken value = match!(ValueToken, ValueType.String)[0];

		return new ImportStatement(this, keyword, value);
	}

	Statement getConcat() {
		ConcatData[] data;
		if (has!(KeywordToken, OperatorToken, OperatorType.Concat)) {
			KeywordToken keyword = peek!KeywordToken[0];
			if (!(keyword.isType(KeywordType.In) || keyword.isType(KeywordType.Out)))
				return null;

			data ~= ConcatData(get!KeywordToken[0]);
		} else if (has!(ValueToken, OperatorToken, OperatorType.Concat)) {
			ValueToken value = peek!ValueToken[0];
			if (!value.isType(ValueType.String))
				return null;

			data ~= ConcatData(get!ValueToken[0]);
		} else
			return null;

		while (has!(OperatorToken, OperatorType.Concat)) {
			get!OperatorToken;
			if (has!KeywordToken) {
				KeywordToken keyword = peek!KeywordToken[0];
				if (!(keyword.isType(KeywordType.In) || keyword.isType(KeywordType.Out)))
					throw new UnknownStatementException(this, file, tokens, current);

				data ~= ConcatData(get!KeywordToken[0]);
			} else if (has!ValueToken) {
				ValueToken value = peek!ValueToken[0];
				if (!value.isType(ValueType.String))
					throw new UnknownStatementException(this, file, tokens, current);

				data ~= ConcatData(get!ValueToken[0]);
			} else
				throw new UnknownStatementException(this, file, tokens, current);
		}
		return new ConcatStatement(this, data);
	}

	Statement getKeyword() {
		if (!has!KeywordToken)
			return null;

		return new KeywordStatement(this, get!KeywordToken[0]);
	}

	Statement getSymbol() {
		if (!has!SymbolToken)
			return null;

		return new SymbolStatement(this, get!SymbolToken[0]);
	}

	Statement getProperty() {
		if (!has!PropertyToken)
			return null;

		return new PropertyStatement(this, get!PropertyToken[0]);
	}

	Statement getCommand() {
		if (!has!(ValueToken, ValueType.Command))
			return null;

		return new CommandStatement(this, get!ValueToken[0]);
	}

	Statement getValue() {
		if (!has!ValueToken)
			return null;

		return new ValueStatement(this, get!ValueToken[0]);
	}

	Statement getArray() {
		if (!has!(OperatorToken, OperatorType.SquareBracketOpen))
			return null;
		get!OperatorToken;

		ArrayStatement array = new ArrayStatement(this);

		if (!has!(OperatorToken, OperatorType.SquareBracketClose))
			while (true) {
				Statement stmt = getStatement();
				array.List ~= stmt;
				if (has!(OperatorToken, OperatorType.SquareBracketClose))
					break;
				match!(OperatorToken, OperatorType.Comma);
			}

		get!(OperatorToken, OperatorType.SquareBracketClose);
		return array;
	}

	Statement getAssignment(Statement stmt) {
		Statement result = null;
		if (auto symbolStmt = cast(SymbolStatement)stmt) {
			SymbolToken symbol = symbolStmt.Symbol;
			OperatorToken operator = peek!OperatorToken[0];
			if (!operator)
				return null;

			if (operator.isType(OperatorType.Assign)) {
				get!OperatorToken;
				result = new SymbolAssignStatement(this, symbol, getStatement());
			} else if (operator.isType(OperatorType.AddAssign)) {
				get!OperatorToken;
				result = new SymbolAddAssignStatement(this, symbol, getStatement());
			}
		} else if (auto propertyStmt = cast(PropertyStatement)stmt) {
			PropertyToken property = propertyStmt.Property;
			OperatorToken operator = peek!OperatorToken[0];
			if (!operator)
				return null;

			// Replacing the last statement
			if (operator.isType(OperatorType.Assign)) {
				get!OperatorToken;
				result = new PropertyAssignStatement(this, property, getStatement());
			} else if (operator.isType(OperatorType.AddAssign)) {
				get!OperatorToken;
				result = new PropertyAddAssignStatement(this, property, getStatement());
			} else if (operator.isType(OperatorType.SquareBracketOpen)) {
				get!OperatorToken;
				ValueToken value = match!(ValueToken, ValueType.String)[0];
				match!(OperatorToken, OperatorType.SquareBracketClose);

				if (has!OperatorToken) {
					operator = get!OperatorToken[0];
					if (operator.isType(OperatorType.Assign))
						result = new PropertySliceAssignStatement(this, property, value, getStatement());
					else if (operator.isType(OperatorType.AddAssign))
						result = new PropertySliceAddAssignStatement(this, property, value, getStatement());
				}
			}
		}
		if (result)
			stmt.destroy;
		return result;
	}

	Statement getCall(Statement stmt) {
		auto symbolStmt = cast(SymbolStatement)stmt;
		if (!symbolStmt)
			return null;

		if (!has!(OperatorToken, OperatorType.BracketOpen))
			return null;
		get!OperatorToken;
		Statement[] args;

		if (!has!(OperatorToken, OperatorType.BracketClose))
			while (true) {
				Statement s = getStatement();
				args ~= s;
				if (has!(OperatorToken, OperatorType.BracketClose))
					break;
				match!(OperatorToken, OperatorType.Comma);
			}

		get!(OperatorToken, OperatorType.BracketClose);
		SymbolToken symbol = symbolStmt.Symbol;
		stmt.destroy;
		return new SymbolCallStatement(this, symbol, args);
	}

	bool has(pattern...)() {
		import std.stdio;

		if (current >= tokens.length)
			return false;

		mixin(genericPeekImpl!("return false;", "", pattern));
		return true;
	}

	auto peek(pattern...)() {
		mixin("alias retType = Tuple!(" ~ genericReturnTypeImpl!pattern ~ ");");
		retType ret;

		mixin(genericReturnValueImpl!pattern);
		return ret;
	}

	auto get(pattern...)() {
		auto ret = peek!pattern;
		foreach (i, p; pattern)
			static if (is(p : Token))
				current++;
		return ret;
	}

	auto match(pattern...)() {
		import std.stdio;

		enum code = genericPeekImpl!("throw new ExpectedException!%s(this, file, tokens, current+%d);", "p.stringof, idx", pattern);
		//pragma(msg, code);
		mixin(code);

		return get!pattern;
	}

	static string genericPeekImpl(string onFail, string extraData, pattern...)() {
		//TODO: Rewrite
		import std.string;

		string ret = "";
		int idx = 0;
		foreach (i, p; pattern) {
			static if (is(p : Token)) {
				static if (__traits(compiles, typeof(pattern[i + 1])) && is(typeof(pattern[i + 1]) == enum)) {
					static assert(hasMember!(p, "isType") && __traits(compiles, (cast(p*)null).isType(pattern[i + 1])),
							format("The type '%s' hasn't got a function called isType for the type of '%s'. Please fix!",
								p.stringof, typeof(pattern[i + 1]).stringof));
					mixin(`ret ~= format("if (current+%d >= tokens.length || !cast(%s)tokens[current+%d] || !(cast(%s)tokens[current+%d]).isType(%s.%s)) "~onFail~"\n", idx, p.stringof, idx, p.stringof, idx, typeof(pattern[i+1]).stringof, pattern[i+1].stringof, ` ~ extraData ~ `);`);
				} else
					mixin(
							`ret ~= format("if (current+%d >= tokens.length || !cast(%s)tokens[current+%d]) "~onFail~"\n", idx, p.stringof, idx, `
							~ extraData ~ `);`);
				idx++;
			}
		}

		return ret;
	}

	static string genericReturnTypeImpl(pattern...)() {
		string ret = "";
		foreach (idx, p; pattern) {
			static if (is(p : Token)) {
				static if (idx)
					ret ~= ", ";
				ret ~= p.stringof;
			} else static if (is(typeof(p) : string)) {
				static if (idx)
					ret ~= ", ";
				ret ~= p.stringof;
			}
		}
		return ret;
	}

	static string genericReturnValueImpl(pattern...)() {
		import std.string;

		string ret = "";
		int idx = 0;
		foreach (i, p; pattern) {
			static if (is(p : Token)) {
				ret ~= format("ret[%d] = cast(%s)tokens[current+%d];\n", idx, p.stringof, idx);
				idx++;
			}
		}

		return ret;
	}
}
