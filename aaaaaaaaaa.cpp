#include <iostream>
#include<stdlib.h>
#include<list>
#include<queue>
using namespace std;

/* run this program using the console pauser or add your own getch, system("pause") or input loop */

class Graph{
	int V;
	list<int> *adj;
public:
	Graph(int V){
		this->V=V;
		adj=new list<int>[V];
	}
	void addEdge(int v,int w){
		adj[v].push_back(w);
	}
	void BFS(int s){
		bool* visited=new bool[V];
		for(int i=0;i<V;i++){
			visited[i]=false;
		}
		list<int> queue;
		visited[s]=true;
		queue.push_back(s);
		
		list<int>::iterator i;
		while(!queue.empty()){
			s=queue.front();
			cout<<s<<"  ";
			queue.pop_front();
			for( i=adj[s].begin();i!=adj[s].end();++i){
				if(!visited[*i]){
					visited[*i]=true;
					queue.push_back(*i);
				}
			}
		}
	}
	
};
int main() {
	
	Graph g(4) ;
	g.addEdge(0,1);
	g.addEdge(1,2);
	g.addEdge(2,0);
	g.addEdge(0,2);
	g.addEdge(2,3);
	g.addEdge(3,3);
	
	cout<<"BFS from vertex 0 is "<<endl;
	g.BFS(0);	
	return 0;
}

