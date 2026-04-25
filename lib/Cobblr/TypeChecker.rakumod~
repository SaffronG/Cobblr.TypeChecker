unit module Cobblr::TypeChecker;

use Cobblr::AST;

class TypeEnv {
    has @.scopes;  # stack of Hashes

    method new-env() {
        my $env = self.new;
        $env.push;
        $env
    }

    method push() {
        @!scopes.push({})
    }

    method pop() {
        @!scopes.pop
    }

    method declare(Str $name, $type) {
        @!scopes[*-1]{$name} = $type
    }

    method lookup(Str $name) {
        for @!scopes.reverse -> %scope {
            return %scope{$name} if %scope{$name}:exists
        }
        die "Undefined variable: $name"
    }
}

class FunctionEnv {
    has %!fns;

    method add(Str $name, @param-types, $ret) {
        %!fns{$name} = { params => @param-types, ret => $ret }
    }

    method lookup(Str $name) {
        %!fns{$name} // die "Undefined function: $name"
    }
}

class TypeChecker {
    has TypeEnv $.tenv;
    has FunctionEnv $.fenv;

    method new() {
        self.bless(tenv => TypeEnv.new-env, fenv => FunctionEnv.new)
    }

    method check(Cobblr::AST::Program $program) {
        self.visit-Program($program)
    }

    method visit-Program(Cobblr::AST::Program $p) {
        for $p.decls -> $decl {
            self.visit($decl)
        }
    }

    method visit($node) {
        given $node.WHAT {
            when Cobblr::AST::Function {
                self.visit-Function($node)
            }
            when Cobblr::AST::Let {
                self.visit-Let($node)
            }
            when Cobblr::AST::LetMut {
                self.visit-LetMut($node)
            }
            when Cobblr::AST::StructDecl {
                # structural type registration only
            }
            when Cobblr::AST::EnumDecl {
            }
            when Cobblr::AST::Impl {
            }
            when Cobblr::AST::ImplTrait {
            }
            default {
                die "Unknown decl: {$node.^name}"
            }
        }
    }

    method visit-Function(Cobblr::AST::Function $f) {
        my @param-types;
        my @params = $f.param-groups.flat;

        for @params -> $param {
            @param-types.push($param.ty // 'Unknown')
        }

        $.fenv.add($f.name, @param-types, $f.ret);

        $.tenv.push;

        # bind params
        for @params -> $param {
            $.tenv.declare($param.name, $param.ty)
        }

        self.visit-Block($f.body);

        $.tenv.pop;
    }

    method visit-Let(Cobblr::AST::Let $l) {
        my $t = self.infer($l.value);
        $.tenv.declare($l.name, $t)
    }

    method visit-LetMut(Cobblr::AST::LetMut $l) {
        my $t = self.infer($l.value);
        $.tenv.declare($l.name, $t)
    }

    method visit-Block(Cobblr::AST::Block $b) {
        $.tenv.push;

        for $b.statements -> $s {
            self.visit-Stmt($s)
        }

        if $b.implicit-return {
            self.infer($b.implicit-return)
        }

        $.tenv.pop;
    }

    method visit-Stmt($s) {
        given $s.WHAT {
            when Cobblr::AST::LetDecl {
                self.visit($s.decl)
            }
            when Cobblr::AST::ExprStmt {
                self.infer($s.expr)
            }
            when Cobblr::AST::Return {
                self.infer($s.expr)
            }
            when Cobblr::AST::IfStmtNode {
                self.infer($s.cond);
                self.visit-Block($s.then-branch);
                self.visit-Block($s.else-branch) if $s.else-branch
            }
            when Cobblr::AST::While {
                self.infer($s.cond);
                self.visit-Block($s.body)
            }
            when Cobblr::AST::For {
                self.visit-Block($s.body)
            }
        }
    }

    method infer($e) {
        given $e.WHAT {

            when Cobblr::AST::NumberLit {
                return self.type-of-number($e.value)
            }

            when Cobblr::AST::StringLit {
                return Cobblr::AST::TString
            }

            when Cobblr::AST::Identifier {
                return $.tenv.lookup($e.name)
            }

            when Cobblr::AST::Add {
                my $l = self.infer($e.l);
                my $r = self.infer($e.r);

                self.ensure-number($l);
                self.ensure-number($r);

                return $l
            }

            when Cobblr::AST::Sub {
                self.infer-binary-number($e)
            }

            when Cobblr::AST::Mul {
                self.infer-binary-number($e)
            }

            when Cobblr::AST::Div {
                self.infer-binary-number($e)
            }

            when Cobblr::AST::LogicalAnd {
                self.ensure-bool(self.infer($e.l));
                self.ensure-bool(self.infer($e.r));
                return Cobblr::AST::TBool
            }

            when Cobblr::AST::LogicalOr {
                self.ensure-bool(self.infer($e.l));
                self.ensure-bool(self.infer($e.r));
                return Cobblr::AST::TBool
            }

            when Cobblr::AST::Call {
                my $fn = $.fenv.lookup($e.func.name);
                return $fn<ret>
            }

            when Cobblr::AST::MethodCall {
                return Cobblr::AST::TCustom.new(name => "Unknown")
            }

            when Cobblr::AST::StructLit {
                return Cobblr::AST::TCustom.new(name => $e.name)
            }

            when Cobblr::AST::FieldAccess {
                return Cobblr::AST::TCustom.new(name => "field")
            }

            default {
                die "No inference rule for {$e.^name}"
            }
        }
    }

    method infer-binary-number($e) {
        my $l = self.infer($e.l);
        my $r = self.infer($e.r);

        self.ensure-number($l);
        self.ensure-number($r);

        return $l
    }

    method ensure-number($t) {
        unless $t ~~ (Cobblr::AST::TInt64 | Cobblr::AST::TInt32 | Cobblr::AST::TFloat64 | Cobblr::AST::TFloat32) {
            die "Expected number type, got {$t.^name}"
        }
    }

    method ensure-bool($t) {
        unless $t ~~ Cobblr::AST::TBool {
            die "Expected bool type, got {$t.^name}"
        }
    }

    method type-of-number($n) {
        given $n {
            when Cobblr::AST::Int64 { Cobblr::AST::TInt64 }
            when Cobblr::AST::Int32 { Cobblr::AST::TInt32 }
            when Cobblr::AST::Float64 { Cobblr::AST::TFloat64 }
            when Cobblr::AST::Float32 { Cobblr::AST::TFloat32 }
            default { Cobblr::AST::TInt64 }
        }
    }

    method format-equation($expr, $type, Bool :$passes = True, Str :$context = "Γ") {
        my $turnstile = $passes ?? "⊢" !! "⊬";
        my $type-text = $type.defined ?? $type.gist !! "τ";
        my $expr-text = self.format-nested-gist($expr.gist);
        "$context $turnstile $expr-text : $type-text"
    }

    method format-nested-gist(Str:D $text) {
        my $out = "";
        my $depth = 0;
        my $in-string = False;
        my $escaped = False;

        for $text.comb -> $ch {
            if $in-string {
                $out ~= $ch;
                if $escaped {
                    $escaped = False;
                } elsif $ch eq "\\" {
                    $escaped = True;
                } elsif $ch eq '"' {
                    $in-string = False;
                }
                next;
            }

            given $ch {
                when '"' {
                    $in-string = True;
                    $out ~= $ch;
                }
                when '(' {
                    $depth++;
                    $out ~= "(\n" ~ ("  " x $depth);
                }
                when ',' {
                    $out ~= ",\n" ~ ("  " x $depth);
                }
                when ')' {
                    $depth-- if $depth > 0;
                    $out ~= "\n" ~ ("  " x $depth) ~ ")";
                }
                default {
                    $out ~= $ch;
                }
            }
        }

        $out
    }
}
