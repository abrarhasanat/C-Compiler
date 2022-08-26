%{
#include<bits/stdc++.h>
#include "1805023_SymbolTable.cpp"
using namespace std ;
int yyparse(void);
int  yylex(void);
extern FILE *yyin;
ofstream errorStream;
ofstream logStream;
SymbolTable st(30); 
extern int line; 
extern int error_cnt;
bool anyVoid ;
string varType; 
string currReturnType;
vector <pair < string ,string >> parameters; 
bool returnStatement = false;  
string returnType = "" ;
int returnLine ;
void yyerror(string s) {
   //write your code
    //error_cnt++;
    logStream << "Error at line " << line << ": " << s << "\n" ; 
    errorStream << "Error at line " << line << ": " << s << "\n" ;
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
            }
            else { 
                //function is declared before but not defined ; 
                if(temp->dataType != $1->getName())  {
                        error_cnt++;
						logStream<<"Error at Line "<<line<<": Return type mismatch with declared functon "<<$2->getName()<< "\n\n"; 
						errorStream<<"Error at Line "<<line<<": Return type mismatch with declared function "<<$2->getName() << "\n\n" ;
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
    }
    }
    compound_statement 
    {
        
        if($1->getName() == "void"  && returnStatement) { 
            logStream <<"Error at Line " << returnLine << ": " << "Return statement with a value in function void\n\n" ;
            errorStream << "Error at Line " << returnLine << ": " << "Return statement with a value in function void\n\n" ;
            error_cnt++ ; 
        }
        
        if($1->getName() == "int" && returnType == "float") { 
            logStream << "Warning at Line " << returnLine <<": conversion from float to int\n\n" ;
            errorStream << "Warning at Line " << returnLine <<": conversion from float to int\n\n" ;
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
        parameters.clear() ;
        $$ = new SymbolInfo(temp , "_") ; 
        logStream << "Line " << line <<": func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n" ;
        logStream << $$->getName() << "\n\n" ; 
        logStream.flush();

        returnType = "" ;
        returnStatement = false ; 
        returnLine = -1; 
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
            }
            else if(temp->dataType != $1->getName())  {
                        error_cnt++;
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
    }
    compound_statement {st.printAll(logStream) ; st.exitScope();} 
    {
         if($1->getName() == "void"  && returnStatement )  { 
            logStream <<"Error at Line " << returnLine << ": " << "Return statement with a value in function void\n\n" ;
            errorStream << "Error at Line " << returnLine << ": " << "Return statement with a value in function void\n\n" ;
            error_cnt++ ; 
        }
        
        if($1->getName() == "int" && returnType == "float") { 
            logStream << "Warning at Line " << returnLine <<": conversion from float to int\n\n" ;
            errorStream << "Warning at Line " << returnLine <<": conversion from float to int\n\n" ;
        }
        string temp = $1->getName()  +" " + $2->getName() + "(";
        for (int i = 0 ; i < parameters.size();  ++i ) {
            if(i) temp += "," ;
            temp = temp + parameters[i].first; 
            if(!parameters[i].second.empty()) 
                temp = temp +  " " + parameters[i].second ;
        }
        temp += ")\n" ;
        parameters.clear() ;
        temp += $6->getName() ; 
        $$ = new SymbolInfo(temp , "_") ; 
        logStream << "Line " << line <<": func_definition : type_specifier ID LPAREN  RPAREN compound_statement\n\n" ;
        logStream << $$->getName() << "\n\n" ; 
        logStream.flush();

        returnType = "" ;
        returnStatement = false ; 
        returnLine = -1; 
    }

;




parameter_list : parameter_list COMMA type_specifier ID
    {
        
        if($3->getName() == "void") {
            logStream << "Error at line " << line << ": variable of type void for " << $1->getName() << "\n\n";
			errorStream<< "Error at line " << line << ": variable of type void for " << $1->getName() << "\n\n";
			error_cnt++;
        }

        else if (anyVoid) {
            anyVoid = false; 
            logStream << "Error at line " << line << ": Invalid use of type void" << "\n\n";
			errorStream << "Error at line " << line << ":Invalid use of type void" << "\n\n";
			error_cnt++;
        }

        else if(find(parameters.begin() , parameters.end() , make_pair($3->getName() , $4->getName())) != parameters.end()){
             logStream << "Error at line " << line << ": Multiple declaration of " << $4->getName() << "\n\n";
			 errorStream << "Error at line " << line << ": Multiple declaration of " << $4->getName() << "\n\n";
			 error_cnt++;
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
        }
        else if (anyVoid) {
            anyVoid = false; 
            logStream << "Error at line " << line << ": Invalid use of type void" << "\n\n";
			errorStream << "Error at line " << line << ":Invalid use of type void" << "\n\n";
			error_cnt++;
        }
        else if(find(parameters.begin() , parameters.end() , make_pair($1->getName() , $2->getName())) != parameters.end()){
             logStream << "Error at line " << line << ": Multiple declaration of " << $2->getName() << "\n\n";
			 errorStream << "Error at line " << line << ": Multiple declaration of " << $2->getName() << "\n\n";
			 error_cnt++;
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
        varType =  "float";
        $$ = new SymbolInfo("float" , varType);
        logStream << $$->getName() << "\n\n"  ; logStream.flush();
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
        }
        else if(!st.insert($3->getName() , "ID"))  { 
                logStream << "Error at line " << line << ": Multiple declaration of " << $3->getName() << "\n\n";
			    errorStream << "Error at line " << line << ": Multiple declaration of " << $3->getName() << "\n\n";
			    error_cnt++;
        }
            
        $$ = new SymbolInfo($1->getName() + "," + $3->getName() , "_") ;
        logStream << "Line " << line <<  ": declaration_list : declaration_list COMMA ID\n\n";
		logStream << $1->getName() + "," + $3->getName() << "\n\n";
        SymbolInfo * temp = st.lookUp($3->getName()) ; 
        temp->dataType = varType ;
        temp->storedAs = "variable"; 
        logStream.flush();
        
    }
| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
    {
         //logStream << "Line " << line <<  ": declaration_list : declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n";
         if (varType == "void") { 
            logStream << "Error at line " << line << ": variable of type void for " << $3->getName() << "\n\n";
			errorStream<< "Error at line " << line << ": variable of type void for " << $3->getName() << "\n\n";
			error_cnt++;
        }
        else {
            if(!st.insert($3->getName() , "ID")) {
                logStream << "Error at line " << line<< ": Multiple declaration of " << $3->getName() << "\n\n";
			    errorStream << "Error at line " << line << ": Multiple declaration of " << $3->getName() << "\n\n";
			    error_cnt++;
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
        
        
    }
| ID
    {
        if(varType == "void") {
            // logStream << "Error at line " << line << ": variable of type void for " << $1->getName() << "\n\n";
			// errorStream<< "Error at line " << line << ": variable of type void for " << $1->getName() << "\n\n";
			// error_cnt++;
        }
        else  
        if(!st.insert($1->getName() , "ID"))  { 
                logStream << "Error at line " << line<< ": Multiple declaration of " << $1->getName() << "\n\n";
			    errorStream << "Error at line " << line << ": Multiple declaration of " << $1->getName() << "\n\n";
			    error_cnt++;
        }
        else {
            SymbolInfo * temp = st.lookUp($1->getName()) ;
            temp->dataType = varType ;
            temp->storedAs = "variable";
        }
            
        $$ = new SymbolInfo($1->getName() , "_") ;
        logStream << "Line " << line <<  ": declaration_list : ID\n\n";
		logStream << $1->getName() << "\n\n";
         logStream.flush();
			
            
        
    }
| ID LTHIRD CONST_INT RTHIRD
    {
        
        if (varType == "void") { 
            logStream << "Error at line " << line << ": variable of type void for " << $1->getName() << "\n\n";
			errorStream<< "Error at line " << line << ": variable of type void for " << $1->getName() << "\n\n";
			error_cnt++;
        }
        else if(!st.insert($1->getName() , "ID")) {
                logStream << "Error at line " << line<< ": Multiple declaration of " << $1->getName() << "\n\n";
			    errorStream << "Error at line " << line << ": Multiple declaration of " << $1->getName() << "\n\n";
			    error_cnt++;
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
| FOR LPAREN expression_statement expression_statement expression RPAREN statement 
	{
			$$ = new SymbolInfo("for( "+$3->getName()+$4->getName()+$5->getName()+")"+$7->getName() , "_");
			logStream<<"Line "<<line <<": statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n";
			logStream<<$$->getName() << "\n\n" ; logStream.flush();
	}
| IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
	{
			$$= new SymbolInfo("if( "+$3->getName()+ ")\n"+$5->getName() , "_");
			logStream <<"Line "<<line<<": statement : IF LPAREN expression RPAREN statement\n\n" ; 
			logStream<<$$->getName() << "\n\n" ;  logStream.flush();
	}
| IF LPAREN expression RPAREN statement ELSE statement 
	{
		$$= new SymbolInfo("if( "+$3->getName()+")\n"+$5->getName()+"\nelse\n"+$7->getName() , "_");			
		logStream<<"Line "<<line<<": statement : IF LPAREN expression RPAREN statement ELSE statement\n\n";
		logStream<<$$->getName()<< "\n\n"; logStream.flush();
	}
| WHILE LPAREN expression RPAREN statement 
	{
        $$= new SymbolInfo("while("+$3->getName()+")\n"+$5->getName() , "_");
		logStream<<"Line "<<line<<": statement : WHILE LPAREN expression RPAREN statement\n\n";
		logStream<<$$->getName()<<"\n\n"; logStream.flush();
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
			}
			else if(temp->storedAs !="variable"){
				logStream<<"Error at Line "<<line<<": "<<$3->getName()<<" cannot be printed"<< "\n\n";
				errorStream<<"Error at Line "<<line <<": "<<$3->getName() << " cannot be printed"<< "\n\n";
			}
			logStream << $$->getName() << "\n\n" ; logStream.flush();
	}
| RETURN expression SEMICOLON 
	{
		    $$= new SymbolInfo("return " +$2->getName()+";", "_");	
			logStream<<"Line "<<line<<": statement : RETURN expression SEMICOLON\n\n";
			logStream << $$->getName() <<  "\n\n" ;  logStream.flush();
            returnStatement = true ;
            returnType = $2->dataType ;
            returnLine = line ;
	}
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
            
	}
;






variable : ID
    {
        $$ = $1  ; 
        logStream <<  "Line " << line <<  " variable : ID\n\n";
        SymbolInfo * temp = st.lookUp($1->getName()) ;  
        if(temp == NULL) { 
            logStream << "Error at line " << line << ": Undeclared variable " << $1->getName() << "\n\n";
			errorStream << "Error at line " << line << ": Undeclared variable " << $1->getName() << "\n\n";
			error_cnt++;
        }
        else if(temp->storedAs == "array") {
            logStream << "Error at line " << line << ": Type mismatch, " << $1->getName() << " is an array\n\n";
			errorStream << "Error at line " << line << ": Type mismatch, " << $1->getName() << " is a array\n\n";
			error_cnt++;
        }
        else if(temp->storedAs == "function") {
            logStream << "Error at line " << line << ": Type mismatch, " << $1->getName() << " is an fujction\n\n";
			errorStream << "Error at line " << line << ": Type mismatch, " << $1->getName() << " is a function\n\n";
			error_cnt++;
        }
        if(temp != NULL) {
            $$->dataType = temp->dataType; 
            $$->storedAs = temp->storedAs ;
        }
        logStream << $$->getName() << "\n\n" ;  logStream.flush();
    }
| ID LTHIRD expression RTHIRD
    {
        $$ = new SymbolInfo ($1->getName() + "[" + $3->getName() + "]" , "_");
        logStream << "Line " << line <<   " variable : ID LTHIRD expression RTHIRD\n\n" ;
        SymbolInfo * temp = st.lookUp($1->getName()) ; 
        if(temp == NULL) { 
            logStream << "Error at line " << line << ": Undeclared variable " << $1->getName() << "\n\n";
			errorStream << "Error at line " << line << ": Undeclared variable " << $1->getName() << "\n\n";
			error_cnt++;
        }
        else if (temp->storedAs != "array") { 
            logStream << "Error at line " << line  << ": "<< $1->getName() << " is not an array " << "\n\n" ; 
            errorStream << "Error at line " << line  << ": "<< $1->getName() << " is not an array " << "\n\n" ; 
            error_cnt++; 
        }
        else if($3->getType() != "CONST_INT"){
            logStream << "Error at line " << line  <<": Index must be const int \n\n" ; 
            errorStream << "Error at line " << line  <<": Index must be const int \n\n" ; 
            error_cnt++;
        }
        $$->index = $3->getName();
        if(temp != NULL)  
            $$->dataType = temp->dataType ;

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
        }

        if($3->storedAs == "array") {
                    logStream << "Error at line " << line << " type mismatch\n\n";
                    errorStream << "Error at line " << line << " type mismatch\n\n" ;
                    error_cnt ++ ;
        }
        $$->dataType = $1->dataType;
        if($3->dataType == "float" && $1->dataType == "int") {
                    logStream << "Warning at line " << line << ": convertion from float to int\n\n";	
                    errorStream << "Warning at line " << line << ": convertion from float to int\n\n";	
                    $$->dataType = "int" ;			
        }
        logStream << "Line " << line <<  " expression : variable ASSIGNOP logic_expression\n\n";
        logStream << $$->getName()  << "\n\n" ; logStream.flush();

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
        }
        $$ = new SymbolInfo($1->getName() +  $2->getName()  + $3->getName(), " ") ;
        logStream << "Line " << line << " simple_expression RELOP simple_expression\n\n" ;
        logStream << $1->getName() << " " << $2->getName() << " " << $3->getName() <<"\n\n" ;  logStream.flush();
        $$->dataType = "int" ;

       
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
        }

        else if($2->getName() ==  "%") {
            if($3->getName() == "0" ) { 
                logStream<<"Error at line "<<line<<": Modulus by Zero"<<endl<<endl;
				errorStream<<"Error at line "<<line<<": Modulus by Zero"<<endl<<endl;
			    error_cnt++ ;

            }
            else if($1->dataType == "float" || $3->dataType == "float") { 
                logStream<<"Error at line "<<line<<": Non-Integer operand on modulus operator"<<endl<<endl;
				errorStream<<"Error at line "<<line<<": Non-Integer operand on modulus operator"<<endl<<endl;
			    error_cnt++; 

            }
        }
        $$ = new SymbolInfo($1->getName()  + $2->getName() +  $3->getName() , "term") ; 
        logStream << "Line " << line <<  " term :  term MULOP unary_expression\n\n";
        logStream << $$->getName() << "\n" ;
        $$->dataType = "int" ;
        if(($1->dataType ==  "float"  || $3->dataType == "float" ) && $2->getName() != "%")
        $$->dataType = "float" ;
        logStream.flush();
    }
;




unary_expression : ADDOP unary_expression
    {
        if($2->dataType == "void") { 
            logStream << "Error at line " << line << ": Wrong type argument to unary_expression\n\n" ;
            errorStream << "Error at line " << line << ": Wrong type argument to unary_expression\n\n" ;
            error_cnt++ ;
        }
        $$ = new SymbolInfo("+" + $2->getName() ,   "_") ; 
        logStream << "Line " << line <<  ": unary_expression : factor \n\n";
  	    logStream << $$->getName() << "\n\n" ;
        $$->dataType = $2->dataType; logStream.flush();
  
    }
| NOT unary_expression
    {
        if($2->dataType == "void") { 
            logStream << "Error at line " << line <<": Wrong type argument to unary_expression\n\n" ;
            errorStream << "Error at line " << line <<": Wrong type argument to unary_expression\n\n" ;
            error_cnt++ ;
        }
        $$ = new SymbolInfo("!" + $2->getName() ,   "_") ; 
        logStream << "Line " << line <<  ": unary_expression : factor \n\n";
  	    logStream << $$->getName() << "\n\n" ;
        $$->dataType  = $2->dataType;  logStream.flush();
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
        }
        else if(temp->storedAs != "function") { 
            logStream << "Error at line " << line << ": " << $1->getName() << " is not a function\n\n";
			errorStream << "Error at line " << line << ": " << $1->getName() << " is not a function\n\n";
			error_cnt++;
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
                }
            }
            else if($3->parameters.size() > temp->parameters.size()) {
                logStream << "Error at line " << line << ": too many arguments\n\n";
				errorStream << "Error at line " << line<< ": too many arguments\n\n";
				error_cnt++;
            }
            else  if ($3->parameters.size() < temp->parameters.size()) { 
                logStream << "Error at line " << line << ": too few arguments \n\n";
				errorStream << "Error at line " << line<< ": too few arguments \n\n";
				error_cnt++;
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
    }
| CONST_FLOAT
    {
        logStream << " Line  " <<line << ": factor : CONST_FLOAT\n\n" ;
        logStream << $1->getName() <<"\n\n" ; 
        $$ = $1 ; 
        $$ ->dataType = "float" ;  logStream.flush();
    }
| variable INCOP
    {
        logStream << "Line " << line <<  ": factor  : variable INCOP\n\n";
		$$ = new SymbolInfo ($1->getName()  + "++" , "factor") ;
        $$->dataType = $1->dataType ;
        $$->dataType = $1->storedAs;  logStream.flush();
    }
| variable DECOP
    {
        logStream << "Line " << line <<  ": factor  : variable DECOP\n\n";
		logStream << "Line " << line <<  ": factor  : variable INCOP\n\n";
		$$ = new SymbolInfo ($1->getName()  + "--" , "factor") ;
        $$->dataType = $1->dataType ;
        $$->storedAs = $1->storedAs;  logStream.flush();
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
	
	yyin=infile;
	yyparse();
	//symboltable.printAllScopeTable(logout);
	logStream << "Total lines: " << line - 1 << endl;
    logStream << "Total errors: " << error_cnt - line + 1<< endl;
	fclose(yyin);
	logStream.close();
	errorStream.close();
	
	
	return 0;
}

