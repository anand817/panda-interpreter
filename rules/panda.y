%code requires {
    #include <iostream>
    #include <string>
    #include <base/nodes.hpp>
    #include <variables/nodes.hpp>
    #include <functions/nodes.hpp>
    #include <expressions/nodes.hpp>
    #include <utils/nodes.hpp>
    #include <enums/type_enum.hpp>
    #include <enums/operation_enum.hpp>
    using namespace std;
}

%code {
    // External functions & variables
    extern int yylex();
    // Functions prototypes
    void yyerror(const char* s);
    // Global variables
    StatementList* programmeRoot = nullptr;
}

// Symbol Types

%union {
    TokenNode                       token; // not a pointer
    BlockNode*                      blockNode;
    ValueNode*                      valueNode;
    IdentifierNode*                 identifierNode;
    TypeNode*                       typeNode;
    StatementList*                  statementList;
    StatementNode*                  statementNode;
    VariableDeclarationNode*        variableDeclarationNode;
    VariableDefinitionNode*         variableDefinitionNode;
    FunctionDeclarationNode*        functionDeclarationNode;
    VariableList*                   variableList;
    ExpressionNode*                 expressionNode;
}

// Tokens Definition

// Data types
%token <token> TYPE_INT
%token <token> TYPE_FLOAT
%token <token> TYPE_CHAR
%token <token> TYPE_BOOL
%token <token> TYPE_VOID
%token <token> TYPE_STRING

// Keywords
%token <token> CONST
%token <token> IF
%token <token> ELSE
%token <token> FOR
%token <token> WHILE
%token <token> BREAK
%token <token> CONTINUE
%token <token> RETURN

// Operators
%token <token> INC
%token <token> DEC
%token <token> LOGICAL_AND
%token <token> LOGICAL_OR
%token <token> EQUAL
%token <token> NOT_EQUAL
%token <token> GREATER_EQUAL
%token <token> LESS_EQUAL

// Values
%token <token> INTEGER
%token <token> FLOAT
%token <token> CHAR
%token <token> BOOL
%token <token> STRING
%token <token> IDENTIFIER

// Non-terminal Symbols Types

%type <statementList>           program
%type <statementList>           statement_list
%type <variableList>            variable_list param_list
%type <statementNode>           statement
%type <blockNode>               statement_block
%type <variableDeclarationNode> variable_declaration
%type <functionDeclarationNode> function_declaration function_header
%type <variableDefinitionNode>  variable_definition
%type <typeNode>                type
%type <identifierNode>          identifier
%type <expressionNode>          expression
%type <valueNode>               value
%type <token>                   '-' '+' '*' '/' '%' '&' '|' '^' '~' '!' '<' '>' '=' '(' ')' '{' '}' '[' ']' ',' ':' ';'


// associativity

%right      '='
%left       LOGICAL_OR
%left       LOGICAL_AND
%left       '|'
%left       '^'
%left       '&'
%left       EQUAL NOT_EQUAL
%left       LESS_EQUAL GREATER_EQUAL '<' '>'
%left       SHR SHL
%left       '-' '+'
%left       '*' '/' '%'
%right      '!' '~'
%right      U_PLUS U_MINUM
%right      PRE_INC PRE_DEC
%left       SUF_INC SUF_DEC

%nonassoc   IF_UNMAT
%nonassoc   ELSE

%%

// Rules Section

program:                /* epsilon */                          { programmeRoot = new StatementList(); $$ = nullptr; }
       |                statement_list                         { programmeRoot = $1; $$ = nullptr; }
       ;


statement_list:         statement                              { $$ = new StatementList(); $$->push_back($1); }
              |         statement_list statement               { $$ = $1; $$->push_back($2); }
              |         statement_block                        { $$ = new StatementList(); $$->push_back($1); }
              |         statement_list statement_block         { $$ = $1; $$->push_back($2); }
              ;
statement_block:        '{' '}'                                { $$ = new BlockNode(); }
               |        '{' statement_list '}'                 { $$ = new BlockNode(*$2); delete $2; }
               ;

statement:              ';'                                    { $$ = new StatementNode(); }
         |              variable_declaration ';'               { $$ = $1; }
         |              variable_definition ';'                { $$ = $1; }
         |              function_declaration                   { $$ = $1; }
         |              expression ';'                         { $$ = $1; }
         ;

variable_declaration:   type identifier                        { $$ = new VariableDeclarationNode(*$1, *$2); delete $1; delete $2; }
                    ;

function_header:        type identifier '(' param_list ')'     { $$ = new FunctionDeclarationNode(*$1, *$2, *$4, NULL); delete $1; delete $2; delete $4; }
               ;

function_declaration:   function_header statement_block        { $$ = $1; $$->assignBody($2); }
                    ;
    
param_list:             /* epsilon */                          { $$ = new VariableList(); }
          |             variable_list                          { $$ = $1; }
          ;

variable_list:          variable_declaration                   { $$ = new VariableList(); $$->push_back(*$1); delete $1; }
             |          variable_list ',' variable_declaration { $$ = $1; $$->push_back(*$3); delete $3; }
             ;

variable_definition:    type identifier '=' expression         { $$ = new VariableDefinitionNode(*$1, *$2, $4); delete $1; delete $2; } // $4 passed as a pointer
                   ;

expression:             expression '+' expression              { $$ = new BinaryExpressionNode($1, $3, BINARY_OPERATOR::ADD); }
          |             expression '-' expression              { $$ = new BinaryExpressionNode($1, $3, BINARY_OPERATOR::SUBTRACT); }
          |             expression '*' expression              { $$ = new BinaryExpressionNode($1, $3, BINARY_OPERATOR::MULTIPLY); }
          |             expression '/' expression              { $$ = new BinaryExpressionNode($1, $3, BINARY_OPERATOR::DIVIDE); }
          |             expression '=' expression              { $$ = new BinaryExpressionNode($1, $3, BINARY_OPERATOR::ASSIGN); }
          |             expression '%' expression              { $$ = new BinaryExpressionNode($1, $3, BINARY_OPERATOR::MODULUS); }
          |             expression '|' expression              { $$ = new BinaryExpressionNode($1, $3, BINARY_OPERATOR::OR); }
          |             expression LOGICAL_OR expression       { $$ = new BinaryExpressionNode($1, $3, BINARY_OPERATOR::LOGICAL_OR); }
          |             expression '&' expression              { $$ = new BinaryExpressionNode($1, $3, BINARY_OPERATOR::AND); }
          |             expression LOGICAL_AND expression      { $$ = new BinaryExpressionNode($1, $3, BINARY_OPERATOR::LOGICAL_AND); }
          |             expression '^' expression              { $$ = new BinaryExpressionNode($1, $3, BINARY_OPERATOR::XOR); }
          |             expression SHL expression              { $$ = new BinaryExpressionNode($1, $3, BINARY_OPERATOR::SHIFT_LEFT); }
          |             expression SHR expression              { $$ = new BinaryExpressionNode($1, $3, BINARY_OPERATOR::SHIFT_RIGHT); }
          |             expression '>' expression              { $$ = new BinaryExpressionNode($1, $3, BINARY_OPERATOR::GREATER); }
          |             expression GREATER_EQUAL expression    { $$ = new BinaryExpressionNode($1, $3, BINARY_OPERATOR::GREATER_EQUAL); }
          |             expression '<' expression              { $$ = new BinaryExpressionNode($1, $3, BINARY_OPERATOR::LESSER); }
          |             expression LESS_EQUAL expression       { $$ = new BinaryExpressionNode($1, $3, BINARY_OPERATOR::LESSER_EQUAL); }
          |             expression EQUAL expression            { $$ = new BinaryExpressionNode($1, $3, BINARY_OPERATOR::EQUAL); }
          |             expression NOT_EQUAL expression        { $$ = new BinaryExpressionNode($1, $3, BINARY_OPERATOR::NOT_EQUAL); }

          |             '+' expression %prec U_PLUS            { $$ = new UnaryExpressionNode($2, UNARY_OPERATOR::UNARY_PLUS); }
          |             '-' expression %prec U_MINUM           { $$ = new UnaryExpressionNode($2, UNARY_OPERATOR::UNARY_MINUS); }
          |             '~' expression                         { $$ = new UnaryExpressionNode($2, UNARY_OPERATOR::NOT); }
          |             '!' expression                         { $$ = new UnaryExpressionNode($2, UNARY_OPERATOR::LOGICAL_NOT); }

          |             INC expression %prec PRE_INC           { $$ = new UnaryExpressionNode($2, UNARY_OPERATOR::PRE_INCREMENT); }
          |             DEC expression %prec PRE_DEC           { $$ = new UnaryExpressionNode($2, UNARY_OPERATOR::PRE_DECREMENT); } 
          |             expression INC %prec SUF_INC           { $$ = new UnaryExpressionNode($1, UNARY_OPERATOR::POST_INCREMENT); }
          |             expression DEC %prec SUF_DEC           { $$ = new UnaryExpressionNode($1, UNARY_OPERATOR::POST_DECREMENT); }

          |             '(' expression ')'                     { $$ = $2; }
          |             identifier                             { $$ = new IdentifierExpressionNode(*$1); delete $1; }
          |             value                                  { $$ = new ExpressionNode(*$1); delete $1; }
          ;

value:                  INTEGER                                { $$ = new ValueNode(INT_TYPE, $1.value); }
     |                  CHAR                                   { $$ = new ValueNode(CHAR_TYPE, $1.value); }
     |                  BOOL                                   { $$ = new ValueNode(BOOL_TYPE, $1.value); }
     |                  FLOAT                                  { $$ = new ValueNode(FLOAT_TYPE, $1.value); }
     |                  STRING                                 { $$ = new ValueNode(STRING_TYPE, $1.value); }
     ;

type:                   TYPE_INT                               { $$ = new TypeNode(INT_TYPE); }
    |                   TYPE_CHAR                              { $$ = new TypeNode(CHAR_TYPE); }
    |                   TYPE_BOOL                              { $$ = new TypeNode(BOOL_TYPE); }
    |                   TYPE_FLOAT                             { $$ = new TypeNode(FLOAT_TYPE); }
    |                   TYPE_STRING                            { $$ = new TypeNode(STRING_TYPE); }
    |                   TYPE_VOID                              { $$ = new TypeNode(VOID_TYPE); }
    ;

identifier:             IDENTIFIER                             { $$ = new IdentifierNode($1.value); }
          ;


%%

void yyerror(const char* s) {
    std::cout << "Error: " << s << std::endl;
}