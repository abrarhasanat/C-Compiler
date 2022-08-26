%{
#include<bits/stdc++.h>
#include "1805023_SymbolTable.cpp"
#include "printHelper.cpp"
#include "CodeOptimize.cpp"
#define  gap  "\n\t\t" 
using namespace std ;
int yyparse(void);
int  yylex(void);
extern FILE *yyin;
ofstream errorStream;
ofstream logStream;
ofstream asmStream;
SymbolTable st(30); 
int anyError = 0 ;
int stackCount = 0  ;
extern int line; 
extern int error_cnt;
bool anyVoid ;
string varType; 
string currReturnType;
vector <pair < string ,string >> parameters; 
bool returnStatement = false;  
string returnType = "" ;
int returnLine ;
int levelCount   = 0 ;
vector < int > jumpEnd ;
vector<int>endIf;
vector<int>endWhile;
vector<int>endFunc ;
vector<int>forStatementLevel;
vector<int>forUpdateLevel; 
bool codeStarted =  false ;
void yyerror(string s) {
   //write your code
    //error_cnt++;
    logStream << "Error at line " << line << ": " << s << "\n" ; 
    errorStream << "Error at line " << line << ": " << s << "\n" ;
 }

void pop(string reg) {
    asmStream << "\n\t\tPOP "<< reg ;
 }
 void push(string reg)  {
    asmStream << "\n\t\tPUSH " << reg ; 
 }

 string getVaiableName(string s ) { 
    string varName = "" ; 
    for (int i =  0 ; i < s.length() ; ++i ) { 
        if(s[i] == '[') break ;
        varName.push_back(s[i]) ;  
    }
    return varName ;

 }
 void writeAsm(string s ) { 
    asmStream << gap << s ;
 }

 void newLevel() { 
    ++levelCount  ; 
    asmStream << gap << "@L_" <<levelCount << ": " ;
 }
 string parseInteger(int k ) {
    stringstream ss;  
    ss<<k;  
    string s;  
    ss>>s;
    return s ;  
 }
 
%}


%union { 
    SymbolInfo *symbolInfo; 
}

%token IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE
%token VOID RETURN SWITCH CASE DEFAULT CONTINUE
%token ASSIGNOP INCOP DECOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON PRINTLN

%token<symbolInfo>CONST_INT
%token<symbolInfo>CONST_FLOAT
%token<symbolInfo>CONST_CHAR
%token<symbolInfo>ID
%token<symbolInfo>ADDOP
%token<symbolInfo>MULOP
%token<symbolInfo>RELOP
%token<symbolInfo>LOGICOP

%type<symbolInfo>compound_statement type_specifier parameter_list declaration_list var_declaration unit func_declaration statement statements variable expression factor arguments argument_list expression_statement unary_expression simple_expression logic_expression rel_expression term func_definition program
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE



%%

start : program
	{
		logStream<<"Line "<<line<< ": start : program\n\n";
        logStream.flush() ;

        asmStream << endl;
        asmStream << endl ;
        asmStream << endl; 
        string s = printPrintHelper() ; 
        writeAsm(s) ;

        asmStream<< "END MAIN" ; 
        asmStream << endl;



	}
;



program : program unit 
		{
			
            $$ =  new SymbolInfo($1->getName() + "\n" + $2->getName() , "") ; 
			logStream<<"Line "<<line<<": program : program unit\n\n"; 
			logStream<<$$->getName() << "\n\n" ; logStream.flush() ;
		}
		| unit 
		{
			$$ = $1 ; 
			logStream<<"Line "<<line<<": program : unit\n\n";
			logStream<<$$->getName() << "\n\n" ; logStream.flush() ;
		}
	
;
	


unit : var_declaration 
		{
			$$ = $1 ;
			logStream <<"Line "<<line<<": unit : var_declaration\n\n";
			logStream<<$$->getName() <<"\n\n" ; logStream.flush() ;
		}
     	| func_declaration 
		{
			$$ = $1 ;
			logStream<<"Line "<<line<<": unit : func_declaration\n\n";
			logStream<<$$->getName() << "\n\n";  logStream.flush() ;
		}
     	| func_definition 
		{
			$$ = $1 ; 
			logStream<<"Line "<<line<<": unit : func_definition\n\n";
			logStream<<$$->getName() << "\n\n";  logStream.flush() ;
		}
;
 



func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
    {   
        
        if(!st.insert($2->getName() ,  "ID")){
            logStream << "Error at line " << line << ": Multiple declaration of " << $2->getName() << "\n\n";
			errorStream << "Error at line " << line << ": Multiple declaration of " << $2->getName() << "\n\n";
		    error_cnt++;
            ++anyError;
        }
        else { 
            SymbolInfo * temp  = st.lookUp($2->getName()) ; 
            temp->dataType = $1->getName() ; 
            temp->storedAs = "function"; 
            temp->parameters = parameters ; 
            temp->isDefined = false ;
        }
        
        string temp = $1->getName()  +" " + $2->getName() + "(" ; 
        for (int i = 0 ; i < parameters.size();  ++i ) {
            if(i) temp += "," ;
            temp = temp + parameters[i].first; 
            if(!parameters[i].second.empty()) 
                temp = temp +  " " + parameters[i].second ;
        }
         temp += ");" ;
        parameters.clear() ;
        $$ = new SymbolInfo(temp , "_") ; 
        logStream << "Line " << line <<  ": func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n"; 
        logStream << $$->getName() << "\n\n" ;  
        logStream.flush();
    }
| type_specifier ID LPAREN RPAREN SEMICOLON
    {
        
        if(!st.insert($2->getName() ,  "ID")){
            logStream << "Error at line " << line << ": Multiple declaration of " << $2->getName() << "\n\n";
			errorStream << "Error at line " << line << ": Multiple declaration of " << $2->getName() << "\n\n";
		    error_cnt++;
            ++anyError;
        }
        else { 
            SymbolInfo * temp  = st.lookUp($2->getName()) ; 
            temp->dataType = $1->getName() ; 
            temp->storedAs = "function"; 
            temp->parameters = parameters ; 
            temp->isDefined = false ;
        }
        
        string temp = $1->getName()  +" " + $2->getName() + "(" ; 
        for (int i = 0 ; i < parameters.size();  ++i ) {
            if(i) temp += "," ;
            temp = temp + parameters[i].first; 
            if(!parameters[i].second.empty()) 
                temp = temp +  " " + parameters[i].second ;
        }
         temp += ");" ;
        parameters.clear() ;
        $$ = new SymbolInfo(temp , "_") ; 
        logStream << "Line " << line <<  ": func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n"; 
        logStream << $$->getName() << "\n\n" ;  
        logStream.flush();
    }
;




func_definition : type_specifier ID LPAREN parameter_list RPAREN 
    {
        
        SymbolInfo *temp  = st.lookUp($2->getName()) ; 
        if(temp != NULL ) { 
            //function is declared
            if(temp->isDefined || temp->storedAs != "function") { 
                        error_cnt++;
						logStream<<"Error at Line "<<line<<": Multiple declaration of "<<$2->getName()<< "\n\n"; 
						errorStream<<"Error at Line "<<line<<": Multiple declaration of "<<$2->getName() << "\n\n" ;
                        anyError += 1 ;
            }
            else { 
                //function is declared before but not defined ; 
                if(temp->dataType != $1->getName())  {
                        error_cnt++;
						logStream<<"Error at Line "<<line<<": Return type mismatch with declared functon "<<$2->getName()<< "\n\n"; 
						errorStream<<"Error at Line "<<line<<": Return type mismatch with declared function "<<$2->getName() << "\n\n" ;
                    
                        anyError += 1;
                }
                else  {
                    bool isEqual = false ;
                    if(parameters.size() == temp->parameters.size())  {
                        isEqual = true ; 
                        for (int i = 0 ; i < parameters.size() ; ++i)  {
                            if(parameters[i].first != temp->parameters[i].first ) isEqual = false; 
                        }
                    } 
                    if(isEqual == false )  {
                        logStream << "Error at Line " << line  << ": arguments mismatch with declaration\n\n" ; 
                        errorStream << "Error at Line " << line << ": arguments mismatch with declaration\n\n" ;
                        error_cnt++ ;  
                        anyError+= 1;
                    }
                    else { 
                        temp->parameters = parameters ; 
                    }
                  
                }
            }
        }
        else { 
            // function is not declared
            if(!st.insert($2->getName() ,  "ID")){
            logStream << "Error at line " << line << ": Multiple declaration of " << $2->getName() << "\n\n";
			errorStream << "Error at line " << line << ": Multiple declaration of " << $2->getName() << "\n\n";
		    error_cnt++;
            anyError += 1;
            }
            else { 
                SymbolInfo * temp  = st.lookUp($2->getName()) ; 
                temp->dataType = $1->getName() ; 
                temp->storedAs = "function"; 
                temp->parameters = parameters ; 
                temp->isDefined = true ;
            }
        }      
        
        st.enterScope() ; 
        for (int i =  0 ; i < parameters.size() ; ++i) { 
            st.insert(parameters[i].second , "ID") ; 
            SymbolInfo *temp = st.lookUp(parameters[i].second) ; 
            temp->dataType = parameters[i].first ;
            temp->isArgument = true;
            temp->argumentPos = parameters.size() - i - 1;
        }
         if(!codeStarted) { 
            writeAsm("\n\n\n.CODE\n\n\n") ; 
            codeStarted = true;
         }

        asmStream<<"\n\n\n" ;
        asmStream << $2->getName() <<"\tPROC" ;
         if($2->getName() == "main") { 
            writeAsm("MOV AX, @DATA") ;
            writeAsm("MOV DS ,AX") ; 
            writeAsm("; DATA segment loaded") ;
        }
        else {
            asmStream <<"\n\t\tPUSH BP\n\t\tMOV BP, SP\n\t\t; STORING THE GPRS\n\t\t; DX for returning results\n\t\tPUSH AX\n\t\tPUSH BX\n\t\tPUSH CX\n\t\tPUSHF";
        }
        endFunc.push_back(++levelCount) ;
    }
    compound_statement 
    {
        
        if($1->getName() == "void"  && returnStatement) { 
            logStream <<"Error at Line " << returnLine << ": " << "Return statement with a value in function void\n\n" ;
            errorStream << "Error at Line " << returnLine << ": " << "Return statement with a value in function void\n\n" ;
            error_cnt++ ; 
            anyError += 1;
        }
        
        if($1->getName() == "int" && returnType == "float") { 
            logStream << "Warning at Line " << returnLine <<": conversion from float to int\n\n" ;
            errorStream << "Warning at Line " << returnLine <<": conversion from float to int\n\n" ;
            anyError += 1;
        }
        st.printAll(logStream) ;
        st.exitScope();
        string temp = $1->getName()  +" " + $2->getName() + "(";
        for (int i = 0 ; i < parameters.size();  ++i ) {
            if(i) temp += "," ;
            temp = temp + parameters[i].first; 
            if(!parameters[i].second.empty()) 
                temp = temp +  " " + parameters[i].second ;
        }
         temp += ")\n" ;
         temp +=  $7->getName() ; 
        
        $$ = new SymbolInfo(temp , "_") ; 
        logStream << "Line " << line <<": func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n" ;
        logStream << $$->getName() << "\n\n" ; 
        logStream.flush();

        returnType = "" ;
        returnStatement = false ; 
        returnLine = -1; 



        asmStream << endl;
        writeAsm("; Return point of function " + $2->getName());
        writeAsm("@L_" + parseInteger( endFunc.back() ) + ":") ; 
        endFunc.pop_back() ;

        if($2->getName() == "main") {
            writeAsm("MOV AH ,4CH") ; 
            writeAsm("int 21h") ; 
            writeAsm("; returned control to OS") ;  
        }
        else   {
        
            writeAsm("MOV SP , BP") ; 
            writeAsm("SUB SP, 8") ;
            writeAsm("POPF") ; 
            pop("CX") ; 
            pop("BX") ; 
            pop("AX") ;
            pop("BP") ; 
            writeAsm("RET " + parseInteger(2 * parameters.size())) ; 
        }
        writeAsm($2->getName() + " ENDP  ; line  no " + parseInteger( line ) + " : function " + $2->getName() + " ended") ; 
        asmStream <<endl; 
        asmStream << endl;
        parameters.clear() ;
		
        
    }

| type_specifier ID LPAREN RPAREN
    {
        SymbolInfo *temp  = st.lookUp($2->getName()) ; 
        if(temp != NULL ) { 
            //function is declared
            if(temp->isDefined || temp->storedAs != "function") { 
                        error_cnt++;
						logStream<<"Error at Line "<<line<<": Multiple declaration of "<<$2->getName()<< "\n\n"; 
						errorStream<<"Error at Line "<<line<<": Multiple declaration of "<<$2->getName() << "\n\n" ;
                        ++anyError;
            }
            else if(temp->dataType != $1->getName())  {
                        error_cnt++;
                        ++anyError;
						logStream<<"Error at Line "<<line<<": Return type mismatch with declared functon "<<$2->getName()<< "\n\n"; 
						errorStream<<"Error at Line "<<line<<": Return type mismatch with declared function "<<$2->getName() << "\n\n" ;
                }
            
        }
        else { 
            // function is not declared
            if(!st.insert($2->getName() ,  "ID")){
            logStream << "Error at line " << line << ": Multiple declaration of " << $2->getName() << "\n\n";
			errorStream << "Error at line " << line << ": Multiple declaration of " << $2->getName() << "\n\n";
		    error_cnt++;
            ++anyError;
            }
            else { 
                SymbolInfo * temp  = st.lookUp($2->getName()) ; 
                temp->dataType = $1->getName() ; 
                temp->storedAs = "function"; 
                temp->parameters = parameters ; 
                temp->isDefined = true ;
            }
        }
        st.enterScope() ; 
        asmStream<<"\n\n\n" ;

         if(!codeStarted) { 
            writeAsm("\n\n\n.CODE\n\n\n") ; 
            codeStarted = true;
         }



        asmStream << $2->getName() <<"\tPROC" ;
         if($2->getName() == "main") { 
            writeAsm("MOV AX ,@DATA") ;
            writeAsm("MOV DS ,AX") ; 
            writeAsm("; DATA segment loaded") ;
        }
        else {
        asmStream <<"\n\t\tPUSH BP\n\t\tMOV BP, SP\n\t\t; STORING THE GPRS\n\t\t; DX for returning results\n\t\tPUSH AX\n\t\tPUSH BX\n\t\tPUSH CX\n\t\tPUSHF";
        
        }
        endFunc.push_back(++levelCount) ;


    }
    compound_statement {st.printAll(logStream) ; st.exitScope();} 
    {
         if($1->getName() == "void"  && returnStatement )  { 
            logStream <<"Error at Line " << returnLine << ": " << "Return statement with a value in function void\n\n" ;
            errorStream << "Error at Line " << returnLine << ": " << "Return statement with a value in function void\n\n" ;
            error_cnt++ ; 
            ++anyError;
        }
        
        if($1->getName() == "int" && returnType == "float") { 
            logStream << "Warning at Line " << returnLine <<": conversion from float to int\n\n" ;
            errorStream << "Warning at Line " << returnLine <<": conversion from float to int\n\n" ;
            ++anyError;
        }
        string temp = $1->getName()  +" " + $2->getName() + "(";
        for (int i = 0 ; i < parameters.size();  ++i ) {
            if(i) temp += "," ;
            temp = temp + parameters[i].first; 
            if(!parameters[i].second.empty()) 
                temp = temp +  " " + parameters[i].second ;
        }
        temp += ")\n" ;
       
        temp += $6->getName() ; 
        $$ = new SymbolInfo(temp , "_") ; 
        logStream << "Line " << line <<": func_definition : type_specifier ID LPAREN  RPAREN compound_statement\n\n" ;
        logStream << $$->getName() << "\n\n" ; 
        logStream.flush();

        returnType = "" ;
        returnStatement = false ; 
        returnLine = -1; 




        asmStream << endl;
        writeAsm("; Return point of function " + $2->getName());
        writeAsm("@L_" + parseInteger( endFunc.back() ) + ":") ; 
        endFunc.pop_back() ;




        if($2->getName() == "main") {
            writeAsm("MOV AH ,4CH") ; 
            writeAsm("int 21h") ; 
            writeAsm("; returned control to OS") ;  
        }
        else   {
        
            writeAsm("MOV SP , BP") ; 
            writeAsm("SUB SP, 8") ;
            writeAsm("POPF") ; 
            pop("CX") ; 
            pop("BX") ; 
            pop("AX") ;
            pop("BP") ; 
            writeAsm("RET " + parseInteger(2 * parameters.size())) ; 
        }
        writeAsm($2->getName() + " ENDP  ; line  no " + parseInteger( line ) + " : function " + $2->getName() + " ended") ; 
        asmStream <<endl; 
        asmStream << endl;
        parameters.clear() ;


        
    }

;




parameter_list : parameter_list COMMA type_specifier ID
    {
        
        if($3->getName() == "void") {
            logStream << "Error at line " << line << ": variable of type void for " << $1->getName() << "\n\n";
			errorStream<< "Error at line " << line << ": variable of type void for " << $1->getName() << "\n\n";
			error_cnt++;
            ++anyError;
        }

        else if (anyVoid) {
            anyVoid = false; 
            logStream << "Error at line " << line << ": Invalid use of type void" << "\n\n";
			errorStream << "Error at line " << line << ":Invalid use of type void" << "\n\n";
			error_cnt++;
            ++anyError;
        }

        else if(find(parameters.begin() , parameters.end() , make_pair($3->getName() , $4->getName())) != parameters.end()){
             logStream << "Error at line " << line << ": Multiple declaration of " << $4->getName() << "\n\n";
			 errorStream << "Error at line " << line << ": Multiple declaration of " << $4->getName() << "\n\n";
			 error_cnt++;
             ++anyError;
        }
        logStream <<  "Line " << line << ": parameter_list : parameter_list COMMA type_specifier ID\n\n" ;
        parameters.push_back(make_pair($3->getName() , $4->getName())) ;
        $$ = new SymbolInfo($1->getName() + "," + $3->getName() + " " +  $4->getName() , "_");
        logStream << $$->getName() << "\n\n" ;
        logStream.flush();
        
    }
| parameter_list COMMA type_specifier
    {
       
        if($1->getName() == "void") { 
            logStream << "Error at line " << line << ": Invalid use of type void" << "\n\n";
			errorStream << "Error at line " << line << ":Invalid use of type void" << "\n\n";
			error_cnt++;
            ++anyError;
        }    
        
        parameters.push_back(make_pair($3->getName() ,  "")) ; 
        $$ = new SymbolInfo($1->getName() + "," + $3->getName() , "_") ;
        logStream <<  "Line " << line << ": parameter_list : parameter_list COMMA type_specifier\n\n" ;
        logStream << $$->getName() << "\n\n" ;
        logStream.flush();
        
    }
| type_specifier ID
    {
       
        if($1->getName() == "void")  {
            logStream << "Error at line " << line << ": variable of type void for " << $1->getName() << "\n\n";
			errorStream<< "Error at line " << line << ": variable of type void for " << $1->getName() << "\n\n";
			error_cnt++;
            ++anyError;
        }
        else if (anyVoid) {
            anyVoid = false; 
            logStream << "Error at line " << line << ": Invalid use of type void" << "\n\n";
			errorStream << "Error at line " << line << ":Invalid use of type void" << "\n\n";
			error_cnt++;
            ++anyError;
        }
        else if(find(parameters.begin() , parameters.end() , make_pair($1->getName() , $2->getName())) != parameters.end()){
             logStream << "Error at line " << line << ": Multiple declaration of " << $2->getName() << "\n\n";
			 errorStream << "Error at line " << line << ": Multiple declaration of " << $2->getName() << "\n\n";
			 error_cnt++;
             ++anyError;
        }
        parameters.push_back(make_pair($1->getName() , $2->getName())) ;
        $$ = new SymbolInfo($1->getName() + " " + $2->getName() , "_") ; 
        logStream <<  "Line " << line << ": parameter_list : type_specifier ID\n\n" ;
        logStream << $$->getName() << "\n\n" ;
        logStream.flush();
    }
| type_specifier
    {
       
        if($1->getName() == "void") { 
            if(!parameters.empty()) { 
                logStream << "Error at line " << line << ": Invalid use of type void" << "\n\n";
			    errorStream << "Error at line " << line << ":Invalid use of type void" << "\n\n";
			    error_cnt++;
                ++anyError;
            }
            anyVoid = true;        
        }
        parameters.push_back(make_pair($1->getName()  , "")); 
        $$ = $1 ;
        logStream <<  "Line " << line << ": parameter_list : type_specifier\n\n" ;
        logStream << $$->getName() << "\n\n" ; logStream.flush();
    }
;









compound_statement : LCURL statements RCURL
    {
        $$ =  new SymbolInfo ("{\n"  + $2->getName() + "\n}" ,  "_") ;
        logStream << "Line " << line << ": compound_statement : LCURL statements RCURL\n\n" ; 
        logStream << $$->getName() << "\n\n" ;  logStream.flush();
    }
| LCURL RCURL
    {
        $$ = new SymbolInfo ("{}" , "_") ; 
        logStream << "Line " << line << ": compound_statement : LCURL RCURL \n\n" ;
        logStream << $$->getName() << "\n\n" ;   logStream.flush();
    }
;






var_declaration : type_specifier declaration_list SEMICOLON
    {
        if($1->getName() == "void")   {
            logStream << "Error at line " << line << ": Variable type cannot be void\n\n";
			errorStream << "Error at line " << line << ": Variable type cannot be void\n\n";
			error_cnt++;
            ++anyError;
        }
        logStream << "Line " << line  << ": var_declaration : type_specifier declaration_list SEMICOLON\n\n" ;
        logStream << $1->getName() << " " << $2->getName() << ";\n\n" ;   logStream.flush();
        $$ = new SymbolInfo ($1->getName() + " " + $2->getName() + ";\n" , "_") ;        
        
    }
;





type_specifier : INT
 {
    logStream << "Line " << line << ": type_specifier : INT\n\n" ;
    varType =  "int";
    $$ = new SymbolInfo("int" , varType);
    logStream << $$->getName() <<  "\n\n" ; logStream.flush();
 }
| FLOAT
    {
        logStream << "Line " << line << ": type_specifier : FLOAT\n\n" ;
         errorStream << "Error at line "  << line << " : float is not supported" << endl << endl;
        varType =  "float";
        $$ = new SymbolInfo("float" , varType);
        logStream << $$->getName() << "\n\n"  ; logStream.flush();
        ++anyError;
    }
| VOID
    {
        logStream << "Line " << line << ": type_specifier : VOID\n\n" ;
        varType =  "void";
        $$ = new SymbolInfo("void" , varType);
        logStream << $$->getName()  << "\n\n" ;
        logStream.flush();
    }
;




declaration_list : declaration_list COMMA ID
    {  
        if(varType == "void") {
            logStream << "Error at line " << line<< ": variable of type void for " << $3->getName() << "\n\n";
			errorStream<< "Error at line " << line << ": variable of type void for " << $3->getName() << "\n\n";
			error_cnt++;
            ++anyError;
        }
        else if(!st.insert($3->getName() , "ID"))  { 
                logStream << "Error at line " << line << ": Multiple declaration of " << $3->getName() << "\n\n";
			    errorStream << "Error at line " << line << ": Multiple declaration of " << $3->getName() << "\n\n";
			    error_cnt++;
                ++anyError;
               
        }
            
        $$ = new SymbolInfo($1->getName() + "," + $3->getName() , "_") ;
        logStream << "Line " << line <<  ": declaration_list : declaration_list COMMA ID\n\n";
		logStream << $1->getName() + "," + $3->getName() << "\n\n";
        SymbolInfo * temp = st.lookUp($3->getName()) ; 
        temp->dataType = varType ;
        temp->storedAs = "variable"; 
        logStream.flush();
        if(!anyError) {
            if(st.getCurrentScopeId() == "1") {
                asmStream  << $3->getName() << "\tDW\t0;line no " << line << ": " << $3->getName() << " Declared" << endl;
                temp->isGlobal = true ;
            }
            else {
                temp->stackCount = st.getCurrentStackCount() ;  
                temp->isGlobal = false ;
                st.increaseStackCount(1) ;
                asmStream << "\n\t\t PUSH BX ; line no " << line  <<" : " << $3->getName() << " declared\n\t\t" << endl;
            }
        }
    }
| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
    {
         //logStream << "Line " << line <<  ": declaration_list : declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n";
         if (varType == "void") { 
            logStream << "Error at line " << line << ": variable of type void for " << $3->getName() << "\n\n";
			errorStream<< "Error at line " << line << ": variable of type void for " << $3->getName() << "\n\n";
			error_cnt++;
            ++anyError;
            
        }
        else {
            if(!st.insert($3->getName() , "ID")) {
                logStream << "Error at line " << line<< ": Multiple declaration of " << $3->getName() << "\n\n";
			    errorStream << "Error at line " << line << ": Multiple declaration of " << $3->getName() << "\n\n";
			    error_cnt++;
                ++anyError;
               
            }
        }
           
        $$ = new SymbolInfo($1->getName() + "," + $3->getName() + "[" + $5->getName() + "]",  ""); 
        $$->dataType = varType; 
        $$->storedAs = "Array" ;
        logStream << "Line " << line <<  ": declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n";
 		logStream << $1->getName() << "," << $3->getName() << "[" << $5->getName() << "]" << "\n\n";
 		SymbolInfo * temp = st.lookUp($3->getName()) ; 
        temp->dataType = varType ;
        temp->storedAs = "array";
             logStream.flush();
        temp->arraySize = atoi($5->getName().c_str()) ;
        st.incrementArrayNum() ;
        if(!anyError) {
            if(st.getCurrentScopeId() == "1") {
                asmStream << $3->getName() << "\tDW\t"<< $5->getName() << "\tDUP(0); line no " << line << ": " << $3->getName() << " declared" << endl;
                temp->isGlobal = true;
            }
            else  {
                temp->stackCount = st.getCurrentStackCount() ; 
                temp->isGlobal = false ;
                st.increaseStackCount(atoi(($5->getName()).c_str()) ) ; 
               // stackCount += atoi(($5->getName()).c_str()) ; 
                int arrayNum = st.getCurrentArrayNum() ;
                arrayNum *= 2 ;
                int arraySize =  atoi($5->getName().c_str()) ;
                
                
                asmStream << "\n\t\tMOV CX, "<< arraySize <<"; line no "<<line<<" : ; new array of size 10" ; 
                newLevel() ;
                writeAsm("JCXZ @L_" + parseInteger(levelCount + 1) ) ;
                push("BX") ;
                asmStream << gap << "DEC CX" ;
                asmStream << gap << "JMP @L_" << parseInteger(levelCount) ;
                newLevel() ; 
                asmStream << endl;
                /* 
                \n\t\t@L_"<< arrayNum <<":\n\t\tJCXZ @L_"<<arrayNum + 1 <<"\n\t\tPUSH BX\n\t\tDEC CX\n\t\tJMP @L_"<<arrayNum<<"\
                 \n\t\t@L_"<<arrayNum + 1<<": \n\t\t" ;
                 */
            }
        }
    }
| ID
    {
        if(varType == "void") {
            // logStream << "Error at line " << line << ": variable of type void for " << $1->getName() << "\n\n";
			// errorStream<< "Error at line " << line << ": variable of type void for " << $1->getName() << "\n\n";
			// error_cnt++;
             //++anyError;

        }
        else if(!st.insert($1->getName() , "ID"))  { 
                logStream << "Error at line " << line<< ": Multiple declaration of " << $1->getName() << "\n\n";
			    errorStream << "Error at line " << line << ": Multiple declaration of " << $1->getName() << "\n\n";
			    error_cnt++;
                ++anyError;
               
        }
        else {
            SymbolInfo * temp = st.lookUp($1->getName()) ;
            temp->dataType = varType ;
            temp->storedAs = "variable";
        }
        SymbolInfo * temp = st.lookUp($1->getName()) ; 
        temp->dataType = varType ;
        temp->storedAs = "variable";      
        $$ = new SymbolInfo($1->getName() , "_") ;
        logStream << "Line " << line <<  ": declaration_list : ID\n\n";
		logStream << $1->getName() << "\n\n";
        logStream.flush();
        if(!anyError) {
            if(st.getCurrentScopeId() == "1") {
                asmStream  << $1->getName() << "\tDW\t0;line no " << line << ": " << $1->getName() << " Declared" << endl;
                temp->isGlobal = true; 
            }
            else {
                temp->stackCount = st.getCurrentStackCount(); 
                temp->isGlobal = false ;
                //++stackCount;
                st.increaseStackCount(1) ;
                asmStream << "\n\t\t PUSH BX ; line no " << line  <<" : " << $1->getName() << " declared\n\t\t" << endl;
            }        
        }    
    }
| ID LTHIRD CONST_INT RTHIRD
    {
        
        if (varType == "void") { 
            logStream << "Error at line " << line << ": variable of type void for " << $1->getName() << "\n\n";
			errorStream<< "Error at line " << line << ": variable of type void for " << $1->getName() << "\n\n";
			error_cnt++;
            ++anyError;

        }
        else if(!st.insert($1->getName() , "ID")) {
                logStream << "Error at line " << line<< ": Multiple declaration of " << $1->getName() << "\n\n";
			    errorStream << "Error at line " << line << ": Multiple declaration of " << $1->getName() << "\n\n";
			    error_cnt++;
                ++anyError;

        }
         
        $$ = new SymbolInfo($1->getName() + "[" + $3->getName() + "]",  ""); 
        $$->dataType = varType; 
        $$->storedAs = "Array" ;
        logStream << "Line " << line <<  ": declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n";
 		logStream << $1->getName() << "[" << $3->getName() << "]" << "\n\n";
 		SymbolInfo * temp = st.lookUp($1->getName()) ; 
        temp->dataType = varType ;
        temp->storedAs = "array";
        logStream.flush();
        st.incrementArrayNum() ;
        if(!anyError) {
            if(st.getCurrentScopeId() == "1") {
                asmStream << $1->getName() << "\tDW\t"<< $3->getName() << "\tDUP(0); line no " << line << ": " << $3->getName() << " declared" << endl;
                temp->isGlobal = true;
            }
            else  {
                temp->stackCount = st.getCurrentStackCount() ;
                temp->isGlobal = false ;
                st.increaseStackCount(atoi(($3->getName()).c_str()));
               // stackCount += atoi(($3->getName()).c_str()) ; 
                int arrayNum = st.getCurrentArrayNum() ;
                arrayNum *= 2 ;
                int arraySize =  atoi($3->getName().c_str()) ;





                asmStream << "\n\t\tMOV CX, "<< arraySize <<"; line no "<<line<<" : ; new array of size 10" ; 
                newLevel() ;
                writeAsm("JCXZ @L_" + parseInteger(levelCount + 1) ) ;
                push("BX") ;
                asmStream << gap << "DEC CX" ;
                asmStream << gap << "JMP @L_" << parseInteger(levelCount) ;
                newLevel() ; 
                asmStream << endl;


               /* asmStream << "\n\t\tMOV CX, "<< arraySize <<"; line no "<<line<<" : ; new array of size 10\
                \n\t\t@L_"<< arrayNum <<":\n\t\tJCXZ @L_"<<arrayNum + 1 <<"\n\t\tPUSH BX\n\t\tDEC CX\n\t\tJMP @L_"<<arrayNum<<"\
                \n\t\t@L_"<<arrayNum + 1<<": \n\t\t" ;
                */
            }
        }

    }
;





statements : statement
    {
        $$ = $1  ; 
        logStream << "Line " << line  << ": statements : statement\n\n" ;
        logStream << $$->getName() << "\n\n" ;  logStream.flush();
    }
| statements statement
    {
        $$ =  new SymbolInfo($1->getName() + $2->getName() , "_") ; 
        logStream << "Line " << line  << ": statements : statements statement\n\n" ; 
        logStream << $$->getName() << "\n\n" ; logStream.flush();
    }
;









statement : var_declaration 
	{
			$$=$1;
			logStream<<"Line "<<line<<": statement : var_declaration\n\n";
			logStream<<$1->getName()<< "\n\n" ; logStream.flush();
	}
| expression_statement 
	{
			$$=$1;
			logStream<<"Line "<<line<<": statement : expression_statement\n\n";
            logStream<<$$->getName() << "\n\n" ; logStream.flush();
	}
| {st.enterScope();} compound_statement {st.printAll(logStream); st.exitScope();} 
	{
		    $$ = $2; 
			logStream<<"Line "<<line<<": statement : compound_statement\n\n";
			logStream<<$$->getName() << "\n\n" ; logStream.flush();
	}
| FOR LPAREN expression_statement  
        {
            newLevel() ; 
            asmStream << " ; line no " << line << " :  loop Start" ; 
            asmStream << endl;
            jumpEnd.push_back(levelCount + 1) ; 
            levelCount++ ;
            asmStream << endl;
        }
        expression_statement 
        {
            writeAsm(";loop conditioin checking\n") ;
            writeAsm("CMP AX, 0") ; 
            writeAsm("JE @L_" + parseInteger(jumpEnd.back())) ; 
            asmStream << " ; line no " << line << " ; the loop is ended" << endl;
           
           
           
           
            forStatementLevel.push_back(++levelCount) ; 
           
            writeAsm("JMP @L_" + parseInteger(forStatementLevel.back())) ; // jumping direct to the statement ;
            writeAsm("\n\n\n")  ; 

            writeAsm(" ;Updateing index value ") ;
            newLevel() ; 
            forUpdateLevel.push_back(levelCount) ;


        }
        expression 
        {
            pop("AX") ;
            asmStream << "\n" << endl;
            writeAsm("JMP @L_" + parseInteger(jumpEnd.back() - 1) + " ; goto incrementPOint point") ;
            writeAsm("@L_" + parseInteger(forStatementLevel.back()) + ":") ; 
            forStatementLevel.pop_back() ; 
            
        }
        RPAREN statement 
	    {
			$$ = new SymbolInfo("for( "+$3->getName()+$5->getName()+$7->getName()+")"+$10->getName() , "_");
			//logStream<<"Line "<<line <<": statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n";
			//logStream<<$$->getName() << "\n\n" ; logStream.flush();
             writeAsm("JMP @L_" + parseInteger(forUpdateLevel.back()) + " ; goto incrementPOint point") ;
             forUpdateLevel.pop_back() ;
             writeAsm("@L_" + parseInteger(jumpEnd.back()) + ": ; exit loop") ;
             jumpEnd.pop_back() ;  



	    }
| DUMMY_IF %prec LOWER_THAN_ELSE
	{
		//	$$= new SymbolInfo("if( "+$4->getName()+ ")\n"+$7->getName() , "_");
		//	logStream <<"Line "<<line<<": statement : IF LPAREN expression RPAREN statement\n\n" ; 
		//	logStream<<$$->getName() << "\n\n" ;  logStream.flush();
            asmStream << endl ;
            writeAsm("@L_" + parseInteger(endIf.back()) + ": ; end if") ; 
            asmStream << endl;
            endIf.pop_back() ;
            endIf.pop_back() ; 
	}
| DUMMY_IF ELSE  
    {
        int last = endIf.back() ; 
        endIf.pop_back() ; 
        int secondLast = endIf.back() ; 
        endIf.pop_back() ;
        writeAsm("JMP @L_"   + parseInteger(secondLast) + " ; go to the exit level of if else statement") ; 
        writeAsm("@L_" + parseInteger(last) + ": ; begining of else level") ;
        endIf.push_back(secondLast) ;
        asmStream << endl;
    }
    statement 
	{
		//$$= new SymbolInfo("if( "+$3->getName()+")\n"+$5->getName()+"\nelse\n"+$7->getName() , "_");			
		//logStream<<"Line "<<line<<": statement : IF LPAREN expression RPAREN statement ELSE statement\n\n";
		//logStream<<$$->getName()<< "\n\n"; logStream.flush();
         writeAsm("@L_" + parseInteger(endIf.back()) +  ": ; end of if else statement") ; 
         asmStream << endl; 
         endIf.pop_back() ;  

	}
| WHILE 
     {
        newLevel() ; 
        asmStream << " ; line no " << line << " :  while loop Start" ; 
        asmStream << endl;
        endWhile.push_back(levelCount + 1) ; 
        levelCount++ ;
        asmStream << endl;
     }  
    LPAREN expression RPAREN
    {
        pop("AX") ;
        writeAsm(";loop conditioin checking\n") ;
        writeAsm("CMP AX, 0") ; 
        writeAsm("JE @L_" + parseInteger(endWhile.back())) ; 
        asmStream << " ; line no " << line << " ; the loop is ended" << endl;
    }
    statement 
	{


        $$= new SymbolInfo("while("+$4->getName()+")\n"+$7->getName() , "_");
		logStream<<"Line "<<line<<": statement : WHILE LPAREN expression RPAREN statement\n\n";
		logStream<<$$->getName()<<"\n\n"; logStream.flush();



        writeAsm("JMP @L_" + parseInteger(endWhile.back() - 1) + " ; ") ;
        writeAsm("@L_" + parseInteger(endWhile.back()) + ": ; exit while loop") ;
        endWhile.pop_back() ;  

	}
| PRINTLN LPAREN ID RPAREN SEMICOLON 
	{
		    $$= new SymbolInfo("printf("+$3->getName()+ ");" , "_");
			logStream<<"Line "<<line<<": statement : PRINTLN LPAREN ID RPAREN SEMICOLON";
			SymbolInfo * temp = st.lookUp($3->getName()) ; 
			if(temp == NULL) {
				logStream<<"Error at line "<<line<<": Undeclared variable "<<$3->getName()<<  "\n\n";
				errorStream<<"Error at line "<<line<<": Undeclared variable "<<$3->getName()<<endl<< "\n\n" ;
                error_cnt++ ;  
                ++anyError;

			}
			else if(temp->storedAs !="variable"){
				logStream<<"Error at Line "<<line<<": "<<$3->getName()<<" cannot be printed"<< "\n\n";
				errorStream<<"Error at Line "<<line <<": "<<$3->getName() << " cannot be printed"<< "\n\n";
                ++anyError;

			}
			logStream << $$->getName() << "\n\n" ; logStream.flush();




            writeAsm("; line no " + parseInteger(line)  + " : calling print function") ;


            if(temp->isGlobal) { 
                asmStream <<"\n\t\tMOV BX, " << $3->getName() ;
                asmStream << "\n\t\tPUSH BX"<<endl; ; 
            }
            else if(temp->isArgument) {
                int pos = 4 + 2 * (temp->argumentPos) ;
                asmStream << "\n\t\tMOV BX, [BP + " << pos << "]" ; 
                asmStream << "\n\t\tPUSH BX"<< endl;
            }
            else { 
                int pos = 10 + 2 * (temp->stackCount) ;
                asmStream <<"\n\t\tMOV BX, [BP - "<< pos << "]" ;
                asmStream <<"\n\t\tPUSH BX" << endl; 
             }



            
            pop("BX");
            push("BX") ; 
            writeAsm("CALL PRINT_DECIMAL_INTEGER") ;
            asmStream << endl ;

	}
| RETURN expression SEMICOLON 
	{
		    $$= new SymbolInfo("return " +$2->getName()+";", "_");	
			logStream<<"Line "<<line<<": statement : RETURN expression SEMICOLON\n\n";
			logStream << $$->getName() <<  "\n\n" ;  logStream.flush();
            returnStatement = true ;
            returnType = $2->dataType ;
            returnLine = line ;
            writeAsm("; line no " + parseInteger(line ) + " : return statement ") ; 
            pop("DX") ;  
            writeAsm("; return value is stored in DX") ;
            writeAsm("JMP @L_" + parseInteger(endFunc.back())) ;
            asmStream << endl;
	}
;




DUMMY_IF : IF LPAREN 
    {
        asmStream << "; line no " << line << " : " << " if Statement" ; 
        ++levelCount ; 
        endIf.push_back(levelCount)  ;

        ++levelCount ; 
        endIf.push_back(levelCount ) ;


        asmStream << endl ;

    }    
    expression
    {    
        writeAsm(";checking condition") ; 
        pop("BX") ; 
        writeAsm("CMP BX, 0")  ; 
        writeAsm("JE @L_" + parseInteger(endIf.back())) ; 
        asmStream << " ; the  conditioin is not satisfied" ;
    } 
    RPAREN statement
    
;



expression_statement : SEMICOLON
    {
		logStream << "Line " << line <<  " expression_statement : SEMICOLON\n\n";
		logStream << ";\n\n"; logStream.flush();
		$$ = new SymbolInfo(";\n" , "_") ; 
	}	
| expression SEMICOLON 
	{   
    
				$$ = new SymbolInfo($1->getName() + ";\n" , "_") ;
				logStream << "Line " << line <<  " expression_statement : expression SEMICOLON \n\n";
				logStream << $$->getName() << "\n\n";  logStream.flush();

                pop("AX") ; 
                asmStream << "; Previously pushed value removed " << endl;
            
	}
;






variable : ID
    {
        $$ = $1  ; 
        bool anyError = false; 
        logStream <<  "Line " << line <<  " variable : ID\n\n";
        SymbolInfo * temp = st.lookUp($1->getName()) ;  
        if(temp == NULL) { 
            logStream << "Error at line " << line << ": Undeclared variable " << $1->getName() << "\n\n";
			errorStream << "Error at line " << line << ": Undeclared variable " << $1->getName() << "\n\n";
			error_cnt++;
            ++anyError;
            
        }
        else if(temp->storedAs == "array") {
            logStream << "Error at line " << line << ": Type mismatch, " << $1->getName() << " is an array\n\n";
			errorStream << "Error at line " << line << ": Type mismatch, " << $1->getName() << " is a array\n\n";
			error_cnt++;
            ++anyError;
            
        }
        else if(temp->storedAs == "function") {
            logStream << "Error at line " << line << ": Type mismatch, " << $1->getName() << " is an fujction\n\n";
			errorStream << "Error at line " << line << ": Type mismatch, " << $1->getName() << " is a function\n\n";
			error_cnt++;
            ++anyError;
            
        }
        if(temp != NULL) {
            $$->dataType = temp->dataType; 
            $$->storedAs = temp->storedAs ;

        }
        if(temp->isGlobal) { 
            asmStream <<"\n\t\tMOV BX ," << $1->getName() ;
            asmStream << "\n\t\tPUSH BX"<<endl; ; 
        }
        else if(temp->isArgument) {
            int pos = 4 + 2 * (temp->argumentPos) ;
            asmStream << "\n\t\tMOV BX, [BP + " << pos << "]" ; 
            asmStream << "\n\t\tPUSH BX"<< endl;
        }
        else { 
            int pos = 10 + 2 * (temp->stackCount) ;
            asmStream <<"\n\t\tMOV BX, [BP - "<< pos << "]" ;
            asmStream <<"\n\t\tPUSH BX" << endl; 
        }
        logStream << $$->getName() << "\n\n" ;  logStream.flush();
    }
| ID LTHIRD expression RTHIRD
    {
        $$ = new SymbolInfo ($1->getName() + "[" + $3->getName() + "]" , "arrayValue");
        logStream << "Line " << line <<   " variable : ID LTHIRD expression RTHIRD\n\n" ;
        SymbolInfo * temp = st.lookUp($1->getName()) ; 
        if(temp == NULL) { 
            logStream << "Error at line " << line << ": Undeclared variable " << $1->getName() << "\n\n";
			errorStream << "Error at line " << line << ": Undeclared variable " << $1->getName() << "\n\n";
			error_cnt++;
            ++anyError;

        }
        else if (temp->storedAs != "array") { 
            logStream << "Error at line " << line  << ": "<< $1->getName() << " is not an array " << "\n\n" ; 
            errorStream << "Error at line " << line  << ": "<< $1->getName() << " is not an array " << "\n\n" ; 
            error_cnt++; 
            ++anyError;

        }
        else if($3->getType() != "CONST_INT"){
            logStream << "Error at line " << line  <<": Index must be const int \n\n" ; 
            errorStream << "Error at line " << line  <<": Index must be const int \n\n" ; 
            error_cnt++;
            ++anyError;

        }
        $$->index = $3->getName();
        if(temp != NULL)  
            $$->dataType = temp->dataType ;
        
        asmStream << "\n\t\tPOP BX" << "; line no " << line  <<": Array index in BX; " << temp->getName() ; 

        asmStream << "\n\t\tSHL BX,1 ;" ; 
        if(temp->isGlobal) {
            asmStream <<"\n\t\tPUSH " << temp->getName() << "[BX]" ;
            push("BX") ;
            asmStream << endl;
        }
        else  { 
            int pos = 10 + 2  * (temp->stackCount) ;
            asmStream << "\n\t\tADD BX, " << pos ;
            asmStream <<"\n\t\tNEG BX";
            asmStream <<"\n\t\tADD BX, BP";
            asmStream <<"\n\t\tPUSH [BX]" ;
            asmStream << "\n\t\tPUSH BX ; address pushed to stack"  << endl;
        }
        
        logStream << $1->getName() << "[" << $1->getName() << "]\n\n" ;  logStream.flush();
    }
;








expression : logic_expression
    {
        $$ = $1; 
        logStream << "Line " << line <<  " expression : logic_expression\n\n";
		logStream << $1->getName() << "\n\n" ;  logStream.flush();
    }
| variable ASSIGNOP logic_expression
    {
        
        $$ = new SymbolInfo($1->getName() + "=" + $3->getName(),  "_") ;
        
        if($3->dataType == "void") {
                    logStream << "Error at line " << line << ": Void function used in expression\n\n";
					errorStream << "Error at line " << line << ": Void function used in expression\n\n";
					error_cnt++;
                    ++anyError;

        }

        if($3->storedAs == "array") {
                    logStream << "Error at line " << line << " type mismatch\n\n";
                    errorStream << "Error at line " << line << " type mismatch\n\n" ;
                    error_cnt ++ ;
                    ++anyError;

        }
        $$->dataType = $1->dataType;
        if($3->dataType == "float" && $1->dataType == "int") {
                    logStream << "Warning at line " << line << ": convertion from float to int\n\n";	
                    errorStream << "Warning at line " << line << ": convertion from float to int\n\n";	
                    $$->dataType = "int" ;	
                    
                    		
        }
        logStream << "Line " << line <<  " expression : variable ASSIGNOP logic_expression\n\n";
        logStream << $$->getName()  << "\n\n" ; logStream.flush();
        
        
        
        
        
        if($3->getType() == "arrayValue") { 
             pop("AX") ;
        }
        asmStream << "\n\t\tPOP AX"  ; 
        SymbolInfo * temp = st.lookUp(getVaiableName($1->getName())) ; 
        if(temp->storedAs != "array") {
            if(temp->isGlobal) { 
                asmStream << "\n\t\tMOV " << $1->getName() << ", AX ; line " << line <<  ": " <<  $1->getName() <<" assigned"  << endl; 
            }
            else if(temp->isArgument) {
                int pos = 4 + 2 * (temp->argumentPos) ;
                asmStream << "\n\t\tMOV  [BP + " << pos << "], AX ; line " << line <<  ": " <<  $1->getName() <<" assigned"  << endl; 
            }
            else { 
                int pos = 10 + 2 * (temp->stackCount) ;
                asmStream <<"\n\t\tMOV [BP - " << pos << "], AX ; line " << line <<  ": " <<  $1->getName() <<" assigned"  << endl; 
            }
        }
        else { 
            
		    asmStream << "\n\t\tPOP BX ; address"  ; 
		    asmStream << "\n\t\tPOP DX; line no  " << line << " :  ;array value popped " ;
            if(temp->isGlobal) {
                asmStream << gap << "MOV " << getVaiableName($1->getName()) << " [BX] , AX ; line no " << line << " : " << $1->getType() << " assigned " << endl; 
            }
		    asmStream << "\n\t\tMOV [BX], AX; line no  " << line << " : " << $1->getName() << " assined "  << endl;
            
        }
        push("AX") ;


    }
;






logic_expression : rel_expression
    {
        logStream << "Line " << line <<  " logic_expression : rel_expression\n\n";
		logStream << $1->getName() << "\n\n" ;  logStream.flush();
        $$ = $1;  
    }
| rel_expression LOGICOP rel_expression
    {
        $$ = new SymbolInfo($1->getName() + $2->getName()  + $3->getName() , "_") ; 
        logStream << "Line " << line << " logic_expression :rel_expression LOGICOP rel_expression\n\n" ;
        logStream << $1->getName() << " " << $2->getName() << " " << $3->getName() <<"\n\n" ; 
        $$->dataType = "int" ; logStream.flush();


        pop("BX") ; 
        int toComp = 0  ; 
        if($2->getName() == "||") toComp = 1; 
        writeAsm("CMP BX ," + parseInteger(toComp)) ;
        writeAsm("JE @L_" + parseInteger(levelCount  + 1)) ; 
        asmStream << " ; line no " << line  << " : " ;
        toComp == 0 ? asmStream << "not true " : asmStream << " true "  ; 


        pop("BX"); 
        writeAsm("CMP BX , 0 "); 
        writeAsm("JE @L_" + parseInteger(levelCount + 1)) ; 
        asmStream << " ; line no " << line  << " : " ;
        
        if(toComp == 0) { 
            asmStream  << "; ;not true" ; 
            push("1") ; 
            asmStream << " ;line no " << line << " conditioin is true" ; 
        }        
        else {
            asmStream << " ;true" ; 
            push("0") ; 
            asmStream << " ; line no " << line << " : conditioin is false" ;
        }
        writeAsm("JMP @L_" + parseInteger(levelCount  + 2)) ; 
        newLevel() ; 
        push(parseInteger(toComp)) ;
        newLevel() ; 
        asmStream << " ; line no " << line << " ; exiting " << (toComp == 0 ? "and" : "or") << " operation  " ;
        asmStream << endl;



        



    }
;




rel_expression : simple_expression
    {
        logStream << "Line " << line <<  " rel_expression : simple_expression\n\n";
		logStream << $1->getName() << "\n\n" ;  logStream.flush();
        $$ = $1; 
    }
| simple_expression RELOP simple_expression
    {   
        if($1->dataType == "void" || $3->dataType == "void") {
            logStream << "Error at line " << line << ": Invalid operand of type void\n\n" ;
           errorStream << "Error at line " << line << ": Invalid operand of type void\n\n" ;
           error_cnt++ ;
            ++anyError;

        }
        $$ = new SymbolInfo($1->getName() +  $2->getName()  + $3->getName(), " ") ;
        logStream << " ; Line " << line << " simple_expression RELOP simple_expression\n\n" ;
        logStream << $1->getName() << " " << $2->getName() << " " << $3->getName() <<"\n\n" ;  logStream.flush();
        $$->dataType = "int" ;



        pop("BX") ; 
        pop("AX") ;
        writeAsm("CMP AX, BX") ; 
        asmStream  << " ; line no " << line << " : relop operation " ; 
        writeAsm("MOV BX, 1"); 
        asmStream << " ; line no " << line  << " : first let it assume positive"  ; 
        string relop =  $2->getName() ; 
        string toPut; 
        if(relop == "<") toPut = "JL" ;
        else if(relop == "<=") toPut = "JLE" ;
        else if(relop == ">") toPut = "JG" ; 
        else if (relop == ">=") toPut = "JGE" ; 
        else if(relop == "==") toPut = "JE" ;
        else toPut = "JNE" ; 

        
        writeAsm( toPut + " @L_" + parseInteger(levelCount + 1)) ;  
    
        writeAsm("MOV BX, 0") ; 
        asmStream << " ;  line no " << line << " : the condition is false " ; 
        newLevel() ; 
        push("BX") ; 

        asmStream << endl;
       
    }
;






simple_expression : term
    {
        logStream << "Line " << line <<  " simple_expression : term\n\n";
		logStream << $1->getName() << "\n\n" ;  logStream.flush();
        $$ = $1; 
    }
| simple_expression ADDOP term
    {
        logStream << "Line " << line << " simple_expression :  simple_expression ADDOP term\n\n";
        $$ = new SymbolInfo($1->getName() + $2->getName() + $3->getName() , "simple_expression") ; 
        $$ ->dataType  = "int" ; 
        if($1->dataType == "float" || $3->dataType == "float") 
        $$->dataType = "float" ;
        logStream << $$->getName() << "\n\n" ; logStream.flush();

        

        pop("AX") ; 
        pop("BX") ;
        if($2->getName() == "+") {
            writeAsm("ADD BX , AX")  ;
        } 
        else { 
            writeAsm("SUB BX, AX") ; 
        }
        asmStream << "; line " << line << ": ADDOP done"  ; 
        push("BX") ;
        asmStream << endl;
        

    }
;



term : unary_expression
    {
        logStream << "Line " << line <<  " term : unary_expression\n\n";
        $$ =  $1 ;
        logStream << $$->getName() << "\n\n"; logStream.flush();
        $$ = $1 ;

    }
| term MULOP unary_expression
    {
        if($3->dataType == "void") { 
            logStream << "Error at line " << line <<": Invalid use of type void in expression\n\n"; 
            errorStream << "Error at line " << line <<": Invalid use of type void in expression\n\n"; 
            error_cnt++;
            ++anyError;

        }

        else if($2->getName() ==  "%") {
            if($3->getName() == "0" ) { 
                logStream<<"Error at line "<<line<<": Modulus by Zero"<<endl<<endl;
				errorStream<<"Error at line "<<line<<": Modulus by Zero"<<endl<<endl;
			    error_cnt++ ;
               ++anyError;


            }
            else if($1->dataType == "float" || $3->dataType == "float") { 
                logStream<<"Error at line "<<line<<": Non-Integer operand on modulus operator"<<endl<<endl;
				errorStream<<"Error at line "<<line<<": Non-Integer operand on modulus operator"<<endl<<endl;
			    error_cnt++; 
               ++anyError;


            }
        }
        $$ = new SymbolInfo($1->getName()  + $2->getName() +  $3->getName() , "term") ; 
        logStream << "Line " << line <<  " term :  term MULOP unary_expression\n\n";
        logStream << $$->getName() << "\n" ;
        $$->dataType = "int" ;
        if(($1->dataType ==  "float"  || $3->dataType == "float" ) && $2->getName() != "%")
        $$->dataType = "float" ;
        logStream.flush();


        if($2->getName() == "*") { 
            pop("BX") ; 
            asmStream <<" ;line no  " << line <<  " : multiplication start of integer" ;
            writeAsm("MOV CX , BX") ; 
            pop("AX") ; 
            writeAsm("IMUL CX") ; 
            writeAsm("MOV BX, AX") ; 
            asmStream <<" ; only last 16 bit is taken" ; 
            push("BX") ; 
            asmStream << endl;

        }
        else{ 
            pop("BX") ; 
            writeAsm("MOV CX, BX") ;
            asmStream << "; line no " << line << " / or % operation " ; 
            writeAsm("XOR DX , DX") ; 
            pop("AX") ;
            writeAsm("IDIV CX")  ;
            if($2->getName() == "/") 
                writeAsm("MOV BX ,AX") ; 
            else  { 
                writeAsm("MOV BX, DX") ; 
            }
            push("BX") ;
        }
        


    }
;




unary_expression : ADDOP unary_expression
    {
        if($2->dataType == "void") { 
            logStream << "Error at line " << line << ": Wrong type argument to unary_expression\n\n" ;
            errorStream << "Error at line " << line << ": Wrong type argument to unary_expression\n\n" ;
            error_cnt++ ;
            ++anyError;

        }
        $$ = new SymbolInfo("+" + $2->getName() ,   "_") ; 
        logStream << "Line " << line <<  ": unary_expression : factor \n\n";
  	    logStream << $$->getName() << "\n\n" ;
        $$->dataType = $2->dataType; logStream.flush();

        if($1->getName() == "-") { 
            pop("BX") ; 
            writeAsm("NEG BX") ;   
            push("BX")  ;
            asmStream << endl;
        }
  
    }
| NOT unary_expression
    {
        if($2->dataType == "void") { 
            logStream << "Error at line " << line <<": Wrong type argument to unary_expression\n\n" ;
            errorStream << "Error at line " << line <<": Wrong type argument to unary_expression\n\n" ;
            error_cnt++ ;
            ++anyError;

        }
        $$ = new SymbolInfo("!" + $2->getName() ,   "_") ; 
        logStream << "Line " << line <<  ": unary_expression : factor \n\n";
  	    logStream << $$->getName() << "\n\n" ;
        $$->dataType  = $2->dataType;  logStream.flush();

        pop("BX") ; 
        asmStream << " ; line no " << line << " : not operation" ; 
        writeAsm("CMP BX , 0") ; 
        writeAsm("MOV BX , 0") ; 
        writeAsm("jne @L_" + parseInteger(levelCount + 1)) ;
        writeAsm("INC BX") ; 
        newLevel() ;
        push("BX") ;
        asmStream << endl; 
    }
| factor
    {
        logStream << "Line " << line <<  ": unary_expression : factor \n\n";
  	    $$ =  $1 ; 
        $$->dataType = $1->dataType;
        logStream << $$->getName() << "\n\n" ; logStream.flush();
    }	 	
;




factor : variable 
    {
        logStream << "Line " << line  << ": factor : variable\n\n" ;
        $$ = $1 ;
        logStream << $$->getName()  << "\n\n" ; logStream.flush();
    }
| ID LPAREN argument_list RPAREN
    {
        
        SymbolInfo * temp = st.lookUp($1->getName())  ; 
        if(temp == NULL) { 
            logStream << "Error at line " << line<< ": Undeclared function " << $1->getName() << "\n\n";
			errorStream<< "Error at line " << line << ": Undeclared function " << $1->getName() << "\n\n";
			error_cnt++;
            ++anyError;

        }
        else if(temp->storedAs != "function") { 
            logStream << "Error at line " << line << ": " << $1->getName() << " is not a function\n\n";
			errorStream << "Error at line " << line << ": " << $1->getName() << " is not a function\n\n";
			error_cnt++;
            ++anyError;
        }
        else {
            bool mathced = false; 
            if(temp->parameters.size() == $3->parameters.size()) {
                mathced  = true ;
                for (int i = 0 ; i < temp->parameters.size() ; ++i ) { 
                    if(temp->parameters[i].first != $3->parameters[i].first )  {
                        mathced = false;
                    }
                        
                }
                if(mathced == false ) {
                logStream << "Warning at line " << line << ": arguments mismatch in function " << $1->getName() << "\n\n";
				//errorStream << "Error at line " << line<< ": arguments mismatch in function " << $1->getName() << "\n\n";
				//error_cnt++;
                // ++anyError;
                }
            }
            else if($3->parameters.size() > temp->parameters.size()) {
                logStream << "Error at line " << line << ": too many arguments\n\n";
				errorStream << "Error at line " << line<< ": too many arguments\n\n";
				error_cnt++;
                 ++anyError;
            }
            else  if ($3->parameters.size() < temp->parameters.size()) { 
                logStream << "Error at line " << line << ": too few arguments \n\n";
				errorStream << "Error at line " << line<< ": too few arguments \n\n";
				error_cnt++;
                 ++anyError;
            }
            
        }
        logStream << "Line " << line<<  " factor  : ID LPAREN argument_list RPAREN\n\n";
        $$ = new SymbolInfo($1->getName() + "(" + $3->getName() + ")"  , "_") ; 
        if(temp != NULL) {
            $$->dataType = temp->dataType; 
            $$->storedAs = temp->storedAs; 
        }
        logStream << $$->getName() << "\n\n";
        logStream.flush();

        
        writeAsm("; line no " + parseInteger(line ) + " : all arguments are loeaded") ;
        writeAsm("; calling the function "  + $1->getName()) ;
        writeAsm("CALL " + $1->getName()) ;
        push("DX")   ;
        writeAsm(" ; return value is in DX"); 
        asmStream << endl ;


        

    }
| LPAREN expression RPAREN 
   {
        $$ = new SymbolInfo("("  + $2->getName() + ")" , "factor") ; 
        logStream << " Line " << line << ": factor : LPAREN expression RPAREN\n\n" ; 
        logStream << $$->getName() << "\n\n" ; 
        $$->dataType = $2->dataType ; 
        $$->storedAs = "factor" ;  logStream.flush();
   }
| CONST_INT
    {
        logStream << " Line  " <<line << " factor : CONST_INT\n\n" ;
        logStream << $1->getName() <<"\n\n" ; 
        $$ = $1 ; 
        $$->dataType  = "int" ; logStream.flush();
        asmStream <<"\n\t\tPUSH " << atoi(($1->getName()).c_str()) ;
    }
| CONST_FLOAT
    {
        errorStream << "Error at line " << line << " : float is not supported " << endl << endl; 
        logStream << " Line  " <<line << ": factor : CONST_FLOAT\n\n" ;
        logStream << $1->getName() <<"\n\n" ; 
        $$ = $1 ; 
        $$ ->dataType = "float" ;  logStream.flush();
        ++anyError;
    }
| variable INCOP
    {
        logStream << "Line " << line <<  ": factor  : variable INCOP\n\n";
		$$ = new SymbolInfo ($1->getName()  + "++" , "factor") ;
        $$->dataType = $1->dataType ;
        $$->dataType = $1->storedAs;  logStream.flush();
       
       
       
       
        
        asmStream << gap << "; incrementing " ;

        SymbolInfo * temp = st.lookUp(getVaiableName($1->getName())) ; 
        if(temp->storedAs != "array") {

            pop("AX") ; 
            push("AX") ; 
            asmStream << gap << "INC AX" ;
        
            if(temp->isGlobal) { 
                asmStream << "\n\t\tMOV " << $1->getName() << ", AX ; line " << line <<  ": " <<  $1->getName() <<" assigned"  << endl; 
            }
            else if(temp->isArgument) {
                int pos = 4 + 2 * (temp->argumentPos) ;
                asmStream << "\n\t\tMOV  [BP + " << pos << "], AX ; line " << line <<  ": " <<  $1->getName() <<" assigned"  << endl; 
            }
            else { 
                int pos = 10 + 2 * (temp->stackCount) ;
                asmStream <<"\n\t\tMOV [BP - " << pos << "], AX ; line " << line <<  ": " <<  $1->getName() <<" assigned"  << endl; 
            }
        }
        else { 

		    asmStream << "\n\t\tPOP BX ; address"  ; 
		    asmStream << "\n\t\tPOP DX; line no  " << line << " :  ;array value popped " ;
            push("DX") ;
            asmStream << gap << "INC DX" ; 
            if(temp->isGlobal) {
                asmStream << gap << "MOV " << getVaiableName($1->getName()) << "[BX], DX; line " << line << ": " << $1->getName() <<" assigned " << endl;
            }
		    asmStream << "\n\t\tMOV [BX], DX; line no  " << line << " : " << $1->getName() << " assined "  << endl;
        }



    }
| variable DECOP
    {
        logStream << "Line " << line <<  ": factor  : variable DECOP\n\n";
		logStream << "Line " << line <<  ": factor  : variable INCOP\n\n";
		$$ = new SymbolInfo ($1->getName()  + "--" , "factor") ;
        $$->dataType = $1->dataType ;
        $$->storedAs = $1->storedAs;  logStream.flush();






          asmStream << gap << "; decrementing " ;

        SymbolInfo * temp = st.lookUp(getVaiableName($1->getName())) ; 
        if(temp->storedAs != "array") {

            pop("AX") ; 
            push("AX") ; 
            asmStream << gap << "DEC AX" ;
        
            if(temp->isGlobal) { 
                asmStream << "\n\t\tMOV " << $1->getName() << ", AX ; line " << line <<  ": " <<  $1->getName() <<" assigned"  << endl; 
            }
            else if(temp->isArgument) {
                int pos = 4 + 2 * (temp->argumentPos) ;
                asmStream << "\n\t\tMOV  [BP + " << pos << "], AX ; line " << line <<  ": " <<  $1->getName() <<" assigned"  << endl; 
            }
            else { 
                int pos = 10 + 2 * (temp->stackCount) ;
                asmStream <<"\n\t\tMOV [BP - " << pos << "], AX ; line " << line <<  ": " <<  $1->getName() <<" assigned"  << endl; 
            }
        }
        else { 

		    asmStream << "\n\t\tPOP BX ; address"  ; 
		    asmStream << "\n\t\tPOP DX; line no  " << line << " :  ;array value popped " ;
            push("DX") ;
            asmStream << gap << "DEC DX" ; 
            if(temp->isGlobal) {
                asmStream << gap << "MOV " << getVaiableName($1->getName()) << "[BX], DX; line " << line << ": " << $1->getName() <<" assigned " << endl;
            }
		    asmStream << "\n\t\tMOV [BX], DX; line no  " << line << " : " << $1->getName() << " assined "  << endl;
        }
    }
;




argument_list : arguments {
    $$ = $1 ;
    logStream << "Line " << line << ": argument_list : arguments \n\n" ;
    logStream << $$->getName() << "\n\n" ;  logStream.flush();  
}
|
    {
        $$ = new SymbolInfo("" , "") ; 
        logStream << "Line " << line << ": argument_list :  \n\n" ;
        logStream << $$->getName() << "\n\n" ;   logStream.flush(); 
    }
;





arguments : arguments COMMA logic_expression
    {
        $$ = new SymbolInfo ($1->getName() +  ","  +  $3->getName() ,  "_") ; 
        logStream << "Line " << line << " arguments : arguments COMMA logic_expression \n\n" ;
        logStream << $$->getName() << "\n\n" ; 
        $$->dataType = $1->dataType;  
        $$->storedAs = $1->storedAs; 
        $$->parameters = $1->parameters ;
        $$->parameters.push_back(make_pair($3->dataType, "")) ;  logStream.flush();

    }
| logic_expression 
    {
        $$  = $1 ; 
        logStream << "Line " << line << " arguments : logic_expression\n\n" ; 
        logStream << $$->getName() << "\n\n" ;
        $$->dataType = $1->dataType ; 
        $$->storedAs = $1->storedAs; 
        $$->parameters.push_back(make_pair($1->dataType , "")) ; logStream.flush();
    }
;

%%

int main(int argc,char *argv[])
{

	if(argc!=2){
		cout << "Please provide input file name and try again\n";
		return 0;
	}
	
	FILE *infile=fopen(argv[1],"r");
	if(infile==NULL){
		cout << "Cannot open specified file\n";
		return 0;
	}
	
	logStream.open("log.txt");
	errorStream.open("error.txt");
	asmStream.open("code.asm") ;
	yyin=infile;
    asmStream <<  ".MODEL SMALL\n\n.STACK 400h; 1KB stack\n\n.DATA\n" << endl;
	yyparse();
	//symboltable.printAllScopeTable(logout);
	logStream << "Total lines: " << line - 1 << endl;
    logStream << "Total errors: " << error_cnt - line + 1<< endl;
	fclose(yyin);
	logStream.close();
	errorStream.close();
	

    if(anyError)  { 
        ofstream dummyStream ;
        dummyStream.open("asmCode.asm") ; 
        dummyStream << "Compilation Failed. Please check error.txt file " ; 
        dummyStream << endl; 
        dummyStream.close() ;
    }
	codeOptimize();
	return 0;
}

