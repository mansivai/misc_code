/* Filename: Compiler.cpp
CSC 340 - Programming Languages
Sergio Yraita, Jr.

A lexical analyzer system for simple arithmetic expressions.

Operator/keyword: +, -, *, /, %, (, ), ;, TRUE, FALSE, ||, &&, !, if, else, {, }
Identifier: (a+b+...+z+A+B+...Z)(a+b+...+z+A+B+...Z+0+1+2+...+9)*
Integer: (0+1+2+...+9)(0+1+2+...+9)*

BNF Grammar:
<ifstmt> -> if (<boolexpr>) '{'<assign>'}' | if (<boolexpr>) '{'<assign>'}' else '{'<assign>'}'
<boolexpr> -> <boolexpr> || <boolterm> | <boolterm>
<boolterm> -> <boolterm> && <boolfactor> | <boolfactor>
<boolfactor> -> TRUE | FALSE | ! <boolfactor> | (<boolexpr>)
<assign> -> id = <expr>; | id = <expr>; <assign>
<expr> -> <term> + <expr> | <term> - <expr> | <term>
<term> -> <factor> * <term> | <factor> / <term> | <factor> % <term> | <factor>
<factor> -> id | int_constant | (<expr>)
*/

#include <iostream>
#include <fstream>
#include <cctype>
using namespace std;

/* Global declarations */
/* Variables */

int charClass;
char lexeme[100];
char nextChar;
int lexLen;
int token;
int nextToken;
int error_count = 0;		//
ifstream in_fp("syntax.txt");

/* Function declarations */
void getChar();
void addChar();
int lex();      // to get the nextToken
void ifstmt();
void term();
void expr();
void boolExpr();
void boolTerm();
void boolFactor();
void assign();
void factor();
void getNonBlank();
void boolFactor();

/* Character classes */
#define LETTER 0
#define DIGIT 1
#define UNKNOWN 99

/* Token codes */
#define INT_LIT 10
#define IDENT 11
#define ADD_OP 21
#define SUB_OP 22
#define MULT_OP 23
#define DIV_OP 24
#define MOD_OP 27

#define LEFT_PAREN 25
#define RIGHT_PAREN 26

#define ASSIGN 100
#define SEMICOL 101

#define TRUE_TOKEN 203
#define FALSE_TOKEN 204

#define IF_TOKEN 201
#define ELSE_TOKEN 202
#define AND_TOKEN 205
#define OR_TOKEN 206
#define NOT_TOKEN 207

#define LEFT_BRACE 300
#define RIGHT_BRACE 301

/******************************************************/
/* main driver */
void main()
{
	/* Open the input data file and process its contents */

	if (in_fp.fail())
	{
		cout << "File could not be opened\n";
		cin.get();
		exit(1);
	}
	else {
		getChar();
		lex();
		ifstmt();
		if (error_count < 1) {
			cout << "\n****************************************\n";
			cout << "Build Succesful. You are great! " << error_count << " Failed \n";
			cout << "\n****************************************\n";
		}
		else {
			cout << "\n**********************************\n";
			cout << "Build Failed! You Suck! " << error_count << " error(s)\n";
			cout << "\n**********************************\n";
		}
	}
	in_fp.close();

	system("PAUSE");
}

/*****************************************************/
/* lookup - a function to lookup operators and parentheses
and return the token */
int lookup(char ch)
{
	switch (ch) {
	case '!':
		addChar();
		nextToken = NOT_TOKEN;
		break;
	case '{':
		addChar();
		nextToken = LEFT_BRACE;
		break;
	case '}':
		addChar();
		nextToken = RIGHT_BRACE;
		break;
	case '(':
		addChar();
		nextToken = LEFT_PAREN;
		break;
	case ')':
		addChar();
		nextToken = RIGHT_PAREN;
		break;
	case '+':
		addChar();
		nextToken = ADD_OP;
		break;
	case '-':
		addChar();
		nextToken = SUB_OP;
		break;
	case '*':
		addChar();
		nextToken = MULT_OP;
		break;
	case '%':
		addChar();
		nextToken = MOD_OP;
		break;
	case '/':
		addChar();
		nextToken = DIV_OP;
		break;
	case '=':
		addChar();
		nextToken = ASSIGN;
		break;
	case ';':
		addChar();
		nextToken = SEMICOL;
		break;
	default:
		addChar();
		nextToken = EOF;
		break;
	}
	return nextToken;
}

/*****************************************************/
/* addChar - a function to add nextChar to lexeme */
void addChar()
{
	if (lexLen <= 98) {
		lexeme[lexLen++] = nextChar;
		lexeme[lexLen] = 0;
	}
	else {
		cout << " Error - lexeme is too long \n";
	}
}

/*****************************************************/
/* getChar - a function to get the next character of
input and determine its character class */
void getChar()
{
	in_fp.get(nextChar);
	if (in_fp.eof())   // if no more characters in the file
		nextChar = EOF;

	if (nextChar != EOF) {
		if (isalpha(nextChar))
			charClass = LETTER;
		else if (isdigit(nextChar))
			charClass = DIGIT;
		else charClass = UNKNOWN;
	}
	else
		charClass = EOF;
}


/*****************************************************/
/* getNonBlank - a function to call getChar until it
returns a non-whitespace character */
void getNonBlank()
{
	while (isspace(nextChar))
		getChar();
}

/***************************************************** /
/* lex - a simple lexical analyzer for arithmetic expressions */
int lex()
{
	lexLen = 0;
	getNonBlank();
	switch (charClass) {
		/* Parse identifiers */
	case LETTER:
		addChar();
		getChar();
		while (charClass == LETTER || charClass == DIGIT) {
			addChar();
			getChar();
		}
		nextToken = IDENT;

		if (lexeme[0] == 'T' && lexeme[1] == 'R' && lexeme[2] == 'U' && lexeme[3] == 'E' && lexeme[4] == 0) {
			nextToken = TRUE_TOKEN;
		}

		if (lexeme[0] == 'F' && lexeme[1] == 'A' && lexeme[2] == 'L' && lexeme[3] == 'S' && lexeme[4] == 'E' && lexeme[5] == 0) {
			nextToken = FALSE_TOKEN;
		}

		if (lexeme[0] == 'i' && lexeme[1] == 'f' && lexeme[2] == 0) {
			nextToken = IF_TOKEN;
		}

		if (lexeme[0] == 'e' && lexeme[1] == 'l' && lexeme[2] == 's' && lexeme[3] == 'e' && lexeme[4] == 0) {
			nextToken = ELSE_TOKEN;
		}

		break;

		/* Parse integer literals */
	case DIGIT:
		addChar();
		getChar();
		while (charClass == DIGIT) {
			addChar();
			getChar();
		}
		nextToken = INT_LIT;
		break;
		/* Parentheses and operators */

	case UNKNOWN:
		lookup(nextChar);
		getChar();

		/* 
		   If the next lexeme is in fact '&&' or '||', nextToken var should contain 'EOF'
		   after calling lookup() and getChar(). 
		   If it is, enter this code block to check for boolean ops.
		*/
		if (nextToken == EOF)
		{
			addChar();
			getChar();

			if (lexeme[0] == '&' && lexeme[1] == '&' && lexeme[2] == 0)
			{
				nextToken = AND_TOKEN;
			}
			else if (lexeme[0] == '|' && lexeme[1] == '|' && lexeme[2] == 0)
			{
				nextToken = OR_TOKEN;
			}
		}
		break;
		/* EOF */

	case EOF:
		nextToken = EOF;
		lexeme[0] = 'E';
		lexeme[1] = 'O';
		lexeme[2] = 'F';
		lexeme[3] = 0;
		break;
	} /* End of switch */
	cout << "Next token is: " << nextToken
		<< "       Next lexeme is " << lexeme << "\n";
	return nextToken;
} /* End of function lex */

/* Function expr Parses strings in the languagegenerated by the rule:<expr> -> <term> {(+ | -) <term>}*/
void expr() {
	/* Parse the first term */
	term(); /* As long as the next token is + or -, call lexto get the next token and parse the next term */
	while (nextToken == ADD_OP || nextToken == SUB_OP) {
		lex(); // to get the nextToken
		term();
	}
}

/* termParses strings in the language generated by the rule:
   term> -> <factor> {(* | /) <factor>}*/
void term() {
	/* Parse the first factor */
	factor();
	/* As long as the next token is * or /,next token and parse the next factor */
	while (nextToken == MULT_OP || nextToken == DIV_OP || nextToken == MOD_OP) {
		lex();
		factor();
	}
} /* End of function term */

/*
Function factorParses strings in the language generated by the rule:
<factor> -> id | int_constant |( <expr>)
*/
void factor() {
	/* Determine which RHS */
	if (nextToken == IDENT || nextToken == INT_LIT)
		/* For the RHS id or int, just call lex */
		lex();
	/* If the RHS is (<expr>) –call lex to pass overthe left parenthesis, call expr, and check forthe right parenthesis */
	else if (nextToken == LEFT_PAREN) {
		lex();
		expr();
		if (nextToken == RIGHT_PAREN)
			lex();
		else {
			error_count++;
			cout << "ERROR #1 - Missing a right parentheses\n";
		}
	}  /* End of else if (nextToken == ...  */
	else {
		error_count++;
		cout << "ERROR #2 - missing left parentheses\n";
	}
	/* Neither RHS matches */
}

/*<assign> -> id = <expr>; | id = <expr>; <assign>*/
void assign() {
	if (nextToken == IDENT) {
		lex();
		if (nextToken == ASSIGN) {
			lex();
			expr();
			if (nextToken == SEMICOL) {
				lex();
				if (nextToken != EOF && nextToken != RIGHT_BRACE)
					assign();
			}
			else {
				error_count++;
				cout << "ERROR #5 - statement must end with semicolon ';' \n";
			}
		}
		else {
			error_count++;
			cout << "ERROR #4 - missing assignment token '=' \n";
		}
	}
}

/* <boolfactor> -> TRUE | FALSE | ! <boolfactor> | (<boolexpr>) */
void boolFactor() {
	/* Determine which RHS */
	if (nextToken == TRUE_TOKEN || nextToken == FALSE_TOKEN)
		lex();
	else if (nextToken == NOT_TOKEN) {
		lex();
		boolFactor();
	}
	else if (nextToken == LEFT_PAREN) {
		lex();
		boolExpr();
		if (nextToken == RIGHT_PAREN)
			lex();
		else {
			error_count++;
			cout << "ERROR #21: Missing a right parentheses\n";
		}
	}
	else {
		error_count++;
		cout << "ERROR #22: Missing a left parentheses\n";
	}
}


/* <boolterm> -> <boolfactor> {&& <boolfactor>} */
void boolTerm() {
	boolFactor();
	while (nextToken == AND_TOKEN) {
		lex();
		boolFactor();
	}
}


/* <boolexpr> -> <boolterm> {|| <boolterm>} */
void boolExpr() {
	boolTerm();
	while (nextToken == OR_TOKEN) {
		lex();
		boolTerm();
	}
}


/* <ifstmt> -> if (<boolexpr>) '{'<assign>'}'[else '{'<assign>'}] */
void ifstmt() {
	if (nextToken == IF_TOKEN) {
		lex();
		if (nextToken == LEFT_PAREN) {
			lex();
			boolExpr();
			if (nextToken == RIGHT_PAREN) {
				lex();
				if (nextToken == LEFT_BRACE) {
					lex();
					assign();
					if (nextToken == RIGHT_BRACE) {
						lex();
						if (nextToken == ELSE_TOKEN) {
							lex();
							if (nextToken == LEFT_BRACE) {
								lex();
								assign();
								if (nextToken == RIGHT_BRACE) {
									lex();
								}
								else {
									error_count++;
									cout << "ERROR #17: Missing Right brace\n";
								}
							}
							else {
								error_count++;

								cout << "ERROR #16: Missing Else\n";
							}
						}
					}
					else {
						error_count++;
						cout << "ERROR #15: Missing Right Brace\n";
					}
				}
				else {
					error_count++;
					cout << "ERROR #14; Missing Left Brace\n";
				}
			}
			else {
				error_count++;
				cout << "ERROR #13: Missing Right parentheses\n";
			}
		}
		else {
			error_count++;
			cout << "ERROR #12: Missing left parentheses\n";
		}
	}
	else {
		error_count++;
		cout << "ERROR #11: Must begin with if statement\n";
	}

}