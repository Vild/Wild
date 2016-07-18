module Wild.AST.Block.Block;

import Wild.AST;

class Block : Base {
public:
	this(Block parent) {
		super(parent);
	}

	~this() {
		variables.destroy;
		properties.destroy;
	}

	Variable GetVariable(string name) {
		if (auto _ = name in variables)
			return *_;
		return null;
	}

	Property GetProperty(PropertyName name) {
		if (auto _ = name in properties)
			return *_;
		return null;
	}

	Block AddVariable(Variable variable) {
		variables[variable.Name] = variable;
		return this;
	}

	Block AddProperty(Property property) {
		properties[property.Name] = property;
		return this;
	}

protected:
	Variable[string] variables;
	Property[PropertyName] properties;

}
