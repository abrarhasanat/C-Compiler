#include<iostream>
#include<string>
#include<bits/stdc++.h>
using namespace std;
class SymbolInfo {
    string name, typ;
    SymbolInfo* next;


public:
    SymbolInfo();
    SymbolInfo(string, string);
    SymbolInfo* Propagate();
    void insert(string, string);
    void remove();
    string getName();
    string getType();
    void setNext(SymbolInfo*);
};

SymbolInfo::SymbolInfo() {
    next = NULL;
    name = typ = "";

}

SymbolInfo::SymbolInfo(string _name, string _typ) {
    next = NULL;
    name = _name;
    typ = _typ;
}

SymbolInfo* SymbolInfo::Propagate() {
    return this->next;
}
void SymbolInfo::insert(string _name, string _typ) {
    SymbolInfo* toAdd = new SymbolInfo(_name, _typ);
    toAdd->next = this->next;
    this->next = toAdd;
}
void SymbolInfo::remove() {
    if (next != NULL) {
        SymbolInfo* temp = next;
        next = temp->next;
        name = temp->name;
        typ = temp->typ;
        delete temp;
    }

}

string SymbolInfo::getName() {
    return name;
}
string SymbolInfo::getType() {
    return typ;
}
void SymbolInfo::setNext(SymbolInfo* temp) {
    next = temp;
}
