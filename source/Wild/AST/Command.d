module Wild.AST.Command;

import Wild.AST;

class Command : Base {
public:
	this(Block parent, string command) {
		super(parent);
		this.command = command;
	}

	@property string Command() {
		return command;
	}

	@property string Needs() {
		import std.string : indexOf;

		auto idx = command.indexOf(' ');
		if (idx)
			return command[0 .. idx];
		else
			return command;
	}

private:
	string command;
}
