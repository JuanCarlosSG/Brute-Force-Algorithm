%{

#pragma warning(disable: 4996 6387 6011 6385)
#include <stdio.h>
#include <string.h>
#include <stdbool.h>

void BruteForceAlgorithm();
void showTables();
int getFunctionValue(const char);

#define MAX_LONGITUD 200

typedef struct {
    char NT; // String representing non terminal symbol
    unsigned int MAX; // Number of productions that have this non terminal symbol
    unsigned int FIRST; // Index of the RHS array where the first rule of the NT is located
} LHS_Element;

typedef struct {
    char SYMB; // Stack symbol (terminal or nonterminal)
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
    q = 0 = normal state
    b = 1 = backtracking state
    t = 2 = termination state
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
					if(LHS[i].NT == *instance) {
						found = true;
						position = i;
						break;
					}
				}

				if(!found) {
					LHS[LHS_ELEMENTS_COUNT].NT = *instance;
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

 <<EOF>> { /* EOF detected when the .txt ends */
		if ( --include_stack_ptr < 0 ) {
			yyterminate();
		} else {
			yy_delete_buffer( YY_CURRENT_BUFFER );
			yy_switch_to_buffer( include_stack[include_stack_ptr] );
			printf("Clossing file : %s\n",file_name );
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
        printf("\nInput : '%s'\n", T);
		yyin = fopen(file_name, "r" );
		if (yyin)
		{
			printf("Reading file : %s\n", file_name);
		}
	}
	else
	{
		printf("\nThis runnable can't read arguments from the command line.\n");
		return(1);
	}
	yylex();
	//showTables();
	BruteForceAlgorithm();
	return(0);
}

// FIX ME
void BruteForceAlgorithm() {

	printf("\nStarting Brute Force Algorithm\n\n");

	// Initialize

	strcat(T, "#");				// T <- T º '#'
	STATE = q; 					// STATE <- 'q'
	i = 0; 						// i <- 0
	HIST[0].P = 0;				// P#[1] <- 0
	HIST[0].SYMB = ' '; 		// SYMB[1] <- ' '
	T_HIST = 0; 				// T_HIST <- 1
	strcpy(SENT, &LHS[0].NT);
	strcat(SENT, "#"); 			// SENT <- NT[1] º '#'

	char help [MAX_LONGITUD] = "";
	char help2 [MAX_LONGITUD] = "";
	char help3 [MAX_LONGITUD] = "";
	
	unsigned int CASE = 0; // Current configuration of the sentenial form
	
	// [Loop until parse is either successful or unsuccessful]
	while(true) {
		
		//[Get stack-top elements and determine current configuration]

		unsigned int p = HIST[T_HIST].P; // p <- P#[T_HIST]
		char s = HIST[T_HIST].SYMB;		 // s <- SYMB[T_HIST]
		char t_local = SENT[0];   		 // t <- SUB(SENT, 1, 1)
		// (Determine stack-top elements)

		if (STATE == q && i == n && t_local == '#') {
			CASE = 3; // (case 3)
		} else {
			if (STATE == q) {
				if (getFunctionValue(t_local) > -1) {
					CASE = 1;
				} else  {
					if(t_local == T[i]) {
						CASE = 2;
					} else {
						CASE = 4;
					}
				}
			} else {
				if (getFunctionValue(s) == -1) {
					CASE = 5;
				} else {
					if (p < LHS[getFunctionValue(s)].MAX) {
						CASE = 6;
					} else {
						if (i == 1 && s == LHS[0].NT) {
							printf("\nUNSUCCESSFUL PARSE\n\n");
							break;
						} else {
							CASE = 7;
						}
					}
				}
			}
		}

		// [Select the correct case]

		switch(CASE) {
			case 1:
				printf("(Case 1: (%u, %d, %c, %s) |- ", STATE, i, t_local, SENT);
				T_HIST++;
				HIST[T_HIST].P = 1;
				HIST[T_HIST].SYMB = t_local;
				strcpy(help, "");
				strcpy(help, SENT + 1);
				strcpy(SENT, RHS[LHS[getFunctionValue(t_local)].FIRST]);
				strcat(SENT, help);
				printf("(%u, %d, %c, %s))\n", STATE, i, t_local, SENT);
				break;
			case 2:
				printf("(Case 2: (%u, %d, %c, %s) |- ", STATE, i, t_local, SENT);
				T_HIST++;
				HIST[T_HIST].P = 0;
				HIST[T_HIST].SYMB = t_local;
				i++;
				strcpy(help, "");
				strcpy(help, SENT + 1);
				strcpy(SENT, help);
				printf("(%u, %d, %c, %s))\n", STATE, i, t_local, SENT);
				break;
			case 3:
				printf("(Case 3: (%u, %d, %c, %s) |- ", STATE, i, t_local, SENT);
				STATE = t;
				strcpy(SENT, "");
				printf("(%u, %d, %c, %s))\n", STATE, i, t_local, SENT);
				printf("\nSUCCESSFUL PARSE\n\n");
				exit(0);
				break;
			case 4:
				printf("(Case 4: (%u, %d, %c, %s) |- ", STATE, i, t_local, SENT);
				STATE = b;
				printf("(%u, %d, %c, %s))\n", STATE, i, t_local, SENT);
				break;
			case 5:
				printf("(Case 5: (%u, %d, %c, %s) |- ", STATE, i, t_local, SENT);
				i--;
				T_HIST--;
				strcpy(help, "");
				strcpy(help, &s);
				strcat(help, SENT);
				strcpy(SENT, help);
				printf("(%u, %d, %c, %s))\n", STATE, i, t_local, SENT);
				break;
			case 6:
				printf("(Case 6: (%u, %d, %c, %s) |- ", STATE, i, t_local, SENT);
				STATE = q;
				HIST[T_HIST].P = p + 1;
				strcpy(help, "");
				strcpy(help2, "");
				strcpy(help, RHS[LHS[getFunctionValue(s)].FIRST + p]);
				strcpy(help2, SENT + (strlen(RHS[LHS[getFunctionValue(s)].FIRST + p - 1])));
				strcat(help, help2);
				strcpy(SENT, help);
				printf("(%u, %d, %c, %s))\n", STATE, i, t_local, SENT);
				break;
			default:
				printf("(Case 7: (%u, %d, %c, %s) |- ", STATE, i, t_local, SENT);
				strcpy(help, "");
				strcpy(help2, "");
				strcpy(help, &s);
				strcpy(help2, SENT + strlen(RHS[LHS[getFunctionValue(s)].FIRST + p - 1]));
				strcat(help, help2);
				//printf("SENT + %lu = %s\n",strlen(RHS[LHS[getFunctionValue(s)].FIRST + p - 1]), SENT + strlen(RHS[LHS[getFunctionValue(s)].FIRST + p - 1]));
				strcpy(SENT, help);
				printf("(%u, %d, %c, %s))\n", STATE, i, t_local, SENT);
				T_HIST--;
				break;
		}

	}
}

int getFunctionValue(const char x) {
	bool found = false;
	unsigned int position = 0;
	for(unsigned int j = 0; j < LHS_ELEMENTS_COUNT; j++) {
		if(LHS[j].NT == x) {
			found = true;
			position = j;
			break;
		}
	}

	if (found) {
		return position;
	} else {
		return -1;
	}
}

void showTables() {
	printf("\nLHS\n\nNT\tMAX\tFIRST\n");
	for(unsigned int k = 0; k < LHS_ELEMENTS_COUNT; k++) {
		printf("%c\t%d\t%d\n", LHS[k].NT, LHS[k].MAX, LHS[k].FIRST);
	}
	printf("\nRHS\n\n");
	for(unsigned int k = 0; k < RHS_ELEMENTS_COUNT; k++) {
		printf("%s\n", RHS[k]);
	}
	printf("\n");
}