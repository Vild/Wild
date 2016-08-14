module Wild.Frontend.Wild.Lexer.Exception;

import Wild.Frontend.Wild.Lexer.Lexer;
import std.string;

abstract class LexerException : Exception {
public:
	this(Lexer lexer, size_t problem, string error) {
		super("");
		import std.string;

		size_t start = problem;
		if (start > 0 && lexer.Data[start] != '\n') {
			while (start > 0 && lexer.Data[start] != '\n')
				start--;
			start++;
		}

		size_t end = lexer.Data.indexOf('\n', problem);
		if (end == -1)
			end = lexer.Data.length - 1;

		size_t[2] problemLine = lexer.GetLinePos(problem);
		char[] problemLocation = new char[problemLine[1]-1];
		for (size_t i = 0; i < problemLine[1] - 1; i++)
			problemLocation[i] = '-';

		while (problem < lexer.Data.length && lexer.Data[problem] != '\n' && lexer.Data[problem] != ' ') {
			problem++;
			problemLocation ~= "^";
		}

		msg = format("%s Problem at %d:%d.\nLine data: %s\n-----------%s\n", error, problemLine[0], problemLine[1],
				lexer.Data()[start .. end], problemLocation);
	}
}

class InvalidTokenException : LexerException {
public:
	this(Lexer lexer, size_t problem) {
		super(lexer, problem, "Invalid token!");
	}
}
