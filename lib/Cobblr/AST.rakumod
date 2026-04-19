unit module Cobblr::AST;

class Program {
    has @.decls;  # Array of Decl
}

role Decl { }

class Function does Decl {
    has Str $.name;
    has @.param-groups;     # Array of Array of Param
    has $.ret;              # TypeExpr | Nil
    has $.body;             # Block
}

class AsyncFunction does Decl {
    has Str $.name;
    has @.param-groups;
    has $.ret;
    has $.body;
}

class StructDecl does Decl {
    has Str $.name;
    has @.type-params;
    has @.members;          # StructMember[]
}

class EnumDecl does Decl {
    has Str $.name;
    has @.variants;         # Array of (Str, Array[TypeExpr] | Nil)
}

class TraitDecl does Decl {
    has Str $.name;
    has @.methods;          # TraitMethod[]
}

class Impl does Decl {
    has Str $.name;
    has @.decls;
}

class ImplTrait does Decl {
    has Str $.trait;
    has Str $.for;
    has @.decls;
}

class Let does Decl {
    has Str $.name;
    has $.type;
    has $.value;
}

class LetMut does Decl {
    has Str $.name;
    has $.type;
    has $.value;
}

class Import does Decl {
    has $.path;
}

class DerivedStruct does Decl {
    has @.derives;
    has $.inner;
}

class Param {
    has Str $.name;
    has $.ty;        # TypeExpr | Nil
    has Bool $.is-mut;
}

class StructMember {
    has Str $.name;
    has $.ty;
    has $.init;

    method field($name, $ty) {
        self.new(name => $name, ty => $ty);
    }

    method field-init($name, $ty, $init) {
        self.new(name => $name, ty => $ty, init => $init);
    }
}

class TraitMethod {
    has Str $.name;
    has @.params;

    method sig($name, @params) {
        self.new(name => $name, params => @params);
    }
}

class Block {
    has @.statements;       # Stmt[]
    has $.implicit-return;  # Expr | Nil
}

role Stmt { }

class LetDecl does Stmt {
    has $.decl;
}

class ExprStmt does Stmt {
    has $.expr;
}

class Return does Stmt {
    has $.expr;
}

class IfStmtNode does Stmt {
    has $.cond;
    has $.then-branch;
    has $.else-branch;
}

class While does Stmt {
    has $.cond;
    has $.body;
}

class Loop does Stmt {
    has $.body;
}

class Break does Stmt { }

class For does Stmt {
    has Str $.name;
    has $.expr;
    has $.body;
}

class MatchStmt does Stmt {
    has $.expr;
}

role Expr { }

class Identifier does Expr {
    has Str $.name;
}

class NumberLit does Expr {
    has $.value;  # Number
}

class StringLit does Expr {
    has Str $.value;
}

class Reference does Expr {
    has $.expr;
}

class MutReference does Expr {
    has $.expr;
}

class MatchExpr does Expr {
    has $.value;
    has @.arms;
}

class Tuple does Expr {
    has @.values;
}

class Call does Expr {
    has $.func;
    has @.args;
}

class AssocCall does Expr {
    has Str $.type;
    has Str $.method;
    has @.args;
}

class MethodCall does Expr {
    has $.receiver;
    has Str $.method;
    has @.args;
}

class StructLit does Expr {
    has Str $.name;
    has @.fields; # (Str, Expr)
}

class Closure does Expr {
    has @.params;
    has $.body;
}

class Variant does Expr {
    has Str $.name;
    has $.value;
}

class Pipe does Expr {
    has $.left;
    has $.right;
}

class Index does Expr {
    has $.left;
    has $.index;
}

class FieldAccess does Expr {
    has $.left;
    has Str $.field;
}

class DotAccess does Expr {
    has $.left;
    has Str $.field;
}

class Add does Expr { has $.l; has $.r; }
class Sub does Expr { has $.l; has $.r; }
class Mul does Expr { has $.l; has $.r; }
class Div does Expr { has $.l; has $.r; }

class Concat does Expr { has $.l; has $.r; }

class LogicalOr does Expr { has $.l; has $.r; }
class LogicalAnd does Expr { has $.l; has $.r; }

class Equal does Expr { has $.l; has $.r; }
class NotEqual does Expr { has $.l; has $.r; }
class Less does Expr { has $.l; has $.r; }
class LessEq does Expr { has $.l; has $.r; }
class Greater does Expr { has $.l; has $.r; }
class GreaterEq does Expr { has $.l; has $.r; }

class BitOr does Expr { has $.l; has $.r; }
class BitAnd does Expr { has $.l; has $.r; }
class Xor does Expr { has $.l; has $.r; }
class Nor does Expr { has $.l; has $.r; }

role Number { }

class Int64 does Number { has Int $.value; }
class Int32 does Number { has Int $.value; }
class Float64 does Number { has Num $.value; }
class Float32 does Number { has Num $.value; }

class MatchArm {
    has $.pattern;
    has $.body;
}

role Pattern { }

class NumberPattern does Pattern {
    has $.value;
}

class Wildcard does Pattern { }

class SomePattern does Pattern {
    has $.inner;
}

class PathPattern does Pattern {
    has $.path;
}

class VariantPattern does Pattern {
    has Str $.name;
    has $.inner;
}

class ExprPattern does Pattern {
    has $.expr;
}

class NonePattern does Pattern { }

role TypeExpr { }

class TInt64 does TypeExpr { }
class TInt32 does TypeExpr { }
class TFloat64 does TypeExpr { }
class TFloat32 does TypeExpr { }
class TBool does TypeExpr { }
class TString does TypeExpr { }

class TCustom does TypeExpr {
    has Str $.name;
}

class TGeneric does TypeExpr {
    has Str $.name;
    has @.params;
}

class TMutRef does TypeExpr {
    has $.inner;
}

class TRef does TypeExpr {
    has $.inner;
}

class TTuple does TypeExpr {
    has @.types;
}

role PathExpr { }

class SinglePath does PathExpr {
    has Str $.name;
}

class NestedPath does PathExpr {
    has $.left;
    has Str $.right;
}

role BoolVal { }

class True does BoolVal { }
class False does BoolVal { }
