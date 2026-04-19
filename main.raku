use lib 'lib';

use Cobblr::AST;
use Cobblr::TypeChecker;

# -----------------------------
# BUILD A SIMPLE AST
# -----------------------------

my $ast = Cobblr::AST::Program.new(
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

# -----------------------------
# TYPE CHECK
# -----------------------------

my $checker = Cobblr::TypeChecker.new;

$checker.check($ast);

say "✔ Type check passed";
