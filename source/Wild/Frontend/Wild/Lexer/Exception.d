module Wild.Frontend.Wild.Lexer.Exception;

import Wild.Frontend.Wild.Lexer.Lexer;
import std.string;
import std.path;

abstract class LexerException : Exception {
public:
	this(Lexer lexer, string file, size_t problem, string error) {
		super("");

		long start = problem;
		if (start > 0 && lexer.Data[start] != '\n') {
			while (start > 0 && lexer.Data[start] != '\n')
				start--;
			start++;
		}

		long end = lexer.Data.indexOf('\n', problem);
		if (end == -1)
			end = lexer.Data.length - 1;

		size_t[2] problemLine = lexer.GetLinePos(problem);
		string problemLocation = "";
		for (long i = 0; i < cast(long)problemLine[1] - 1; i++)
			problemLocation ~= "-";

		while (problem < lexer.Data.length && lexer.Data[problem] != '\n' && lexer.Data[problem] != ' ') {
			problem++;
			problemLocation ~= "^";
		}

		msg = format("%s: %s Problem at %d:%d.\nLine data: %s\n-----------%s\n", relativePath(file), error,
				problemLine[0], problemLine[1], lexer.Data()[start .. end], problemLocation);
	}
}

class InvalidTokenException : LexerException {
public:
	this(Lexer lexer, string file, size_t problem) {
		super(lexer, file, problem, "Invalid token!");
	}
}
