#include<iostream>
#include<fstream>
using namespace std;
class node
{
    int keys[4];
    node *child[5];
    int fill;
    node *parent;
    friend class btree;
    public:
	node();
};
node::node()
{
    for(int i=0;i<4;i++)
       keys[i]=0;
    fill=0;
    for( int i=0;i<5;i++)
	child[i]=NULL;
    parent=NULL;
}
class  btree
{
    node *root;
    public:
	btree()
	{
	     root=NULL;
	}
	void makeroot()
	{
	     int x;
	     root=new node;
	     cout<<"Please enter 4 entries for the root:";
	     for(int i=0;i<4;i++)
	     {
		  cout<<"Enter the "<<i+1<<" value:";
		  cin>>x;
		  if(i==0)
		      root->keys[0]=x;
		  else
		      sortins(root,x);
		  root->fill++;
	     }
	     for(int i=0;i<5;i++)
	     {
		 root->child[i]=new node;
		 root->child[i]->parent=root;
	     }

	}
	void sortins(node *tmp,int x)
	{
	     int i=0;int j;
	     while(tmp->keys[i]<x && i<tmp->fill)
		 i++;
	     if(tmp->fill==i)
		 tmp->keys[i]=x;
	     else
	     {
		 for(int j=tmp->fill;j>i;j--)
		 {
		    tmp->keys[j]=tmp->keys[j-1];
		    tmp->child[j+1]=tmp->child[j];
		 }
		 tmp->keys[j]=x;
		 tmp->child[j+1]=tmp->child[j];
	     }
	}
	void accept()
	{
	     int x;
	     cout<<"Enter the value to be inserted:";
	     cin>>x;
	     node *tmp;
	     tmp=root;
	     int fil=0;
	     do
	     {
		 while(tmp->keys[fil]<x && fil<tmp->fill)
		       fil++;
		 tmp=tmp->child[fil];
	     }while(tmp->child[0]!=NULL);
	     insert(tmp,x,NULL,NULL);
	}
	void insert(node *tmp,int x,node *lc,node *rc)
	{
	     node *par=tmp->parent;
	     if(tmp->fill<4)
	     {
		int i=0;
		while(tmp->keys[i]<x && i<tmp->fill)
		     i++;
		tmp->child[i]=rc;
		sortins(tmp,x);
		tmp->child[i]=lc;
		tmp->fill++;
	     }
	     else if(tmp==root)
	     {
		 split(tmp,x,lc,rc);
	     }
	     else
	     {
		 int check=0;
		 node *tmp1;
		 int fil=0;
		 int re,re1;
		 while(par->keys[fil]<x && fil<par->fill)
		       fil++;
		 if(fil!=0)
		 {
		      if(par->child[fil-1]->fill!=4)
		      {
			    int ins;
			    tmp1=par->child[fil-1];
			    if(x<tmp->keys[0])
			    {
				 ins=tmp->keys[0];
				 re=x;
			    }
			    else
			    {
				 re=tmp->keys[0];
				 ins=x;
			    }
			    re1=par->keys[fil-1];
			    par->keys[fil-1]=re;
			    re=tmp1->fill;
			    tmp1->keys[re]=re1;
			    tmp1->fill++;
			    int i=1;
			    while(tmp->keys[i]<ins && i<tmp->fill)
			    {
				tmp->keys[i-1]=tmp->keys[i];
				i++;
			    }
			    tmp->keys[i-1]=ins;
			    check=1;
		      }
		      else;
		 }
		 if(fil!=4 && !check)
		 {
		     int ins;
		     if(par->child[fil+1]->fill!=4)
		      {
			    tmp1=par->child[fil+1];
			    if(x>tmp->keys[3])
			    {
				 ins=tmp->keys[3];
				 re=x;
			    }
			    else
			    {
				 re=tmp->keys[3];
				 ins=x;
			    }
			    re1=par->keys[fil];
			    par->keys[fil]=re;
			    re=tmp1->fill;
			    while(re>0)
			    {
				  tmp1->keys[re]=tmp1->keys[re-1];
				  re--;
			    }
			    tmp1->keys[0]=re1;
			    tmp1->fill++;
			    tmp->fill--;
			    sortins(tmp,ins);
			    tmp->fill++;
			    check=1;
		       }
		 }
		 if(!check)
		 {
		     split(tmp,x,lc,rc);
		 }
	     }
	}
	void split(node *tmp,int x,node *c1,node *c2)
	{
	     node *gc1,*gc2;
	     node *t[2];
	     gc1=new node;
	     gc2=new node;
	     int a[5];
	     int i=0,j;
	     while(tmp->keys[i]<x && i<4)
	     {
		 a[i]=tmp->keys[i];
		 i++;
	     }
	     a[i]=x;
	     j=i;
	     i++;
	     while(i<5)
	     {
		 a[i]=tmp->keys[i-1];
		 i++;
	     }
	  if(c1!=NULL || c2!=NULL)
	  {
	     if(j==0)
	     {
		 gc1->child[0]=c1;
		 gc1->child[1]=c2;
		 gc1->child[2]=tmp->child[1];
		 gc2->child[0]=tmp->child[2];
		 gc2->child[1]=tmp->child[3];
		 gc2->child[2]=tmp->child[4];
	     }
	     else if(j==1)
	     {
		 gc1->child[0]=tmp->child[0];
		 gc1->child[1]=c1;
		 gc1->child[2]=c2;
		 gc2->child[0]=tmp->child[2];
		 gc2->child[1]=tmp->child[3];
		 gc2->child[2]=tmp->child[4];
	     }
	     else if(j==2)
	     {
		 gc1->child[0]=tmp->child[0];
		 gc1->child[1]=tmp->child[1];
		 gc1->child[2]=c1;
		 gc2->child[0]=c2;
		 gc2->child[1]=tmp->child[3];
		 gc2->child[2]=tmp->child[4];
	     }
	     else if(j==3)
	     {
		 gc1->child[0]=tmp->child[0];
		 gc1->child[1]=tmp->child[1];
		 gc1->child[2]=tmp->child[2];
		 gc2->child[0]=c1;
		 gc2->child[1]=c2;
		 gc2->child[2]=tmp->child[4];
	     }
	     else if(j==4)
	     {
		 gc1->child[0]=tmp->child[0];
		 gc1->child[1]=tmp->child[1];
		 gc1->child[2]=tmp->child[2];
		 gc2->child[0]=tmp->child[4];
		 gc2->child[1]=c1;
		 gc2->child[2]=c2;
	     }
	     if(j<2)
		 c1->parent=c2->parent=gc1;
	     else if(j==2)
	     {
		 c1->parent=gc1;
		 c2->parent=gc2;
	     }
	     else
		 c1->parent=c2->parent=gc2;
	 }
	     gc1->fill=2;
	     gc2->fill=2;
	     gc1->keys[0]=a[0];
	     gc1->keys[1]=a[1];
	     gc2->keys[0]=a[3];
	     gc2->keys[1]=a[4];
	     if(tmp==root)
	     {
		  root=new node;
		  root->keys[0]=a[2];
		  root->fill++;
		  root->child[0]=gc1;
		  root->child[0]->parent=root;
		  root->child[1]=gc2;
		  root->child[1]->parent=root;
		  gc1->parent=root;
		  gc2->parent=root;
	     }
	     else
	     {
		  insert(tmp->parent,a[2],gc1,gc2);
	     }
	}
	void dis()
	{
	     for(int i=0;i<root->fill;i++)
		   cout<<root->keys[i];
	     cout<<"\n";
	     for(i=0;i<root->child[0]->fill;i++)
		   cout<<root->child[0]->keys[i];
	     cout<<"\n";
	     for(i=0;i<root->child[1]->fill;i++)
		   cout<<root->child[1]->keys[i];
	     cout<<"\n";
	    for(i=0;i<root->child[0]->child[0]->fill;i++)
		   cout<<root->child[0]->child[0]->keys[i];
	     cout<<"\n";
	     for(i=0;i<root->child[0]->child[1]->fill;i++)
		   cout<<root->child[0]->child[1]->keys[i];
	     cout<<"\n";
	     for(i=0;i<root->child[0]->child[2]->fill;i++)
		   cout<<root->child[0]->child[2]->keys[i];

	}
};
void main()
{
    btree t;
    t.makeroot();
    for(int i=0;i<10;i++)
       t.accept();
    t.dis();
}

