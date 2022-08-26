#include<bits/stdc++.h>
#include"1805023_LinkedList.cpp"
using namespace std;
const int CHAIN = 0;
class ScopeTable {
    vector<linkedList>table;
    int size;
    int numOfChild;
    string id;
    ScopeTable* parentScope;
    long long getHashValue(string name) {
        unsigned long hash = 0;
        int c;
        for (int c : name) {
            hash = c + (hash << 6) + (hash << 16) - hash;

        }
        return hash % size;

    }
public:
    ScopeTable() {
        size = 0;
        parentScope = NULL;
        id = "";
        numOfChild = 0;
    }

    ScopeTable(int _size) {
        size = _size;
        table.resize(size);
        parentScope = NULL;
        id = "";
        numOfChild = 0;
    }

    ScopeTable(int _size, ScopeTable* parent) {
        size = _size;
        table.resize(size);
        parentScope = parent;
    }

    bool insert(string name, string type) {
        long long hashVal = getHashValue(name);
        int temp = table[hashVal].addSymbol(name, type);
        if (temp == -1) {
            cout << "< " << name << ":" << type << " > already exists in current scope table" << endl;
            return false;
        }
        cout << "Inserted in ScopeTable# " << id << "  at position " << hashVal << ", " << -1 + table[hashVal].length() << endl;
        return true;
    }

    SymbolInfo* lookUp(string key) {
        int index = getHashValue(key);

        pair <SymbolInfo*, int> temp = table[index].lookUp(key);
        if (temp.second != -1) {
            cout << "Found in ScopeTable# " << id << " at position " << index << ", " << temp.second << endl;
        }

        // first value returns the  number of probes
        // second value return the corresponding value of the key
        return temp.first;
    }


    bool Delete(string name) {
        SymbolInfo* res = lookUp(name);
        cout << endl;
        if (res == NULL) {
            cout << name << " not found" << endl;
            return false;
        }
        else {
            int index = getHashValue(name);
            int pos = table[index].deleteAKey(name);
            cout << "Deleted Entry " << index
                << ", " << pos << " from current ScopeTable" << endl;
            return true;
        }
    }
    void Print() {
        cout << "ScopeTable# " << id << endl;
        for (int i = 0;i < table.size(); ++i) {
            cout << i << " --> ";
            table[i].printKeys();
            cout << endl;
        }
    }

    string getId() {
        return id;
    }

    int getNumOfChild() {
        return numOfChild;
    }

    void increseChild() {
        ++numOfChild;
    }

    void setId(string parentId, int cnt) {
        //cout << parentId << " " << cnt << endl;
        if (!parentId.empty()) {
            id = parentId;
            id += ".";
        }
        id += ('0' + cnt);
    }
    void setParentScope(ScopeTable* parent) {
        parentScope = parent;
    }
    ScopeTable* getParentScope() {
        return parentScope;
    }

    ~ScopeTable() {

        table.clear();
    }

};

// int main() {
//     ScopeTable* sc = new ScopeTable(2);
//     sc->insert("int", "keywords");
//     sc->insert("int", "keywords");
//     sc->insert("123", "number");
//     sc->insert("foo", "function");
//     sc->Print();
//     sc->lookUp("foo");
//     sc->Delete("foo");
//     sc->Delete("sdfa");
//     sc->Print();


// }

