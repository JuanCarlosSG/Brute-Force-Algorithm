%{

#pragma warning(disable: 4996 6387 6011 6385)
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

void testRules();

#define MAX_LONGITUD 200

typedef struct {
    char NT[MAX_LONGITUD]; // String representing non terminal symbol
    unsigned int MAX; // Number of productions that have this non terminal symbol
    unsigned int FIRST; // Index of the RHS array where the first rule of the NT is located
} LHS_Element;

typedef struct {
    char SYMB[MAX_LONGITUD]; // Stack stymbol (terminal or nonterminal)
    unsigned int P; // Number of the alterate for the nonterminal or 0 if contains terminal or empty
} HIST_Element;

char file_name[MAX_LONGITUD] = "";
char T[MAX_LONGITUD] = "";

const char delimiter[2] = " ";
char temp[MAX_LONGITUD] = "";

LHS_Element LHS[MAX_LONGITUD];
char RHS[MAX_LONGITUD][MAX_LONGITUD];
HIST_Element HIST[MAX_LONGITUD]; // History Stack
char SENT[MAX_LONGITUD] = ""; // Stack that represent the current sentenial form

size_t n;
unsigned int i;
enum PARSE_STATE {q=0, b, t} STATE;
/*
	State of parse
    q = normal state
    b = backtracking state
    t = termination state
*/
unsigned int T_HIST; // Points to the top of HIST Stack

unsigned int LHS_ELEMENTS_COUNT = 0;
unsigned int RHS_ELEMENTS_COUNT = 0;

//max depth es 1 porque solo lee el mismo archivo una vez
#define MAX_INCLUDE_DEPTH 1

YY_BUFFER_STATE include_stack[MAX_INCLUDE_DEPTH]; /* PILA para archivos */

int include_stack_ptr = 0;

%}

%option noyywrap
%option outfile="Brute_Force.c"

%x ANALISIS

%%

[^\n]+ { /* Cualquier caracter que no sea un cambio de linea */

    if ( include_stack_ptr >= MAX_INCLUDE_DEPTH ) {
		printf("Archivos sobrepasan la profundidad maxima\n" );
		exit(1);
	}
	strcpy(temp, "");
	strcpy(temp, yytext);

	char * instance = strtok(temp, delimiter);
	int band = 0;

	bool found = false;
	unsigned int position = 0;
	unsigned int position_nt = 0;

	while(instance != NULL) {
		switch(band) {
			case 0:
				for(unsigned int i = 0; i < LHS_ELEMENTS_COUNT; i++) {
					if(strcmp((LHS[i]).NT, instance) == 0) {
						found = true;
						position = i;
						break;
					}
				}

				if(!found) {
					strcpy(LHS[LHS_ELEMENTS_COUNT].NT, instance);
					LHS[LHS_ELEMENTS_COUNT].MAX = 1;
					position_nt = LHS_ELEMENTS_COUNT;
					LHS_ELEMENTS_COUNT++;
				} else {
					LHS[position].MAX++;
					position_nt = position;
				}
				band++;
				break;
			default:
				strcpy(RHS[RHS_ELEMENTS_COUNT], instance);
				if(!found) {
					LHS[position_nt].FIRST = RHS_ELEMENTS_COUNT;
				}
				RHS_ELEMENTS_COUNT++;
				break;
		}
		instance = strtok(NULL, delimiter);
	}
}

.|\n		

 <<EOF>> { /* EOF detected when the SongDirectory.txt ends */
		if ( --include_stack_ptr < 0 ) {
			yyterminate();
		} else {
			yy_delete_buffer( YY_CURRENT_BUFFER );
			yy_switch_to_buffer( include_stack[include_stack_ptr] );
			printf("Cerrando el archivo %s\n",file_name );
			BEGIN(INITIAL);
		}
	}
	
%%

int main( int argc, char* argv[] )
{
	if ( argc == 3 )
	{
		strcpy(file_name, argv[1]);
		n = strlen(argv[2]);
        strcpy(T, argv[2]);
		STATE = q;
        printf("Cadena ingresada: %s\n", T);
		yyin = fopen(file_name, "r" );
		if (yyin)
		{
			printf("Leyendo del archivo: %s\n", file_name);
		}
	}
	else
	{
		printf("Este programa solo lee de un archivo no puede leer de una entrada de teclado");
		return(1);
	}
	yylex();
	return(0);
}
