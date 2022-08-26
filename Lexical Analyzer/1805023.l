%option noyywrap

%x cmstate
%x CHAR_SCAN
%x STRING_SCAN
%x SINGLE_LINE_COMMENT_SCAN
%{
#include<stdio.h>
#include<stdlib.h>
#include<string>
#include<iostream>
#include "1805023_SymbolTable.cpp"
using namespace std;

string cm="";
int line=1;
int error_cnt=0;
ofstream tokenStream, logStream;
SymbolTable st(7);
string s1 ,s2;
int stringStartLine;
%}

/* Rules Section*/


WHITESPACE [  \f\r\t\v]+
NEWLINE \r?\n
DIGIT [0-9]
DIGITS {DIGIT}+
INT_LITERAL {DIGITS}
FLOAT_EXP1 {DIGIT}*\.{DIGIT}+
FLOAT_EXP2 {DIGIT}+\.{DIGIT}*
FLOAT_EXP3 {FLOAT_EXP1}[Ee][+-]?{DIGITS}
FLOAT_EXP4 {FLOAT_EXP2}[Ee][+-]?{DIGITS}
FLOAT_EXP5 {DIGITS}[Ee][+-]?{DIGITS}
FLOAT_LITERAL  {FLOAT_EXP1}|{FLOAT_EXP2}|{FLOAT_EXP3}|{FLOAT_EXP4}|{FLOAT_EXP5}
TOO_MANY_DECIMAL_POINT {DIGIT}*\.({DIGIT}*\.{DIGIT}*)+
EXPONENTIAL {FLOAT_EXP3} | {FLOAT_EXP4} | {FLOAT_EXP5}
ILL_FORMED_NUMBER1 {EXPONENTIAL}\.({DIGIT}*\.{DIGIT}*)*
ILL_FORMED_NUMBER {DIGIT}*(\.)?{DIGIT}*[Ee]{DIGIT}*\.({DIGIT}*(\.)*{DIGIT}*)*
NORMAL_CHAR '([ -�]{-}[\\])'
SPECIAL_CHAR '(\\([nt\\afrbv0\']))'
WRONG_FORMATTED_CHAR '\\'
UNTERMINATED_CHAR '([ -�]{-}[\']*)
CHAR_LITERAL {NORMAL_CHAR}|{SPECIAL_CHAR}
MULTI_CHAR1 '(([ -�]{-}[\\\'])([ -�]{-}[\']+))'
MULTI_CHAR2 '(\\([ -�]{-}[nt\\afrbv0\']))'
MULTI_CHAR3 '([ -�]{-}[\'][ -�]{-}[\']([ -�]{-}[\']+))'
MULTI_CHAR {MULTI_CHAR1}|{MULTI_CHAR2}|{MULTI_CHAR3}
EMPTY_CHAR ''
MULTILINE_COMMENT (\/\*)([^\*]|\*[^\/])*(\*\/)
UNFINISHED_COMMENT (\/\*)([^\*]|\*[^\/])*
IDENTIFIER [A-Za-z_][a-zA-Z0-9_]*
INVALID_PREFIX ({DIGIT}+)([A-Za-z_]+)([a-zA-Z0-9]*)

ADDOP [+-]
MULOP [*/%]
INCOP ("++"|"--")
RELOP ("<"|"<="|">"|">="|"=="|"!=")
ASSIGNOP [=]
LOGICOP ("&&"|"||")




%%
{WHITESPACE}    {}
{NEWLINE} {
	++line;
	
}
"if" {
			tokenStream << "<IF> ";
			logStream << "Line no " << line<< ":  TOKEN <IF> Lexeme " << yytext <<" found\n";
			logStream << endl;
}   
"else" {
			tokenStream << "<ELSE> ";
			logStream << "Line no " << line<< ":  TOKEN <ELSE> Lexeme " << yytext <<" found\n";
			logStream << endl;
}
"for" {
			tokenStream << "<FOR> ";
			logStream << "Line no " << line<< ":  TOKEN <FOR> Lexeme " << yytext <<" found\n";
			logStream << endl;
}
"while" {
			tokenStream << "<WHILE> ";
			logStream << "Line no " << line<< ":  TOKEN <WHILE> Lexeme " << yytext <<" found\n";
			logStream << endl;
}
"do" {
			tokenStream << "<DO> ";
			logStream << "Line no " << line<< ":  TOKEN <DO> Lexeme " << yytext <<" found\n";
			logStream << endl;
}
"break" {
			tokenStream << "<BREAK> ";
			logStream << "Line no " << line<< ":  TOKEN <BREAK> Lexeme " << yytext <<" found\n";
			logStream << endl;
}
"int" {
			tokenStream << "<INT> ";
			logStream << "Line no " << line<< ":  TOKEN <INT> Lexeme " << yytext <<" found\n";
			logStream << endl;
}
"char" {
			tokenStream << "<CHAR> ";
			logStream << "Line no " << line<< ":  TOKEN <CHAR> Lexeme " << yytext <<" found\n";
			logStream << endl;
}
"float" {
			tokenStream << "<FLOAT> ";
			logStream << "Line no " << line<< ":  TOKEN <FLOAT> Lexeme " << yytext <<" found\n";
			logStream << endl;
}
"double" {
			tokenStream << "<DOUBLE> ";
			logStream << "Line no " << line<< ":  TOKEN <DOUBLE> Lexeme " << yytext <<" found\n";
			logStream << endl;
}
"void" {
			tokenStream << "<VOID> ";
			logStream << "Line no " << line<< ":  TOKEN <VOID> Lexeme " << yytext <<" found\n";
			logStream << endl;
}	
"return"  {
			tokenStream << "<RETURN> ";
			logStream << "Line no " << line<< ":  TOKEN <RETURN> Lexeme " << yytext <<" found\n";
			logStream << endl;
}	
"switch"  {
			tokenStream << "<SWITCH> ";
			logStream << "Line no " << line<< ":  TOKEN <SWITCH> Lexeme " << yytext <<" found\n";
			logStream << endl;
}
"case" {
			tokenStream << "<CASE> ";
			logStream << "Line no " << line<< ":  TOKEN <CASE> Lexeme " << yytext <<" found\n";
			logStream << endl;
}		
"default" {
			tokenStream << "<DEFAULT> ";
			logStream << "Line no " << line<< ":  TOKEN <DEFAULT> Lexeme " << yytext <<" found\n";
			logStream << endl;
}		
"continue" {
			tokenStream << "<CONTINUE> ";
			logStream << "Line no " << line<< ":  TOKEN <CONTINUE> Lexeme " << yytext <<" found\n";
			logStream << endl;
}	
{ADDOP} {
			tokenStream << "<ADDOP, "<< yytext << "> ";
			logStream << "Line no " << line<< ":  TOKEN <ADDOP> Lexeme " << yytext <<" found\n";
			logStream << endl;	
}	
{MULOP} {
			tokenStream << "<MULOP, "<< yytext << "> ";
			logStream << "Line no " << line<< ":  TOKEN <MULOP> Lexeme " << yytext <<" found\n";	
			logStream << endl;
}
{INCOP} {
			tokenStream << "<INCOP, "<< yytext << "> ";
			logStream << "Line no " << line<< ":  TOKEN <INCOP> Lexeme " << yytext <<" found\n";	
			logStream << endl;
}
{RELOP} {
			tokenStream << "<RELOP, "<< yytext << "> ";
			logStream << "Line no " << line<< ":  TOKEN <RELOP> Lexeme " << yytext <<" found\n";	
			logStream << endl;
}
{ASSIGNOP} {
			tokenStream << "<ASSIGNOP, "<< yytext << "> ";
			logStream << "Line no " << line<< ":  TOKEN <ASSIGNOP> Lexeme " << yytext <<" found\n";
			logStream << endl;
}
{LOGICOP} {
			tokenStream << "<LOGICOP, "<< yytext << "> ";
			logStream << "Line no " << line<< ":  TOKEN <LOGIC> Lexeme " << yytext <<" found\n";	
			logStream << endl;
}
"!" {
			tokenStream << "<NOT, "<< yytext << "> ";
			logStream << "Line no " << line<< ":  TOKEN <NOT> Lexeme " << yytext <<" found\n";	
			logStream << endl;
}
"(" {
			tokenStream << "<LPAREN, "<< yytext << "> ";
			logStream << "Line no " << line<< ":  TOKEN <LPAREN> Lexeme " << yytext <<" found\n";	
			logStream << endl;
}
")" {
			tokenStream << "<RPAREN, "<< yytext << "> ";
			logStream << "Line no " << line<< ":  TOKEN <RPAREN> Lexeme " << yytext <<" found\n";	
			logStream << endl;
}
"{" {
			tokenStream << "<LCURL, "<< yytext << "> ";
			logStream << "Line no " << line<< ":  TOKEN <LCURL> Lexeme " << yytext <<" found\n";	
			logStream << endl;
			st.enterScope();
}
"}" {
			tokenStream << "<RCURL, "<< yytext << "> ";
			logStream << "Line no " << line<< ":  TOKEN <RCURL> Lexeme " << yytext <<" found\n";
			logStream << endl;
			st.exitScope();	
}
"[" {
			tokenStream << "<LTHIRD, "<< yytext << "> ";
			logStream << "Line no " << line<< ":  TOKEN <LTHIRD> Lexeme " << yytext <<" found\n";
			logStream << endl;

}
"]"     {
			tokenStream << "<RTHIRD, "<< yytext << "> ";
			logStream << "Line no " << line<< ":  TOKEN <RTHIRD> Lexeme " << yytext <<" found\n";	
			logStream << endl;
}
","   {
			tokenStream << "<COMMA, "<< yytext << "> ";
			logStream << "Line no " << line<< ":  TOKEN <COMMA> Lexeme " << yytext <<" found\n";	
			logStream << endl;
}
";"    {
			tokenStream << "<SEMICOLON, "<< yytext << "> ";
			logStream << "Line no " << line<< ":  TOKEN <SEMICOLON> Lexeme " << yytext <<" found\n";	
			logStream << endl;
}


{IDENTIFIER} {
			tokenStream << "<ID, "<< yytext << "> ";
			logStream << "Line no " << line << ":  TOKEN <ID> Lexeme " << yytext <<" found\n";
			logStream << endl;
			bool inserted = st.insert(yytext,"ID");
			if(inserted){
				st.printAll(logStream);
			}
			else {
				logStream << yytext << " already exists in current ScopeTable\n" << endl;
			}
}

{DIGITS} {
	tokenStream << "<CONST_INT, " << yytext << "> ";
    logStream << "Line no " << line << ":  TOKEN <CONST_INT> Lexeme " << yytext << " found\n";
    logStream << endl;
    bool inserted = st.insert(yytext, "CONST_INT");
    if (inserted) {
        st.printAll(logStream);
    }

}
{FLOAT_LITERAL} {
	tokenStream << "<CONST_FLOAT, " << yytext << "> ";
    logStream << "Line no " << line << ":  TOKEN <CONST_FLOAT> Lexeme " << yytext << " found\n";
    logStream << endl;
    bool inserted = st.insert(yytext, "CONST_FLOAT");
    if (inserted) {
        st.printAll(logStream);
    }
}
{TOO_MANY_DECIMAL_POINT} {
	    logStream << "Error at line no  " << line << ": " << "Too Many Decimal Points " <<  yytext << endl;
		logStream << endl; 
		error_cnt++;
}
{ILL_FORMED_NUMBER} {
		logStream << "Error at line no "  << line << ": " << "Ill Formed Number " <<  yytext << endl;
		logStream << endl;
		error_cnt++;
}
{CHAR_LITERAL} {
	    string str = yytext;
		char ans ;
		if(str[1] == '\\') {
			if(str[2]== '\\') ans = '\\' ;
			if(str[2]== 'n') ans = '\n'  ;
			if(str[2]== 't') ans = '\t'  ;
			if(str[2] =='a') ans = '\a'  ;
			if(str[2] == 'f') ans = '\f' ;
			if(str[2] == 'r') ans = '\r' ;
			if(str[2] == 'b') ans = '\b' ;
			if(str[2] == 'v') ans = '\v' ;
			if(str[2] == '0') ans = '\0' ;
			if(str[2] == '\'') ans = '\'';
		}
		else ans = str[1];
		tokenStream << "<CONST_CHAR, "<< ans << "> ";
		logStream << "Line no " << line<< ":  TOKEN <CONST_CHAR> Lexeme " << yytext <<" found --> " <<   "<CONST_CHAR, "<< ans << ">\n";
		logStream << endl;
		bool inserted = st.insert(yytext,"CONST_CHAR");
		if(inserted){
			st.printAll(logStream);
		}
}

{WRONG_FORMATTED_CHAR} {
		logStream << "Error at line no  " << line << ": " << "Wrong formatted Character " <<  yytext << endl;
		logStream << endl;
		error_cnt++;
}
{MULTI_CHAR} {
		logStream << "Error at line no  " << line << ": " << "Multiple character constant " <<  yytext << endl;
		logStream << endl;
		error_cnt++;
}
{EMPTY_CHAR} {
		logStream << "Error at line no  " << line << ": " << "Empty character constant " <<  yytext << endl;
		logStream << endl;
		error_cnt++;
}

\" {
	s1.clear();
	s2.clear();
	s1 +=yytext;
	stringStartLine = line;
	BEGIN STRING_SCAN;
}

<STRING_SCAN>\\n {
	s1+=yytext;
	s2+='\n';
}


<STRING_SCAN>\\r {
	s1+=yytext;
	s2+='\r';
}


<STRING_SCAN>\\\\ {
	s1+=yytext;
	s2+='\\';
}

<STRING_SCAN>\\t {
	s1+=yytext;
	s2+='\t';
}
<STRING_SCAN>\\0 {
	s1+=yytext;
	s2+='\0';
}


<STRING_SCAN>\\v {
	s1+=yytext;
	s2+='\v';
}

<STRING_SCAN>\\\' {
	s1+=yytext;
	s2+='\'';
}

<STRING_SCAN>\\a {
	s1+=yytext;
	s2+='\a';
}

<STRING_SCAN>\\f {
	s1+=yytext;
	s2+='\f';
}



<STRING_SCAN>\\b {
	s1+=yytext;
	s2+='\b';
}




<STRING_SCAN>\\{NEWLINE} {
	line++;
	s1+=yytext;
}

<STRING_SCAN>"\\\"" {
	s1+=yytext;
	s2+='\"';
}

<STRING_SCAN>\" {
	s1+=yytext;
	tokenStream << "<STRING, \"" << s2 << "\" > ";
	logStream << "Line no " << line << ": Token <STRING> Lexeme " << s1 << " found --> <STRING, \"" << s2 << "\" > \n";
	logStream << endl;	
	bool inserted = st.insert("\"" + s2 + "\"", "STRING");
	if(inserted){
		st.printAll(logStream);
	}
	s1.clear();
	s2.clear();	
	BEGIN INITIAL;
}

<STRING_SCAN>[ -�] {
	s1+=yytext;
	s2+=yytext;
}

<STRING_SCAN>{NEWLINE} {
	logStream << "Error at line no  " << stringStartLine << ": " << "Unterminated String " <<  s1  << endl;
	logStream << endl;
	error_cnt++;
	line++;
	s1.clear();
	s2.clear();
	BEGIN INITIAL;
}

<STRING_SCAN><<EOF>> {
	logStream << "Error at line no  " << stringStartLine << ": " << "Unterminated String " <<  s1 << endl;
	logStream << endl;
	error_cnt++;
	st.printAll(logStream);
	return 0;
}
"//" {
	s1.clear() ;
	s2.clear() ;
	stringStartLine = line ;
	BEGIN SINGLE_LINE_COMMENT_SCAN;
}

<SINGLE_LINE_COMMENT_SCAN>{NEWLINE} {
	logStream<<"Line no "<<line<<": Token <COMMENT> Lexeme "<< s1 <<" found\n";
	++line ;
	BEGIN INITIAL;
}
<SINGLE_LINE_COMMENT_SCAN>[ -�] {
	s1 += yytext;
}
<SINGLE_LINE_COMMENT_SCAN>\\{NEWLINE} {
	++line ;
	s1 += yytext;
}
<SINGLE_LINE_COMMENT_SCAN><<EOF>> {
	logStream<<"Line no "<<line<<": Token <COMMENT> Lexeme "<< s1 <<" found\n";
	st.printAll(logStream) ;
	logStream<<"\nTotal lines: "<<line<<'\n';
	logStream<<"Total errors: "<<error_cnt<<'\n';
	return 0;
}

{MULTILINE_COMMENT}  {
		logStream << "Line no " << line<< ":  TOKEN <COMMENT> Lexeme " << yytext <<" found\n";
		for(int i = 0; i < strlen(yytext); i++){
			if(yytext[i] == '\n'){
				line++;
			}
		}	
		logStream << endl;			
}
{UNFINISHED_COMMENT} {
		logStream << "Error at line no  " << line << ": " << "Unterminated Comment " <<  yytext << endl;
		for(int i = 0; i < strlen(yytext); i++){
			if(yytext[i] == '\n'){
				line++;
			}
		}
		error_cnt++;
}





{INVALID_PREFIX} {
	logStream << "Error at line no  " << line << ": " << "Invalid prefix on ID or invalid suffix on Number " <<  yytext << endl;
	logStream << endl;
	error_cnt++;
}

{UNTERMINATED_CHAR} {
		logStream << "Error at line no  " << line << ": " << "Unterminated Character " <<  yytext << endl;
		logStream << endl;
		error_cnt++;
}
. {
		logStream << "Error at line no  " << line << ": " << "Unrecognized Character " <<  yytext << endl;
		logStream << endl;
		error_cnt++;
}
<<EOF>> {
	line--;
	st.printAll(logStream);
	logStream << "Total Lines: " << line<< endl;
	logStream << "Total Errors: " << error_cnt << endl;
	return 0;
}


%%
int main(int argc,char *argv[]){
	
	if(argc!=2){
		cout << "Please provide input file name and try again\n";
		return 0;
	}
	
	FILE *file=fopen(argv[1],"r");
	if(file==NULL){
		cout << "Cannot open specified file\n";
		return 0;
	}
	tokenStream.open("1805023_token.txt");
	logStream.open("1805023_log.txt") ;
	yyin= file;
	yylex();
	fclose(yyin);
	logStream.close();
	tokenStream.close();
	return 0;
}