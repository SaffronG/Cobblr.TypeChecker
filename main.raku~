use lib 'lib';

use Cobblr::AST;
use Cobblr::TypeChecker;

my $passing-ast = Cobblr::AST::Program.new(
    decls => [
        Cobblr::AST::Let.new(
            name  => "x",
            type  => Nil,
            value => Cobblr::AST::NumberLit.new(
                value => Cobblr::AST::Int64.new(value => 10)
            ),
        ),
        Cobblr::AST::Let.new(
            name  => "y",
            type  => Nil,
            value => Cobblr::AST::NumberLit.new(
                value => Cobblr::AST::Int64.new(value => 20)
            ),
        ),
        Cobblr::AST::Let.new(
            name  => "z",
            type  => Nil,
            value => Cobblr::AST::Add.new(
                l => Cobblr::AST::Identifier.new(name => "x"),
                r => Cobblr::AST::Identifier.new(name => "y")
            )
        )
    ]
);

my $failing-ast = Cobblr::AST::Program.new(
    decls => [
        Cobblr::AST::Let.new(
            name  => "x",
            type  => Nil,
            value => Cobblr::AST::NumberLit.new(
                value => Cobblr::AST::Int64.new(value => 10)
            ),
        ),
        Cobblr::AST::Let.new(
            name  => "bad",
            type  => Nil,
            value => Cobblr::AST::Add.new(
                l => Cobblr::AST::Identifier.new(name => "x"),
                r => Cobblr::AST::StringLit.new(value => "oops")
            )
        )
    ]
);

say "\t<<KEY>> \nΓ = Context\n⊢ = asserts that \n⊬ = asserts that is not\n: = has type of <type>\n";
my $passing-checker = Cobblr::TypeChecker::TypeChecker.new;
$passing-checker.check($passing-ast);
say "PASS  Γ ⊢ x + y : TInt64";

my $failing-checker = Cobblr::TypeChecker::TypeChecker.new;
try {
    $failing-checker.check($failing-ast);
    say "FAIL  Γ ⊢ x + \"oops\" : TInt64   (unexpected)";
    CATCH {
        default {
            say "PASS  Γ ⊬ x + \"oops\" : τ    ({.message})";
        }
    }
}
