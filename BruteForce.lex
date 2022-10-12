%{

#pragma warning(disable: 4996 6387 6011 6385)
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAX_LONGITUD 200

typedef struct {
    char NT[MAX_LONGITUD]; // String representing non terminal symbol
    unsigned int MAX; // Number of productions that have this non terminal symbol
    unsigned int FIRST; // Index of the RHS array where the first rule ofr the NT is located
} LHS_Element

typedef struct {
    char SYMB[MAX_LONGITUD]; // Stack stymbol (terminal or nonterminal)
    unsigned int P; // Number of the alterate for the nonterminal or 0 if contains terminal or empty
} HIST_Element

enum PARSE_STATE {q, b, t};
/*
    q = normal state
    b = backtracking state
    t = termination state
*/

char file_name[MAX_LONGITUD] = "";
char T[MAX_LONGITUD] = "";

LHS_Element LHS[MAX_LONGITUD];
char RHS[MAX_LONGITUD][MAX_LONGITUD];
HIST_Element HIST[MAX_LONGITUD]; // History Stack
char SENT[MAX_LONGITUD] = ""; // Stack that represent the current sentenial form

unsigned int n;
unsigned int i;
enum STATE PARSE_STATE; // State of the parse
unsigned int T_HIST; // Points to the top of HIST Stack

//max depth es 3 porque solo lee el mismo archivo dos veces
#define MAX_INCLUDE_DEPTH 2

YY_BUFFER_STATE include_stack[MAX_INCLUDE_DEPTH]; /* PILA para archivos */

int include_stack_ptr = 0;

%}

%option noyywrap
%option outfile="Brute_Force.c"

%x ANALISIS

%%

[^\n]+ { /* Cualquier caracter que no sea un cambio de linea */

    if ( include_stack_ptr >= MAX_INCLUDE_DEPTH ) {
		printf("Archivos include sobrepasan la profundidad maxima\n" );
		exit(1);
	}

    /*

        Missing functionality

    */

}

.|\n		

 <<EOF>> { /* EOF detected when the SongDirectory.txt ends */
		if ( --include_stack_ptr < 0 ) {
			yyterminate();
		} else {
			yy_delete_buffer( YY_CURRENT_BUFFER );
			yy_switch_to_buffer( include_stack[include_stack_ptr] );
			printf("Cerrando el archivo %s\n",nombre_archivo );
			BEGIN(INITIAL);
		}
	}
	
%%

int main( int argc, char* argv[] )
{
	if ( argc == 3 )
	{
		strcpy(file_name, argv[1]);
        strcpy(T, argv[2]);
        printf("Cadena ingresada: %s\n", T);
		yyin = fopen(nombre_archivo, "r" );
		if (yyin)
		{
			printf("Leyendo del archivo: %s\n", nombre_archivo);
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