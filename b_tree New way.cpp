/*
	author - Anubhav
	compiler - gcc 4.3.2
	os - ubuntu 9.10
*/

#include <iostream>
#include <cstdlib>
using namespace std;
struct btnode
{
	int count ;
	int *key;
	btnode **child;
	
	btnode(int x)
	{
		key=new int[2*x+1]; 				//instead of 0 data key is filled from 1
		child=new btnode*[2*x+1];
		count=0;
	}
} ;
class btree
{
	private :
		btnode *root ;
		int d;
		int min ,max;
	public :
		btree(int x);
		
		void insert ( int val ) ;  //insert a key in the tree
		
		int adjust_val ( int val, btnode *n, int &p, btnode * &c ) ;  //goes to the position of insertion and splits the node if necessary and returns true if node is splitted
		
		static int searchnode ( int val, btnode *n, int &pos ) ;  //searches for a given key in the given node
		
		void fillnode ( int val, btnode *c, btnode *n, int k ) ;  //enters the given number at sorted position and adjusts the pointers
		
		void split ( int val, btnode *c, btnode *n,int k, int &y, btnode * &newnode ) ;  //splits the node into two
		
		void show( ) ;  //prints the tree
		
		void display ( btnode *t ) ;  //in-order traversal
		
		void del ( int val ) ;  //delete a key
		
		int delete_val ( int val, btnode *t ) ;  //actually performs the delete operation :)
		
		void clear ( btnode *t, int k ) ;  //deletes the k th key and moves everything one step backward
		
		void copysucc ( btnode *t, int i ) ;  //copy the successor of t->val[i] into t->val[i]
		
		void restore ( btnode *t, int i ) ;  //restores the b-tree property of a node
		
		void rightshift ( btnode *t,int k ) ;  //shifts a key from left --> right
		
		void leftshift ( btnode *t,int k ) ;  //shifts a key from left --> right
		
		void merge ( btnode *t,int k ) ;  //merges node k and k-1
} ;
 
btree :: btree(int x)
{
	root = NULL ;
	d=x;
	min=x;
	max=2*x;
}
void btree :: insert ( int val )
{
	int i ;
	btnode *c, *n ;
	bool flag ;
	flag = adjust_val ( val, root, i, c ) ;
	if ( flag )
	{
		n = new btnode(d) ;
		n -> count = 1 ;
		n -> key[1] = i ;
		n -> child[0] = root ;
		n -> child[1] = c ;
		root = n ;
	}
}
int btree :: adjust_val ( int val, btnode *n, int &p, btnode *&c )
{
	int k ;
	if ( n == NULL )
	{
		p = val ;
		c = NULL ;
		return 1 ;
	}
	else
	{
		if ( searchnode ( val, n, k ) )
			cout << endl << "Key key already exists." << endl ;
		if ( adjust_val ( val, n -> child[k], p, c ) )
		{
			if ( n -> count < max )
			{
				fillnode ( p, c, n, k ) ;
				return 0 ;
			}
			else
			{
				split ( p, c, n, k, p, c ) ;
				return 1 ;
			}
		}
		return 0 ;
	}
}

int btree :: searchnode ( int val, btnode *n, int &pos )
{
	if ( val < n -> key[1] )
	{
		pos = 0 ;
		return 0 ;
	}
	else
	{
		pos = n -> count ;
		while ( ( val < n -> key[pos] ) && pos > 1 )
			pos-- ;
		if ( val == n -> key[pos] )
			return 1 ;
		else
			return 0 ;
	}
}	
	
void btree :: fillnode ( int val, btnode *c, btnode *n, int k )
{
	int i ;
	for ( i = n -> count ; i > k ; i-- )
	{
		n -> key[i + 1] = n -> key[i] ;
		n -> child[i + 1] = n -> child[i] ;
	}
	n -> key[k + 1] = val ;
	n -> child[k + 1] = c ;
	n -> count++ ;
}
void btree :: split ( int val, btnode *c, btnode *n,int k, int &y, btnode * &newnode )
{
	int i, mid ;
 
	if ( k <= min )
		mid = min ;
	else
		mid = min + 1 ;
 
	newnode = new btnode(d) ;
 
	for ( i = mid + 1 ; i <= max ; i++ )
	{
		(newnode ) -> key[i - mid] = n -> key[i] ;
		(newnode ) -> child[i - mid] = n -> child[i] ;
	}
 
	(newnode ) -> count = max - mid ;
	n -> count = mid ;
 
	if ( k <= min )
		fillnode ( val, c, n, k ) ;
	else
		fillnode ( val, c, newnode, k - mid ) ;
 
	y = n -> key[n -> count] ;
	(newnode ) -> child[0] = n -> child[n -> count] ;
	n -> count-- ;
}
void btree :: del ( int val )
{
	btnode * temp ;
 
	if ( ! delete_val ( val, root ) )
		cout << endl << "key " << val << " not found.\n" ;
	else
	{
		if ( root -> count == 0 )
		{
			temp = root ;
			root = root -> child[0] ;
			delete temp ;
		}
	}
}
int btree :: delete_val ( int val, btnode *t )
{
	int i ;
	bool flag ;
 
	if ( t == NULL )
		return 0 ;
	else
	{
		flag = searchnode ( val, t, i ) ;
		if ( flag )
		{
			if ( t -> child[i] )
			{
				copysucc ( t, i ) ;
				flag = delete_val ( t -> key[i], t -> child[i] ) ;
			}
			else
				clear ( t, i ) ;
		}
		else
			flag = delete_val ( val, t -> child[i] ) ;
		if ( t -> child[i] != NULL )
		{
			if ( t -> child[i] -> count < min )
				restore ( t, i ) ;
		}
		return flag ;
	}
}
void btree :: clear ( btnode *t, int k )
{
	int i ;
	for ( i = k + 1 ; i <= t -> count ; i++ )
	{
		t -> key[i - 1] = t -> key[i] ;
		t -> child[i - 1] = t -> child[i] ;
	}
	t -> count-- ;
}
void btree :: copysucc ( btnode *t, int i )
{
	btnode *temp = t -> child[i] ;
 
	while ( temp -> child[0] )
		temp = temp -> child[0] ;
 
	t -> key[i] = temp -> key[1] ;
}
void btree :: restore ( btnode *t, int i )
{
	if ( i == 0 )
	{
		if ( t -> child [1] -> count > min )
			leftshift ( t,1 ) ;
		else
			merge ( t,1 ) ;
	}
	else
	{
		if ( i == t -> count )
		{
			if ( t -> child[i - 1] -> count > min )
				rightshift ( t,i ) ;
			else
				merge ( t,i ) ;
		}
		else
		{
			if ( t -> child[i - 1] -> count > min )
				rightshift ( t,i ) ;
			else
			{
				if ( t -> child[i + 1] -> count > min )
					leftshift ( t,i + 1 ) ;
				else
					merge ( t,i ) ;
			}
		}
	}
}
void btree :: rightshift ( btnode *t,int k )
{
	int i ;
	btnode *temp ;
 
	temp = t -> child[k] ;
 
	for ( i = temp -> count ; i > 0 ; i-- )
	{
		temp -> key[i + 1] = temp -> key[i] ;
		temp -> child[i + 1] = temp -> child[i] ;
	}
 
	temp -> child[1] = temp -> child[0] ;
	temp -> count++ ;
	temp -> key[1] = t -> key[k] ;
	temp = t -> child[k - 1] ;
	t -> key[k] = temp -> key[temp -> count] ;
	t -> child[k] -> child [0] = temp -> child[temp -> count] ;
	temp -> count-- ;
}
void btree :: leftshift ( btnode *t,int k )
{
	btnode *temp ;
 
	temp = t -> child[k - 1] ;
	temp -> count++ ;
	temp -> key[temp -> count] = t -> key[k] ;
	temp -> child[temp -> count] = t -> child[k] -> child[0] ;
	temp = t -> child[k] ;
	t -> key[k] = temp -> key[1] ;
	temp -> child[0] = temp -> child[1] ;
	temp -> count-- ;
	for ( int i = 1 ; i <= temp -> count ; i++ )
	{
		temp -> key[i] = temp -> key[i + 1] ;
		temp -> child[i] = temp -> child[i + 1] ;
	}
}
void btree :: merge ( btnode *t,int k )
{
	btnode *temp1, *temp2 ;
	temp1 = t -> child[k] ;
	temp2 = t -> child[k - 1] ;
	temp2 -> count++ ;
	temp2 -> key[temp2 -> count] = t -> key[k] ;
	temp2 -> child[temp2 -> count] = t -> child[k-1] ;
	int i;
	for (i = 1 ; i <= temp1 -> count ; i++ )
	{
		temp2 -> count++ ;
		temp2 -> key[temp2 -> count] = temp1 -> key[i] ;
		temp2 -> child[temp2 -> count] = temp1 -> child[i] ;
	}
	for ( i = k ; i < t -> count ; i++ )
	{
		t -> key[i] = t -> key[i + 1] ;
		t -> child[i] = t -> child[i + 1] ;
	}
	t -> count-- ;
	delete temp1 ;
}
void btree :: show( )
{
	display ( root ) ;
}
void btree :: display ( btnode *t )
{
	int i;
	if (t != NULL )
	{
		for (i = 0 ; i < t -> count ; i++ )
		{
			display ( t -> child[i] ) ;
			cout << t -> key[i + 1] << "\t" ;
		}
		display ( t -> child[i] ) ;
	}
}
int main( )
{
	btree b(2) ;
	int arr[10] = { 27, 42, 22, 47, 32, 22, 51, 40, 13, 5} ;
	for ( int i = 0 ; i < 10 ; i++ )
		b.insert ( arr[i] ) ;
	b.show( ) ;
	cout<<endl<<endl<<endl;
	b.del ( 22 ) ;
	b.del ( 11 ) ;
	b.del ( 27 ) ;
	b.show( ) ;

}
