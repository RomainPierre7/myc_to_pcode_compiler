%{

#include "Table_des_symboles.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
  
extern int yylex();
extern int yyparse();
extern int yylineno;

void yyerror(const char* format, ...) {
    va_list args;
    va_start(args, format);

    printf("\nERROR at line %d: ", yylineno);
    vprintf(format, args);
    printf("\n");

    va_end(args);
    exit(0);
}

char buffer[100];

int label_count = 0;
int loop_count = 0;

char* makeLabel(int i){
  sprintf(buffer, "LABEL_%d", i);
  return buffer;
}

char* Makeloop(int i){
  sprintf(buffer, "LOOP_%d", i);
  return buffer;
}
		
 int depth=0; // block depth

 int arg_count;
 int arg_type[MAX_ARG];
 
%}

%union { 
  struct ATTRIBUTE * symbol_value;
  char * string_value;
  int int_value;
  float float_value;
  int type_value;
  int label_value;
  int offset_value;
}

%token <int_value> NUM
%token <float_value> DEC


%token INT FLOAT VOID

%token <string_value> ID
%token AO AF PO PF PV VIR
%token RETURN  EQ
%token <label_value> IF ELSE WHILE

%token <label_value> AND OR NOT DIFF EQUAL SUP INF
%token PLUS MOINS STAR DIV
%token DOT ARR

%nonassoc IFX
%left OR                       // higher priority on ||
%left AND                      // higher priority on &&
%left DIFF EQUAL SUP INF       // higher priority on comparison
%left PLUS MOINS               // higher priority on + - 
%left STAR DIV                 // higher priority on * /
%left DOT ARR                  // higher priority on . and -> 
%nonassoc UNA                  // highest priority on unary operator
%nonassoc ELSE


%{
char * type2string (int c) {
  switch (c)
    {
    case INT:
      return("int");
    case FLOAT:
      return("float");
    case VOID:
      return("void");
    default:
      return("type error");
    }  
};

  
  %}


%start prog  

// liste de tous les non terminaux dont vous voulez manipuler l'attribut
%type <type_value> type exp  typename app
%type <string_value> fun_head fid
%type <offset_value> glob_decl_list decl decl_list var_decl vlist params
%type <label_value> if elsop while
%type <int_value> arglist

 /* Attention, la rêgle de calcul par défaut $$=$1 
    peut créer des demandes/erreurs de type d'attribut */

%%

 // O. Déclaration globale

prog : glob_decl_list              {}

glob_decl_list : glob_decl_list fun {}
| glob_decl_list decl PV       {$$ = $2;}
|                              {$$ = 0;} // empty glob_decl_list shall be forbidden, but usefull for offset computation

// I. Functions

fun : type fun_head fun_body   {}
;

fun_head : ID PO PF            {
  // Pas de déclaration de fonction à l'intérieur de fonctions !
  if (depth>0) yyerror("Function must be declared at top level !");
  printf("\nvoid pcode_%s()", $1);
  set_symbol_value($1, makeSymbol($<type_value>0, -1, -1));
  }

| ID PO params PF              {
   // Pas de déclaration de fonction à l'intérieur de fonctions !
  if (depth>0) yyerror("Function must be declared at top level !");
  printf("\nvoid pcode_%s()", $1);
  set_symbol_value($1, makeSymbol($<type_value>0, -1, -1));
  attribute fun = get_symbol_value($1);
  fun->arg_count = arg_count;
  for (int i = 0; i < arg_count; ++i){
    fun->type_array[i] = arg_type[i];
  }
 }
;

params: type ID vir params     {
  printf("//%s arg with %s type and offset of %d\n", $2, type2string($1), $4);
  set_symbol_value($2, makeSymbol($1, $4, 1));
  $$ = $4 - 1;
  ++arg_count;
  arg_type[arg_count-1] = $1;
} // récursion droite pour numéroter les paramètres du dernier au premier
| type ID                      {
  printf("//%s arg with %s type and offset of %d\n", $2, type2string($1), -1);
  set_symbol_value($2, makeSymbol($1, -1, 1));
  $$ = -2;
  arg_count = 1;
  arg_type[arg_count-1] = $1;
  }


vir : VIR                      {}
;

fun_body : fao block faf       {}
;

fao : AO                       {printf("{\n"); depth++;}
;
faf : AF                       {printf("}\n"); depth--;}
;


// II. Block
block:
decl_list inst_list            {}
;

// III. Declarations

decl_list : decl_list decl PV   {$$ = $2;} 
|                               {$$ = 1;}
;

decl: var_decl                  {$$ = $1;}
;

var_decl : type vlist          {$$ = $2;}
;

vlist: vlist vir ID            {
  int offset = $1;
  int type = $<type_value>0;
  $$ = offset + 1;
  printf("//%s type %s declaration with an offset of %d at depth %d\n", type2string(type), $3, offset, depth);
  set_symbol_value($3, makeSymbol(type, offset, depth));
  if (type == INT){
    printf("LOADI(0)\n");
  } else if (type == FLOAT){
    printf("LOADF(0.0)\n");
  }
} // récursion gauche pour traiter les variables déclararées de gauche à droite
| ID                           {
  int offset = $<offset_value>-1;
  int type = $<type_value>0;
  $$ = offset + 1;
  printf("//%s type %s declaration with an offset of %d at depth %d\n", type2string(type), $1, offset, depth);
  set_symbol_value($1, makeSymbol(type, offset, depth));
  if (type == INT){
    printf("LOADI(0)\n");
  } else if (type == FLOAT){
    printf("LOADF(0.0)\n");
  }
}
;

type
: typename                     {$$ = $1;}
;

typename
: INT                          {$$ = INT;}
| FLOAT                        {$$ = FLOAT;}
| VOID                         {$$ = VOID;}
;

// IV. Intructions

inst_list: inst_list inst   {} 
| inst                      {}
;

pv : PV                       {}
;
 
inst:
ao block af                   {}
| aff pv                      {}
| ret pv                      {}
| cond                        {}
| loop                        {}
| pv                          {}
;

// Accolades explicites pour gerer l'entrée et la sortie d'un sous-bloc

ao : AO                       {depth++; printf("SAVEBP //entering block\n");}
;

af : AF                       {depth--; printf("RESTOREBP //exiting block\n");}
;


// IV.1 Affectations

aff : ID EQ exp               {
  attribute attr = get_symbol_value($1);
  if (attr->type == INT && $3 == FLOAT){
    yyerror("Float value cannot be assigned to an int !");
  } else if (attr->type == FLOAT && $3 == INT){
    printf("I2F "); printf("//converting second arg to float\n");
  }
  if (depth == 0  || attr->depth == 0){
    printf("STOREP(%d) ", attr->offset); printf("//storing %s value\n", $1);
  } else {
    printf("STOREP(");
    for (int i = 0; i < depth - attr->depth; i++){
      printf("stack[");
    }
    printf("bp");
    for (int i = 0; i < depth - attr->depth; i++){
      printf("]");
    }
    printf("+%d) ", attr->offset); printf("//storing %s value in current block\n", $1);
  }
  }

// IV.2 Return
ret : RETURN exp              {printf("return;\n");}
| RETURN PO PF                {printf("return;\n");}
;

// IV.3. Conditionelles
//           N.B. ces rêgles génèrent un conflit déclage reduction
//           qui est résolu comme on le souhaite par un décalage (shift)
//           avec ELSE en entrée (voir y.output)

cond :
if bool_cond inst  elsop       {}
;

elsop : else inst              {
  $$ = $<label_value>-2;;
  printf("END_%s:\n//end of conditional %d\n", makeLabel($$), $$);
}
|                  %prec IFX   {
  int loop = $<label_value>-2;
  printf("//end of conditional %d\n", loop);
  } // juste un "truc" pour éviter le message de conflit shift / reduce
;

bool_cond : PO exp PF         {
  int loop = $<label_value>0;
  printf("IFN(%s)\n//the condition %d is true\n", makeLabel(loop), loop);
  }
;

if : IF                       {
  $$ = label_count++;
  printf("//start of conditional %d\n", $$);
  }
;

else : ELSE                   {
  int loop = $<label_value>-2;
  printf("GOTO(END_%s)\n%s:\n//the condition %d is false\n", makeLabel(loop), makeLabel(loop), loop);
  }
;

// IV.4. Iterations

loop : while while_cond inst  {printf("GOTO(%s)\n//end of while loop %d\nEND_%s:\n", Makeloop($1), $1, Makeloop($1));}
;

while_cond : PO exp PF        {
  int loop = $<label_value>0;
  printf("IFN(END_%s)\n//start of while loop %d\n", Makeloop(loop), loop);
}

while : WHILE                 {
  $$ = loop_count++;
  printf("%s: //loading condition while loop %d\n", Makeloop($$), $$);
}
;


// V. Expressions

exp
// V.1 Exp. arithmetiques
: MOINS exp %prec UNA         {$$ = $2;}
         // -x + y lue comme (- x) + y  et pas - (x + y)
| exp PLUS exp                {
  if ($1 == INT && $3 == INT){
    $$ = INT;
    printf("ADDI\n");
  } else if ($1 == FLOAT && $3 == FLOAT){
    $$ = FLOAT;
    printf("ADDF\n");
  } else if ($1 == INT && $3 == FLOAT){
    $$ = FLOAT;
    printf("I2F2 "); printf("//converting first arg to float\n");
    printf("ADDF\n");
  } else if ($1 == FLOAT && $3 == INT){
    $$ = FLOAT;
    printf("I2F "); printf("//converting second arg to float\n");
    printf("ADDF\n");
  }
}
| exp MOINS exp               {
  if ($1 == INT && $3 == INT){
    $$ = INT;
    printf("SUBI\n");
  } else if ($1 == FLOAT && $3 == FLOAT){
    $$ = FLOAT;
    printf("SUBF\n");
  } else if ($1 == INT && $3 == FLOAT){
    $$ = FLOAT;
    printf("I2F2 "); printf("//converting first arg to float\n");
    printf("SUBF\n");
  } else if ($1 == FLOAT && $3 == INT){
    $$ = FLOAT;
    printf("I2F "); printf("//converting second arg to float\n");
    printf("SUBF\n");
  }
}
| exp STAR exp                {
  if ($1 == INT && $3 == INT){
    $$ = INT;
    printf("MULTI\n");
  } else if ($1 == FLOAT && $3 == FLOAT){
    $$ = FLOAT;
    printf("MULTF\n");
  } else if ($1 == INT && $3 == FLOAT){
    $$ = FLOAT;
    printf("I2F2 "); printf("//converting first arg to float\n");
    printf("MULTF\n");
  } else if ($1 == FLOAT && $3 == INT){
    $$ = FLOAT;
    printf("I2F "); printf("//converting second arg to float\n");
    printf("MULTF\n");
  }
}
| exp DIV exp                 {
  if ($1 == INT && $3 == INT){
    $$ = INT;
    printf("DIVI\n");
  } else if ($1 == FLOAT && $3 == FLOAT){
    $$ = FLOAT;
    printf("DIVF\n");
  } else if ($1 == INT && $3 == FLOAT){
    $$ = FLOAT;
    printf("I2F2 "); printf("//converting first arg to float\n");
    printf("DIVF\n");
  } else if ($1 == FLOAT && $3 == INT){
    $$ = FLOAT;
    printf("I2F "); printf("//converting second arg to float\n");
    printf("DIVF\n");
  }
}
| PO exp PF                   {$$ = $2;}
| ID                          {
  attribute attr = get_symbol_value($1);
  if (depth == 0 || attr->depth == 0){
    printf("LOADP(%d) ", attr->offset); printf("//loading %s value\n", $1);
  } else {
    printf("LOADP(");
    for (int i = 0; i < depth - attr->depth; i++){
      printf("stack[");
    }
    printf("bp");
    for (int i = 0; i < depth - attr->depth; i++){
      printf("]");
    }
    printf("+%d) ", attr->offset); printf("//loading %s value in current block\n", $1);
  }
  if (attr->type == INT){
    $$ = INT;
  } else if (attr->type == FLOAT){
    $$ = FLOAT;
  }
}
| app                         {$$ = $1;}
| NUM                         {$$ = INT; printf("LOADI(%d)\n", $1);}
| DEC                         {$$ = FLOAT; printf("LOADF(%f)\n", $1);}


// V.2. Booléens

| NOT exp %prec UNA           {printf("NOT\n");}
| exp INF exp                 {
  if ($1 == INT && $3 == INT){
    printf("LTI\n");
  } else if ($1 == FLOAT && $3 == FLOAT){
    printf("LTF\n");
  } else if ($1 == INT && $3 == FLOAT){
    printf("I2F2 "); printf("//converting first arg to float\n");
    printf("LTF\n");
  } else if ($1 == FLOAT && $3 == INT){
    printf("I2F "); printf("//converting second arg to float\n");
    printf("LTF\n");
  }
}
| exp SUP exp                 {
    if ($1 == INT && $3 == INT){
    printf("GTI\n");
  } else if ($1 == FLOAT && $3 == FLOAT){
    printf("GTF\n");
  } else if ($1 == INT && $3 == FLOAT){
    printf("I2F2 "); printf("//converting first arg to float\n");
    printf("GTF\n");
  } else if ($1 == FLOAT && $3 == INT){
    printf("I2F "); printf("//converting second arg to float\n");
    printf("GTF\n");
  }
}
| exp EQUAL exp               {
    if ($1 == INT && $3 == INT){
    printf("EQI\n");
  } else if ($1 == FLOAT && $3 == FLOAT){
    printf("EQF\n");
  } else if ($1 == INT && $3 == FLOAT){
    printf("I2F2 "); printf("//converting first arg to float\n");
    printf("EQF\n");
  } else if ($1 == FLOAT && $3 == INT){
    printf("I2F "); printf("//converting second arg to float\n");
    printf("EQF\n");
  }
}
| exp DIFF exp                {
    if ($1 == INT && $3 == INT){
    printf("NEQI\n");
  } else if ($1 == FLOAT && $3 == FLOAT){
    printf("NEQF\n");
  } else if ($1 == INT && $3 == FLOAT){
    printf("I2F2 "); printf("//converting first arg to float\n");
    printf("NEQF\n");
  } else if ($1 == FLOAT && $3 == INT){
    printf("I2F "); printf("//converting second arg to float\n");
    printf("NEQF\n");
  }
}
| exp AND exp                 {printf("AND\n");}
| exp OR exp                  {printf("OR\n");}

;

// V.3 Applications de fonctions


app : fid PO args PF          {
  attribute attr = get_symbol_value($1);
  $$ = attr->type;
  }
;

fid : ID                      {$$ = $1;}

args :  arglist               {printf("SAVEBP\nCALL(pcode_%s)\nRESTOREBP\nENDCALL(%d) //unloading %d args of function %s\n", $<string_value>0, $1, $1, $<string_value>0);}
|                             {printf("SAVEBP\nCALL(pcode_%s)\nRESTOREBP\nENDCALL(0)\n", $<string_value>0);}
;

arglist : arglist VIR exp     {
  $$ = $1 + 1;
  attribute fun = get_symbol_value($<string_value>-1);
  int type = fun->type_array[fun->arg_count - $$];
  if (type == FLOAT && $3 == INT){
    printf("I2F //converting previous arg\n");
  } else if (type == INT && $3 == FLOAT){
    yyerror("int argument is needed, you tried to put a float instead !");
  }
} // récursion gauche pour empiler les arguements de la fonction de gauche à droite
| exp                         {
  $$ = 1;
  attribute fun = get_symbol_value($<string_value>-1);
  int type = fun->type_array[fun->arg_count - $$];;
  if (type == FLOAT && $1 == INT){
    printf("I2F //converting previous arg\n");
  } else if (type == INT && $1 == FLOAT){
    yyerror("int argument is needed, you tried to put a float instead !");
  }
  }
;



%% 
int main () {

  /* Ici on peut ouvrir le fichier source, avec les messages 
     d'erreur usuel si besoin, et rediriger l'entrée standard 
     sur ce fichier pour lancer dessus la compilation.
   */

char * header=
"// PCode Header\n\
#include \"PCode.h\"\n\
\n\
int main() {\n\
pcode_main();\n\
return stack[sp-1].int_value;\n\
}\n";  

printf("%s\n",header); // ouput header
  
return yyparse ();
 
 
}