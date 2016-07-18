module Wild.AST.Variable;

import Wild.AST;

import std.variant;

alias VariableData = Algebraic!(string, Block);

class Variable : Base {
public:
	this(Block parent, string name, VariableData value) {
		super(parent);
		this.name = name;
		this.value = value;
	}

	@property string Name() {
		return name;
	}

	@property VariableData Value() {
		return value;
	}

private:
	string name;
	VariableData value;
}
