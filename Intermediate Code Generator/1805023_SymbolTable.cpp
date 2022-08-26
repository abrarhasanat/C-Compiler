#include<bits/stdc++.h>
#include "1805023_ScopeTable.cpp"
using namespace std;
class SymbolTable {
    ScopeTable* current;
    int bucket_size;
    int numOfParentScopes;
public:
    SymbolTable(int n) {
        bucket_size = n;
        numOfParentScopes = 1;
        current = new ScopeTable(n);
        current->setId("", numOfParentScopes);
    }
    void enterScope() {
        if (current == NULL) {
            ++numOfParentScopes;
            current = new ScopeTable(bucket_size);
            current->setId("", numOfParentScopes);
        }
        else {
            current->increseChild();
            ScopeTable* temp = new ScopeTable(bucket_size);
            temp->setId(current->getId(), current->getNumOfChild());
            temp->setParentScope(current);
            current = temp;
        }
        cout << "New ScopeTable with id " << current->getId() << " created" << endl;
    }
    void exitScope() {
        if (current == NULL) {
            cout << "No scope is opened currently" << endl;
            return;
        }
        cout << "ScopeTable with id " << current->getId() << " removed" << endl;
        ScopeTable* temp = current;
        current = current->getParentScope();
        delete temp;
    }
    bool insert(string name, string type) {
        if (current == NULL) return false;
        return current->insert(name, type);
    }
    bool remove(string name) {
        return current->Delete(name);
    }
    SymbolInfo* lookUp(string name) {
        ScopeTable* temp = current;
        while (temp != NULL) {
            SymbolInfo* res = temp->lookUp(name);
            if (res != NULL) return res;
            temp = temp->getParentScope();
        }
        cout << "not found" << endl;
        return nullptr;
    }
    void printCurrent() {
        current->Print();
    }
    void printAll() {
        ScopeTable* temp = current;
        while (temp != NULL) {
            temp->Print();
            temp = temp->getParentScope();
            cout << endl;
        }
    }

    void printAll(ofstream& logStream) {
        ScopeTable* temp = current;
        while (temp != NULL) {
            temp->Print(logStream);
            temp = temp->getParentScope();
            cout << endl;
        }
    }
    string getCurrentScopeId() {
        return current->getId();
    }
    int getCurrentArrayNum() {
        return current->numOfArrays;  
    }
    void incrementArrayNum() {
        current->numOfArrays++;
    }
    int getCurrentStackCount() {
        return current->stackCount;
    }
    void increaseStackCount(int value) {
        current->stackCount += value;
    }



};

// int main() {
//    // freopen("input.txt", "r", stdin);
//    // freopen("output.txt", "w", stdout);
//     int n; cin >> n;
//     SymbolTable st(n);
//     char cmd ;
//     while (cin>> cmd) {
//         //char cmd; cin >> cmd;
//         //cout << cmd << endl;
//         cout << "\n";
//         if (cmd == 'I') {
//             string name, typ;
//             cin >> name >> typ;
//             st.insert(name, typ);
//         }
//         else if (cmd == 'L') {
//             string name; cin >> name;
//             st.lookUp(name);
//         }
//         else if (cmd == 'D') {
//             string name;cin >> name;
//             st.remove(name);
//         }
//         else if (cmd == 'P') {
//             char x;  cin >> x;
//             if (x == 'A') st.printAll();
//             else st.printCurrent();
//         }
//         else if (cmd == 'S') {
//             st.enterScope();
//         }
//         else if (cmd == 'E') {
//             st.exitScope();
//         }
//         else if(cmd == '$') {
//             break;
//         }
//         else {
//             cout << "Undefined command" << endl;
//         }
//         cout << endl;
//     }

// }


