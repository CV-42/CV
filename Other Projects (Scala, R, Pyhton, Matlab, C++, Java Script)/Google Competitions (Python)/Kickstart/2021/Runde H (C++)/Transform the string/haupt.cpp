using namespace std;
#include <iostream>
#include <vector>

int abstand(char ch, string F){
    int res = 26;
    for (char f: F){
        int a = abs(f - ch);
        int b = abs(ch - 'z') + 1 + abs('a' - f);
        int c = abs(ch - 'a') + 1 + abs('z' - f);
        res = min(a, min(b, min(c, res)));
    }
    return res;
}

int abstand(string S, string F){
    int res = 0;
    for (char ch: S){
        res += abstand(ch, F);
    }
    return res;
}

int main(){
    long int T;
    cin >> T;

    for (int t = 1; t<=T; ++t){
        string S;
        string F;
        cin >> S >> F;
        cout << "Case #" << t << ": " << abstand(S,F) << "\n";
    }

    return 0;
}