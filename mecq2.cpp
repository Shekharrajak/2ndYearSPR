#include <iostream>
#include<stack>
using namespace std;
 
/* run this program using the console pauser or add your own getch, system("pause") or input loop */


int matched(char *x) {
  int i;
  stack<char> s;
  //init(&s);
  for(i = 0; x[i] != '\0'; i++) {
    switch(x[i]) {
    case '(':
      s.push(x[i]); break;
    case ')':
      if(s.empty()) return 0;
      if(&s.top() == "(") return 1;
      else return 0;
    }
  }
  return s.empty();
}
int main(int argc, char** argv) {
	string x = "())";
	cout <<matched(&x[0]);
	return 0;
}
