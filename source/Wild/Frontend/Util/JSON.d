module Wild.Frontend.Util.JSON;

import std.json;
import Wild.Frontend.Parser.Statement;
import Wild.Frontend.Lexer.Token;

JSONValue toJson(T)(T[] arr) if (is(T : Statement) || is(T : Token) || is(T : ConcatData)) {
	JSONValue ret = parseJSON(`[]`);
	foreach (obj; arr)
		ret.array ~= obj.toJson();
	return ret;
}

JSONValue toJson(T)(T obj) if (is(T == enum)) {
	import std.traits;
	import std.format;

	foreach (i, e; EnumMembers!T)
		if (obj == e)
			return JSONValue(__traits(allMembers, T)[i]);

	return JSONValue(format("cast(%s)%d", T.stringof, cast(OriginalType!T)obj));
}

JSONValue toJson(T)(T obj) if (is(T == ConcatData)) {
	if (auto _ = obj.peek!KeywordToken)
		return _.toJson;
	else if (auto _ = obj.peek!ValueToken)
		return _.toJson;
	else
		assert(0, "You forgot to update the ast.util.json.toJson, silly!");
}
