#include<bits/stdc++.h>
#include "1805023_SymbolInfo.cpp"
using namespace std;
class linkedList {
    SymbolInfo* head;
    int size;
public:
    linkedList();
    int addSymbol(string, string);
    void printKeys();
    int deleteAKey(string);
    bool isEmpty();
    int  length();
    pair< SymbolInfo*, int>  lookUp(string);
    string getHeadName() {
        if (head == NULL) return "-";
        return head->getName();
    }
    string getHeadType() {
        if (head == NULL) return  "-_-";
        return head->getType();
    }
    ~linkedList() {

        SymbolInfo* temp = head;
        while (temp != NULL and size > 1) {
            temp->remove();
            --size;
        }
        if (head != NULL) delete head;
    }
};

linkedList::linkedList() {
    head = NULL;
    size = 0;
}

int linkedList::addSymbol(string _name, string _typ) {
    if (head == NULL) {
        head = new SymbolInfo(_name, _typ);
        ++size;
        return  0;
    }
    else {
        SymbolInfo* temp = head;
        while (temp->Propagate() != NULL) {
            if (temp->getName() == _name and temp->getType() == _typ) return  -1;
            temp = temp->Propagate();
        }
        if (temp->getName() == _name and temp->getType() == _typ) return -1;
        temp->insert(_name, _typ);
        ++size;
        return 1;
    }

}
void linkedList::printKeys() {
    SymbolInfo* temp = head;
    while (temp != NULL) {
        cout << "< " << temp->getName() << " : " << temp->getType() << " >";
        temp = temp->Propagate();
    }
}
int linkedList::deleteAKey(string _name) {
    SymbolInfo* temp = head;
    --size;
    int pos = 0;
    if (size == 0) {
        if (head->getName() == _name) {
            SymbolInfo* temp = head;
            head = NULL;
            delete temp;
            return pos;
        }
        return -1;
    }
    while (temp != NULL) {
        if (temp->getName() == _name) {
            temp->remove();
            return pos;
        }
        ++pos;
        SymbolInfo* check = temp->Propagate();
        if (temp->getName() == _name and check->Propagate() == NULL) {
            delete check;
            temp->setNext(NULL);
            return pos;
        }
        temp = check;
    }
    return  -1;
}

pair<SymbolInfo*, int> linkedList::lookUp(string name) {
    if (head == NULL) return { nullptr , -1 };
    SymbolInfo* temp = head;
    int pos = 0;
    while (temp != NULL) {
        if (temp->getName() == name) {
            return make_pair(temp, pos);
        }
        ++pos;
        temp = temp->Propagate();
    }
    return make_pair(nullptr, -1);
}

bool linkedList::isEmpty() {
    return size == 0;
}
int linkedList::length() {
    return size;
}
