module Wild.AST.Base;

import Wild.AST;

class Base {
public:
	this(Block parent) {
		this.parent = parent;
	}

	@property Block Parent() {
		return parent;
	}

protected:
	Block parent;
}
