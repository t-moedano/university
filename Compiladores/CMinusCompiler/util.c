/****************************************************/
/*                                                  */
/*                                                  */         
/* Thauany Moedano                                  */
/*                                                  */
/*                                                  */
/****************************************************/

#include "globals.h"
#include "util.h"


void printToken( TokenType token, const char* tokenString )
{ switch (token)
  { case IF: fprintf(listing, "Reserved Word: %s\n",tokenString); break;
    case ELSE: fprintf(listing, "Reserved Word: %s\n",tokenString); break;
    case INT: fprintf(listing, "Reserved Word: %s\n",tokenString); break;
    case RETURN: fprintf(listing, "Reserved Word: %s\n",tokenString); break;
    case VOID: fprintf(listing, "Reserved Word: %s\n",tokenString); break;
    case WHILE: fprintf(listing, "Reserved Word: %s\n",tokenString); break;
    case ASSIGN: fprintf(listing,"Symbol: =\n"); break;
    case LT: fprintf(listing,"<\n"); break;
    case EQ: fprintf(listing,"==\n"); break;
    case GT: fprintf(listing,">\n"); break; 
    case LTE: fprintf(listing, "<=\n"); break;
    case GTE: fprintf(listing, ">=\n"); break; 
    case NE: fprintf(listing, "!=\n"); break;
    case LBRACKET: fprintf(listing, "[\n"); break;
    case RBRACKET: fprintf(listing, "]\n"); break;
    case LKEYS: fprintf(listing, "{\n"); break;
    case RKEYS: fprintf(listing, "}\n"); break;	
    case LPAREN: fprintf(listing,"(\n"); break;
    case RPAREN: fprintf(listing,")\n"); break;
    case SEMI: fprintf(listing,";\n"); break;
    case COMMA: fprintf(listing,",\n"); break;
    case PLUS: fprintf(listing,"+\n"); break;
    case MINUS: fprintf(listing,"-\n"); break;
    case TIMES: fprintf(listing,"*\n"); break;
    case OVER: fprintf(listing,"/\n"); break;
    case ENDFILE: fprintf(listing,"EOF\n"); break;
	 
    case NUM:
      fprintf(listing,
          "Number: %s\n",tokenString);
      break;
    case ID:
      fprintf(listing,
          "ID: %s\n",tokenString);
      break;
    case ERROR:
      fprintf(listing,
          "ERROR: %s\n",tokenString);
      break;
    default: 
      fprintf(listing,"Unknown token: %d\n",token);
  }
}

TreeNode * newStmtNode(StatementKind kind)
{ TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
  int i;
  if (t==NULL)
    fprintf(listing,"Out of memory error at line %d\n",lineno);
  else {
    for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
    t->sibling = NULL;
    t->nodekind = STATEMENTK;
    t->kind.stmt = kind;
    t->lineno = lineno;
  }
  return t;
}


TreeNode * newExpNode(ExpressionIdentifier kind)
{ TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
  int i;
  if (t==NULL)
    fprintf(listing,"Out of memory error at line %d\n",lineno);
  else {
    for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
    t->sibling = NULL;
    t->nodekind = EXPRESSIONK;
    t->kind.exp = kind;
    t->lineno = lineno;
    t->type = VOID;
  }
  return t;
}

char * copyString(char * s)
{ int n;
  char * t;
  if (s==NULL) return NULL;
  n = strlen(s)+1;
  t = malloc(n);
  if (t==NULL)
    fprintf(listing,"Out of memory error at line %d\n",lineno);
  else strcpy(t,s);
  return t;
}

static indentno = 0;


#define INDENT indentno+=2
#define UNINDENT indentno-=2


static void printSpaces(void)
{ 
  int i;
    for (i=0;i<indentno;i++)
      fprintf(listing," ");
}


void printTree( TreeNode * tree )
{ int i;
  INDENT;
  while (tree != NULL) {
    printSpaces();
    if (tree->nodekind==STATEMENTK)
    { switch (tree->kind.stmt) {
        case IFK:
          fprintf(listing,"If\n");
          break;
        case REPEATK:
          fprintf(listing,"Repeat\n");
          break;
        case ASSIGNK:
          fprintf(listing,"Assign\n");
          break;
        case READK:
          fprintf(listing,"Read: %s\n",tree->attr.name);
          break;
        case WRITEK:
          fprintf(listing,"Write\n");
          break;
	case WHILEK:
	  fprintf(listing,"While\n");
	  break;
	case VARIABLEK:
	  fprintf(listing,"Variable %s\n", tree->attr.name);
	  break;
	case FUNCTIONK:
	  fprintf(listing,"Function %s\n", tree->attr.name);
	  break;
        case CALLK:
	  fprintf(listing,"Call to Function %s\n", tree->attr.name);
	  break;        
	case RETURNK:
	  fprintf(listing, "Return\n");
	  break;        
	        
	default:
          fprintf(listing,"Unknown ExpNode kind\n");
          break;
      }
    }
    else if (tree->nodekind==EXPRESSIONK)
    { switch (tree->kind.exp) {
        case OPERATIONK:
          fprintf(listing,"Operation: ");
          printToken(tree->attr.op,"\0");
          break;
        case CONSTANTK:
          fprintf(listing,"Constant: %d\n",tree->attr.val);
          break;
        case IDK:
          fprintf(listing,"Id: %s\n",tree->attr.name);
          break;
	case VECTORK:
          fprintf(listing,"Vector: %s\n",tree->attr.name);
          break;
	case VECTORIDK:
          fprintf(listing,"Index [%d]\n",tree->attr.len);
          break;
	case TYPEK:
          fprintf(listing,"Type %s\n",tree->attr.name);
          break;
        
        default:
          fprintf(listing,"Unknown ExpNode kind\n");
          break;
      }
    }
    else fprintf(listing,"Unknown node kind\n");
    for (i=0;i<MAXCHILDREN;i++)
         printTree(tree->child[i]);
    tree = tree->sibling;
  }
  UNINDENT;
}
