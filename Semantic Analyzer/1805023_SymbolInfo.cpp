#include<iostream>
#include<string>
#include<bits/stdc++.h>
using namespace std;
class SymbolInfo {
    string name, typ;
    SymbolInfo* next;
public:
    string dataType, storedAs;
    // dataType : will be used as Return type in case of function 
    // storedAs : example  : var , array , function  ;

    vector<pair<string, string>> parameters;
    // stores the data type of the parameter_list or arguments_list of a function
    
    bool isDefined; // to check whether a function is defined or not
    string index; 
    SymbolInfo() {
        next = NULL;
        name = typ = "";
    }

    SymbolInfo(string _name, string _typ) {
        next = NULL;
        name = _name;
        typ = _typ;
    }
    SymbolInfo(string _name, string _typ, string _dataType, string _storedAs) {
        name = _name;
        typ = _typ;
        dataType = _dataType;
        storedAs = _storedAs;
        next = NULL;
    }
    
    SymbolInfo* Propagate() {
        return this->next;
    }
    void insert(string _name, string _typ) {
        SymbolInfo* toAdd = new SymbolInfo(_name, _typ);
        toAdd->next = this->next;
        this->next = toAdd;
    }
    void remove() {
        if (next != NULL) {
            SymbolInfo* temp = next;
            next = temp->next;
            name = temp->name;
            typ = temp->typ;
            delete temp;
        }

    }

    string getName() {
        return name;
    }
    string getType() {
        return typ;
    }
    void setNext(SymbolInfo* temp) {
        next = temp;
    }
};
