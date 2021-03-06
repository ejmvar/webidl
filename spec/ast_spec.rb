require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe WebIDL::Ast do

  #
  # modules
  #

  it "creates a module" do
    result = parse(fixture("empty_module.idl")).build

    result.should be_kind_of(Array)
    result.size.should == 1

    result.first.should be_kind_of(WebIDL::Ast::Module)
    result.first.qualified_name.should == "::gui"
  end

  it "creates a module with a typedef" do
    mod = parse(fixture("module_with_typedef.idl")).build.first

    mod.definitions.should be_kind_of(Array)

    typedef = mod.definitions.first
    typedef.should be_kind_of(WebIDL::Ast::TypeDef)

    typedef.type.should == 'DOMString'
    typedef.name.should == 'string'
    typedef.qualified_name.should == '::gui::string'
  end

  it "creates a module with an extended attribute (no args)" do
    mod = parse(fixture("module_with_xattr_no_arg.idl")).build.first
    mod.should be_kind_of(WebIDL::Ast::Module)

    xattrs = mod.extended_attributes
    xattrs.size.should == 1

    xattrs.first.should be_kind_of(WebIDL::Ast::ExtendedAttribute)
    xattrs.first.name.should == 'OverrideBuiltins'
  end

  it "creates a module with extended attribute (two args)" do
    mod = parse(fixture("module_with_xattr_two_args.idl")).build.first
    mod.should be_kind_of(WebIDL::Ast::Module)

    xattrs = mod.extended_attributes
    xattrs.size.should == 1

    xattr = xattrs.first

    xattr.should be_kind_of(WebIDL::Ast::ExtendedAttribute)
    xattr.name.should == 'Constructor'

    xattr.args.size.should == 2
    xattr.args.should be_kind_of(Array)
    xattr.args.each { |a| a.should be_kind_of(WebIDL::Ast::Argument)  }
  end

  it "creates a module with extended attribute (named args)" do
    mod = parse(fixture("module_with_xattr_named_args.idl")).build.first
    mod.should be_kind_of(WebIDL::Ast::Module)

    xattrs = mod.extended_attributes
    xattrs.should be_kind_of(Array)

    xattr = xattrs.first
    xattr.should be_kind_of(Array) # TODO: review this

    xattr.first.should == 'NamedConstructor'
    xattr.last.should be_kind_of(WebIDL::Ast::ExtendedAttribute)
  end

  it "creates a module with extended attribute (ident)" do
    mod = parse(fixture("module_with_xattr_ident.idl")).build.first
    mod.should be_kind_of(WebIDL::Ast::Module)

    xattrs = mod.extended_attributes
    xattrs.should be_kind_of(Array)

    xattr = xattrs.first
    xattr.should be_kind_of(Array) # TODO: review this

    xattr.first.should == 'PutForwards'
    xattr.last.should == "name"
  end

  it "creates a module with extended attribute (scoped name)" do
    mod = parse(fixture("module_with_xattr_scoped.idl")).build.first
    mod.should be_kind_of(WebIDL::Ast::Module)

    xattrs = mod.extended_attributes
    xattrs.should be_kind_of(Array)

    xattr = xattrs.first
    xattr.should be_kind_of(Array) # TODO: review this

    xattr.first.should == 'Prefix'
    xattr.last.should be_kind_of(WebIDL::Ast::ScopedName)
  end

  #
  # interfaces
  #

  it "creates an empty interface" do
    result = parse(fixture("empty_interface.idl")).build

    result.should be_kind_of(Array)
    result.size.should == 1

    interface = result.first
    interface.should be_kind_of(WebIDL::Ast::Interface)
    interface.name.should == "System"
  end

  it "creates an interface with members" do
    interface = parse(fixture("interface_with_members.idl")).build.first
    interface.should be_kind_of(WebIDL::Ast::Interface)

    interface.members.first.should be_kind_of(WebIDL::Ast::Operation)
  end

  it "creates an interface with stringifier members" do
    interface = parse(fixture("interface_with_stringifiers.idl")).build.first
    interface.should be_kind_of(WebIDL::Ast::Interface)

    interface.members.first.should be_kind_of(WebIDL::Ast::Attribute)
    interface.members.first.should be_stringifier

    interface.members.last.should be_kind_of(WebIDL::Ast::Operation)
    interface.members.last.should be_stringifier
  end

  it "creates an interface with inheritance" do
    interface = parse(fixture("interface_with_inheritance.idl")).build.last
    interface.inherits.should_not be_empty
    interface.inherits.first.qualified_name.should == "::foo"
  end

  it "creates an exception with inheritance" do
    exception = parse(fixture("exception_with_inheritance.idl")).build.last
    exception.inherits.should_not be_empty
    exception.inherits.first.name.should == "NotFoundException"
  end

  it "creates an interface with an array type member" do
    interface = parse(fixture("interface_with_array_member.idl")).build.first
    interface.should be_kind_of(WebIDL::Ast::Interface)

    attr = interface.members.first
    attr.should be_kind_of(WebIDL::Ast::Attribute)

    attr.type.should be_kind_of(WebIDL::Ast::Type)
    attr.type.name.should == :UnsignedShortArray
  end

  it "creates a framework from the example in the WebIDL spec" do
    mod = parse(fixture("framework.idl")).build.first
    mod.definitions.size.should == 4
    mod.definitions.map { |e| e.class}.should == [
      WebIDL::Ast::TypeDef,
      WebIDL::Ast::Exception,
      WebIDL::Ast::Interface,
      WebIDL::Ast::Module
    ]

    inner_mod = mod.definitions[3]
    inner_mod.name.should == 'gui'
    inner_mod.qualified_name.should == '::framework::gui'

    interface = inner_mod.definitions[0]
    interface.name.should == 'TextField'
    interface.qualified_name.should == '::framework::gui::TextField'
    interface.members.first.qualified_name.should == '::framework::gui::TextField::const' # or should it?
  end


  #
  # various
  #

  it "creates an exception" do
    interface = parse(fixture("module_with_exception.idl")).build.first
    ex        = interface.definitions.first

    ex.name.should == "FrameworkException"
    ex.qualified_name.should == '::framework::FrameworkException'
    ex.members.size.should == 2

    xattr = ex.extended_attributes
    xattr.first.name.should == "Supplemental"

    first, last = ex.members

    first.should be_kind_of(WebIDL::Ast::Const)
    first.name.should == "ERR_NOT_FOUND"
    first.qualified_name.should == '::framework::FrameworkException::ERR_NOT_FOUND'
    first.type.should be_kind_of(WebIDL::Ast::Type)
    first.type.name.should == :Long
    first.value.should == 1

    last.should be_kind_of(WebIDL::Ast::Field)
    last.type.should be_kind_of(WebIDL::Ast::Type)
    last.type.name.should == :Long
    last.name.should == "code"
  end


  it "creates an attribute" do
    interface = parse(fixture("interface_with_attribute.idl")).build.first
    first, last = interface.members

    first.should be_kind_of(WebIDL::Ast::Attribute)
    first.name.should == 'const'

    last.should be_kind_of(WebIDL::Ast::Attribute)
    last.name.should == 'value'
    last.type.name.should == :DOMString
    last.type.should be_nullable
  end

  it "creates a static operation" do
    interface = parse(fixture("interface_with_static_operation.idl")).build.first
    interface.members.first.should be_static
  end

  it "creates an implements statement" do
    mod = parse(fixture("module_with_implements_statement.idl")).build.first

    mod.definitions.first.should be_kind_of(WebIDL::Ast::Interface)

    impls = mod.definitions.last
    impls.should be_kind_of(WebIDL::Ast::ImplementsStatement)
    impls.implementor.should == "::foo::bar"
    impls.implementee.should == "::foo::baz"
  end

  it "builds an AST from the HTML5 spec" do
    parse(fixture("html5.idl")).build
  end

end
