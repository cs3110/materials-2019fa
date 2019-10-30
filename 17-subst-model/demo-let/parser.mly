%{
open Ast
%}

%token <int> INT
%token <string> ID
%token TIMES  
%token PLUS
%token LPAREN
%token RPAREN
%token LET
%token EQUALS
%token IN
%token EOF

%nonassoc IN
%left PLUS
%left TIMES  

%start <Ast.expr> prog

%%

prog:
	| e = expr; EOF { e }
	;
	
expr:
	| i = INT { Int i }
	| x = ID { Var x }
	| e1 = expr; TIMES; e2 = expr { Binop (Mult, e1, e2) } 
	| e1 = expr; PLUS; e2 = expr { Binop (Add, e1, e2) }
	| LET; x = ID; EQUALS; e1 = expr; IN; e2 = expr { Let (x, e1, e2) }
	| LPAREN; e=expr; RPAREN {e} 
	;
	
