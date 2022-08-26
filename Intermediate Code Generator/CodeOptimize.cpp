#include<bits/stdc++.h>
using namespace std;
string removeUnnecessary(string input) {
    string ans;
    bool anyFound = false;
    bool commentStart = false; 
    for (auto i : input) {
        if (i == ';')
            commentStart = true;
        
        if (commentStart)
            continue;
        if (i >= 'a' and i <= 'z')
            ans.push_back(toupper(i));
        else if (i >= 'A' and i <= 'Z')
            ans.push_back(toupper(i));
        else if (i == '@' or i == '_' or i == '.' or i == ',' or i == '[' or i == ']')
            ans.push_back(toupper(i));
           
    }
    return ans;

}

bool checkPush(string first, string second) {
    string temp; 
    if (first.size() < 6) return false;
    int i = 0;
    for (; i < 4; ++i) temp.push_back(first[i]);
    if (temp != "PUSH") return false;
    temp.clear();
    for (; i < first.size(); ++i) temp.push_back(first[i]);
    string bemp;
    if (second.size() < 5) return false;
    int j = 0;
    for (;j < 3; ++j) bemp.push_back(second[j]);
    if (bemp != "POP") return false;
    bemp.clear();
    for (; j < second.size(); ++j) bemp.push_back(second[j]);
    if (bemp != temp) return false;
    return true; 
}

bool checkMov(string first, string second) {
    if (first.size() < 7 or second.size() < 7) return false;
    
    int i = 0, j = 0;
    string s, t;
    for (; i < 3; ++i) {
        s.push_back(first[i]);
        t.push_back(second[i]); 
    }
    if (s != t or s != "MOV") return false;
    s.clear();
    t.clear();
    i = j = 3;
    string a, b, c, d;
    bool comma = false;
    for (; i < first.size(); ++i) {
        if (first[i] == ',') comma = true;
        else if (!comma) a.push_back(first[i]);
        else b.push_back(first[i]);
    }
    comma = false; 
    for (; j < second.size(); ++j) {
        if (second[j] == ',') comma = true;
        else if (!comma) c.push_back(second[j]);
        else d.push_back(second[j]);
    }
 //   cout << a << " " << b << " " << c << "  " << d << endl;
    if (a == d and b == c) return true;
    return false;
}
void codeOptimize() {
    ifstream codeRead("code.asm");
    ofstream optimizeStream("optimized_code.asm");
    string line1, line2;
    string lastCommand;
    bool movCommand = false;
    bool pushCommand = false;
    string first, second;


    while (first.empty() and getline(codeRead, line1)) {
        first = removeUnnecessary(line1);
    }
    if (first.empty()) return;
    
    while (true) {
        while (second.empty() and getline(codeRead, line2)) {
            second = removeUnnecessary(line2);
        }
        if (second.empty()) {
            optimizeStream << line1 << endl;
            return;
        }


        if (checkPush(first , second)) {
            optimizeStream << "\n\t\t;Optimization" << endl;
            optimizeStream << "; " << line1 << endl;
            optimizeStream << "; " << line2 << endl;
            //code 
            
            
            first.clear();


            while (first.empty() and getline(codeRead, line1)) {
                first = removeUnnecessary(line1);
            }
            if (first.empty()) return;

            second.clear();

            continue;
        }
        if (checkMov(first ,second)) {
            optimizeStream << ";\n\t\t;Optimization" << endl;
            optimizeStream << line1 << endl;
            optimizeStream << ";" << line2 << endl;
            //code 
            first.clear();
            while (first.empty() and getline(codeRead, line1)) {
                first = removeUnnecessary(line1);
            }
            if (first.empty()) return;

            second.clear();
            continue;
        }
        optimizeStream << line1 << endl;
        line1 = line2;
        first = second;
        second.clear();



    }


}
