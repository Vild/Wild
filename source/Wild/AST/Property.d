module Wild.AST.Property;

import Wild.AST;

public import Wild.Frontend.Lexer.Token.PropertyToken : PropertyName = PropertyType;

class Property : Base {
public:
	this(Block parent, PropertyName name, string value) {
		super(parent);
		this.name = name;
		this.value = value;
	}

	@property PropertyName Name() {
		return name;
	}

	@property string Value() {
		return value;
	}

private:
	PropertyName name;
	string value;
}
