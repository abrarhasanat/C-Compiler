#include<bits/stdc++.h>
using namespace std;
string gapp = "\n\t\t";
string  printPrintHelper() {
    ifstream ifs("printHelper.txt");
    string s = "";
    string contents = ""; 
    while (getline(ifs, s)) {
        contents += s;
        contents.push_back('\n');

    }
    
    ifs.close();
    return contents;
}
