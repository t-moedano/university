/****************************************************/
/* Thauany Moedano                                  */
/*                                                  */
/* Arquivo: cms.y                                   */
/****************************************************/

%{
    #define YYPARSER    
    #include "globals.h"
    #include "util.h"
    #include "scan.h"
    #include "parse.h"

    #define YYSTYPE TreeNode *
    static TreeNode * savedTree;   
    static int yylex(void);
%}

%token IF ELSE WHILE INT VOID RETURN
%token NUM ID
%token ASSIGN EQ NE LT LTE GT GTE PLUS MINUS TIMES OVER LPAREN RPAREN LBRACKET RBRACKET LKEYS RKEYS COMMA SEMI
%token ERROR ENDFILE

%% 

program            :   list_declaration
                       {
                          savedTree = $1;
                       }
                    ;
list_declaration    :   list_declaration declaration
                        {
                            YYSTYPE t = $1;
                            if(t != NULL)
		   	  			    {
                                while(t->sibling != NULL)
                                    t = t->sibling;
                                t->sibling = $2;
                                $$ = $1;
                            }
                            else
                                $$ = $2;
                        }
                    |   declaration
                        {
                           $$ = $1;
                        }
                    ;
declaration         :   var_declaration
                        {
                           $$ = $1;
                        }
                    |   fun_declaration
                        {
                           $$ = $1;
                        }
                    ;
var_declaration     :   specify_type ident SEMI
                        {
                            $$ = $1;
                            $$->child[0] = $2;
                            $2->nodekind = STATEMENTK;
                            $2->kind.stmt = VARIABLEK;
                        }
                    |   specify_type ident LBRACKET num RBRACKET SEMI
                        {
                            $$ = $1;
                            $$->child[0] = $2;
                            $2->nodekind = STATEMENTK;
                            $2->kind.stmt = VECTORK;
                            $2->attr.len = $4->attr.val;
                        }
                    ;
specify_type        :   INT
                        {
                            $$ = newExpNode(TYPEK);
                            $$->type = INTEGERK;
                            $$->attr.name = "Integer";
                        }

                    |   VOID
                        {
                            $$ = newExpNode(TYPEK);
                            $$->type = VOIDK;
                            $$->attr.name = "Void";
                        }
                    ;
fun_declaration     :   specify_type ident LPAREN params RPAREN compound_decl
                        {
                            $$ = $1;
                            $$->child[0] = $2;
                            $2->child[0] = $4;
                            $2->child[1] = $6;
                            $2->nodekind = STATEMENTK;
                            $2->kind.stmt = FUNCTIONK;
                        }
                    ;
params              :   param_list
                        {
                           $$ = $1;
                        }
                    |   VOID
                        {
						}
                   ;
param_list         :   param_list COMMA param
                       {
                           YYSTYPE t = $1;
                           if(t != NULL)
						   {
                              while(t->sibling != NULL)
                                  t = t->sibling;
                              t->sibling = $3;
                              $$ = $1;
                            }
                            else
                              $$ = $3;
                        }
                    |   param
                        {
                            $$ = $1;
                        }
                    ;
param               :   specify_type ident
                        {
                           $$ = $1;
                           $$->child[0] = $2;
                        }
                    |   specify_type ident LBRACKET RBRACKET
                         {
                            $$ = $1;
                            $$->child[0] = $2;
                            $2->kind.exp = VECTORK;
                         }
                    ;
compound_decl       :   LKEYS local_declarations statement_list RKEYS
                        {
                            YYSTYPE t = $2;
                            if(t != NULL)
						    {
                               while(t->sibling != NULL)
                                  t = t->sibling;
                                t->sibling = $3;
                                $$ = $2;
                            }
                            else
                               $$ = $3;
                        }
                    |   LKEYS local_declarations RKEYS
                        {
                            $$ = $2;
                        }
                    |   LKEYS statement_list RKEYS
                        {
                            $$ = $2;
                        }
                    |   LKEYS RKEYS
                        {
			   			}
                    ;
local_declarations  :   local_declarations var_declaration
                        {
                            YYSTYPE t = $1;
                            if(t != NULL)
							{
                            	while(t->sibling != NULL)
                                	 t = t->sibling;
                             	t->sibling = $2;
                             	$$ = $1;
                            }
                            else
                               $$ = $2;
                        }
                   |    var_declaration
                        {
                            $$ = $1;
                        }
                   ;
statement_list     :   statement_list statement
                       {
                           YYSTYPE t = $1;
                           if(t != NULL)
						   {
                              while(t->sibling != NULL)
                                   t = t->sibling;
                              t->sibling = $2;
                              $$ = $1;
                           }
                           else
                             $$ = $2;
                       }
                    |   statement
                        {
                           $$ = $1;
                        }
                    ;
statement           :   expression_decl
                        {
                           $$ = $1;
                        }
                    |   compound_decl
                        {
                           $$ = $1;
                        }
                    |   selection_decl
                        {
                           $$ = $1;
                        }
                    |   iterator_decl
                        {
                           $$ = $1;
                        }
                    |   return_decl
                        {
                           $$ = $1;
                        }
                    ;
expression_decl     :   expression SEMI 
                        {
                           $$ = $1;
                        }
                    |   SEMI
                        {
						}
                    ;
selection_decl      :   IF LPAREN expression RPAREN statement 
                        {
                             $$ = newStmtNode(IFK);
                             $$->child[0] = $3;
                             $$->child[1] = $5;
                        }
                    |   IF LPAREN expression RPAREN statement ELSE statement
                        {
							 
                             $$ = newStmtNode(IFK);
                             $$->child[0] = $3;
                             $$->child[1] = $5;
                             $$->child[2] = $7;
                        }
                    ;
iterator_decl       :   WHILE LPAREN expression RPAREN statement
                        {
                             $$ = newStmtNode(WHILEK);
                             $$->child[0] = $3;
                             $$->child[1] = $5;
                        }
                   ;
return_decl        :   RETURN SEMI
                       {
                            $$ = newStmtNode(RETURNK);
                       }
                   |   RETURN expression SEMI
                       {
                            $$ = newStmtNode(RETURNK);
                            $$->child[0] = $2;
                       }
                   ;
expression         :   var ASSIGN expression
                       {
                            $$ = newStmtNode(ASSIGNK);
                            $$->child[0] = $1;
                            $$->child[1] = $3;
                       }
                   |   simple_expression
                       {
                            $$ = $1;
                       }
                   ;
var                :   ident
                       {
                            $$ = $1;
                       }
                   |   ident LBRACKET expression RBRACKET
                       {
                            $$ = $1;
                            $$->child[0] = $3;
                            $$->kind.exp = VECTORIDK;
                       }
                    ;
simple_expression   : sum_expression relational sum_expression
                       {
                            $$ = $2;
                            $$->child[0] = $1;
                            $$->child[1] = $3;
                       }
                    |  sum_expression
                       {
                            $$ = $1;
                       }
                    ;
relational          :  EQ
                       {
                            $$ = newExpNode(OPERATIONK);
                            $$->attr.op = EQ;                            
                       }
                    |  NE
                       {
                            $$ = newExpNode(OPERATIONK);
                            $$->attr.op = NE;                            
                       }
                    |  LT
                       {
                            $$ = newExpNode(OPERATIONK);
                            $$->attr.op = LT;                            
                       }
                    |  LTE
                       {
                            $$ = newExpNode(OPERATIONK);
                            $$->attr.op = LTE;                            
                       }
                    |  GT
                       {
                            $$ = newExpNode(OPERATIONK);
                            $$->attr.op = GT;                            
                       }
                    |  GTE
                       {
                            $$ = newExpNode(OPERATIONK);
                            $$->attr.op = GTE;                            
                       }
                    ;
sum_expression      :  sum_expression sum term
                       {
                            $$ = $2;
                            $$->child[0] = $1;
                            $$->child[1] = $3;
                       }
                    |  term
                       {
                            $$ = $1;
                       }
                   ;
sum                :  PLUS
                      {
                            $$ = newExpNode(OPERATIONK);
                            $$->attr.op = PLUS;                            
                      }
                    | MINUS
                      {
                            $$ = newExpNode(OPERATIONK);
                            $$->attr.op = MINUS;                            
                      }
                   ;
term               :   term mult factor
                       {
                            $$ = $2;
                            $$->child[0] = $1;
                            $$->child[1] = $3;
                       }
                   |   factor
                       {
                            $$ = $1;
                       }
                   ;
mult               :   TIMES
                       {
                            $$ = newExpNode(OPERATIONK);
                            $$->attr.op = TIMES;                            
                       }
                   |   OVER
                       {
                            $$ = newExpNode(OPERATIONK);
                            $$->attr.op = OVER;                            
                       }
                   ;
factor             :   LPAREN expression RPAREN
                       {
                            $$ = $2;
                       }
                   |   var
                       {
                            $$ = $1;
                       }
                   |   activation
                       {
                            $$ = $1;
                       }
                   |   num
                       {
                            $$ = $1;
                       }
                   ;
activation         :   ident LPAREN arg_list RPAREN
                       {
                            $$ = $1;
                            $$->child[0] = $3;
                            $$->nodekind = STATEMENTK;
                            $$->kind.stmt = CALLK;
                       }
                   |   ident LPAREN RPAREN 
					   {
                            $$ = $1;
                            $$->nodekind = STATEMENTK;
                            $$->kind.stmt = CALLK;
                       }
                       
                   ;
arg_list           :   arg_list COMMA expression
                       {
                            YYSTYPE t = $1;
                             if(t != NULL)
							 {
                                while(t->sibling != NULL)
                                   t = t->sibling;
                                 t->sibling = $3;
                                 $$ = $1;
                             }
                             else
                                 $$ = $3;
                        }
                    |   expression
                        {
                             $$ = $1;
                        }
                    ;
ident               :   ID
                        {
                             $$ = newExpNode(IDK);
                             $$->attr.name = copyString(tokenString);
                        }
                    ;
num                 :   NUM
                        {
                             $$ = newExpNode(CONSTANTK);
                             $$->attr.val = atoi(tokenString);
                        }
                    ;

%%

int yyerror(char* message){
    fprintf(listing,"Syntax error at line %d: %s\n",lineno,message);
    fprintf(listing,"Current token: ");
    printToken(yychar,tokenString);
    Error = TRUE;
    return 0;
}


static int yylex(void){
    return getToken();
}

TreeNode * parse(void){
    yyparse();
    return savedTree;
}
