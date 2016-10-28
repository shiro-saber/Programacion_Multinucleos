#include <stdio.h>
//#include <conio.h>
#include <math.h>
#include <string.h>
int imax=57;
int jmax=57;
double Lr=1.0;
double Lz=1.0;
double dr=Lr/(imax-2);
double dz=Lz/(jmax-2);
int iter=0; //To keep track of iteration
double rho=7750; //Physical parameters
double cp=500;
double kk=16.2;
double dt=0.1;
int ptime=0;
int i,j;
double alpha=kk/(rho*cp);
void MAKE_ARRAY();
void SET_GEOMETRY();
void INITIAL_CONDITION();
void BC();
void FLUX();
void UPDATE();
void TEMPERATURE();
double UNSTEADINESS();
void printit(int);
double **r,**z,**T,**qr,**qz,**TOLD,**rr,**rz,**Qr,**Qz;
int main(int argc,char *argv[])
{
	int iter=0;
	double unstead=1;
	MAKE_ARRAY();
	SET_GEOMETRY();
	INITIAL_CONDITION();
	printit(0);
	while(unstead>=0.0001 && iter<=300000) //while(unstead>=0.0001)
	{
		unstead=0;
		iter++;
		BC();
		FLUX();
		UPDATE();
		TEMPERATURE();
		if(iter%1000 == 0)
		{
		printit(iter);
		}
		unstead=UNSTEADINESS();
	//printf("\n Iter=%d Unsteadiness=%f",iter,unstead);
	}
	
	printit(1);
	return 0;
}
void MAKE_ARRAY()
{
	r=new double*[jmax];
	z=new double*[jmax];
	T=new double*[jmax];
	TOLD=new double*[jmax];
	qr=new double*[jmax-1];
	qz=new double*[jmax-1];
	rr=new double*[jmax-1];
	rz=new double*[jmax-1];
	Qr=new double*[jmax-2];
	Qz=new double*[jmax-2];
	for(j=0;j<jmax;j++)
	{
		r[j]=new double[imax];
		z[j]=new double[imax];
		T[j]=new double[imax];
		TOLD[j]=new double[imax];
	}
	for(j=0;j<jmax-1;j++)
	{
		qr[j]=new double[imax-1];
		qz[j]=new double[imax-1];
		rr[j]=new double[imax-1];
		rz[j]=new double[imax-1];
	}
	for(j=0;j<jmax-2;j++)
	{
		Qr[j]=new double[imax-2];
		Qz[j]=new double[imax-2];
	}
}
void SET_GEOMETRY()
{
	for(j=0;j<jmax-1;j++)
	{
		for(i=0;i<imax-1;i++)
		{
			rr[j][i]=i*dr;
			rz[j][i]=j*dz;
		}
	}
	for(j=0;j<jmax;j++)
	{
		for(i=0;i<imax;i++)
		{
			if(j!=0 && j!=1 && j!=jmax-1)
			{
				z[j][i]=z[j-1][i]+dz;
			}
			else
			{
				if(j==0)
				{
					z[j][i]=0;
				}
				else if(j==1)
				{
					z[j][i]=dz/2;
				}
				else if(j==jmax-1)
				{
					z[j][i]=Lz;
				}
			}
		}
	}
	for(j=0;j<jmax;j++)
	{
		for(i=0;i<imax;i++)
		{
			if(i!=0 && i!=1 && i!=imax-1)
			{
				r[j][i]=r[j][i-1]+dr;
			}
			else
			{
				if(i==0)
				{
					r[j][i]=0;
				}
				else if(i==1)
				{
					r[j][i]=dr/2;
				}
				else if(i==imax-1)
				{
					r[j][i]=Lr;
				}
			}
		}
	}
}
void INITIAL_CONDITION()
{
	for(j=0;j<jmax;j++)
	{
		for(i=0;i<imax;i++)
		{
			T[j][i]=0;
		}
	}
	for(j=0;j<jmax-1;j++)
	{
		for(i=0;i<imax-1;i++)
		{
			qr[j][i]=0;
			qz[j][i]=0;
		}
	}
	for(j=0;j<jmax-2;j++)
	{
		for(i=0;i<imax-2;i++)
		{
			Qr[j][i]=0;
			Qz[j][i]=0;
		}
	}
}
void BC()
{
	for(j=0;j<jmax;j++)
	{
		T[j][0]=T[j][1];
		T[j][imax-1]=200;
	}
	for(i=0;i<imax;i++)
	{
		T[0][i]=100;
		T[jmax-1][i]=300;
	}
}
void FLUX()
{
	for(j=0;j<jmax-1;j++)
	{
		for(i=0;i<imax-1;i++)
		{
			if(i!=0 && i!=imax-1)
			{
				qr[j][i]=kk*rr[j][i]*(T[j][i+1]-T[j][i])/dr;
			}
			else
			{
				qr[j][i]=(2*kk*rr[j][i]*(T[j][i+1]-T[j][i]))/dr;
			}
		}
	}
	for(j=0;j<jmax-1;j++)
	{
		for(i=0;i<imax-1;i++)
		{
			if(j!=0 && j!=jmax-1)
			{
				qz[j][i]=kk*(T[j+1][i]-T[j][i])/dz;
			}
			else
			{
				qz[j][i]=(2*kk*(T[j+1][i]-T[j][i]))/dz;
			}
		}
	}
}
void UPDATE()
{
	for(j=0;j<jmax;j++)
	{
		for(i=0;i<imax;i++)
		{
			TOLD[j][i]=T[j][i];
		}
	}
}
void TEMPERATURE()
{
	for(j=1;j<jmax-1;j++)
	{
		for(i=1;i<imax-1;i++)
		{
			Qr[j-1][i-1]=qr[j][i]-qr[j][i-1];
			Qz[j-1][i-1]=qz[j][i]-qz[j-1][i];
		}
	}
	for(j=1;j<jmax-1;j++)
	{
		for(i=1;i<imax-1;i++)
		{
			T[j][i]=TOLD[j][i]+((dt/(rho*cp*dr*r[j][i]))*Qr[j-1][i-1])+((dt/(rho*cp*dz))*Qz[j-1][i-1]);
		}
	}
}
double UNSTEADINESS()
{
	double sum=0;
	int cnt=0;
	for(j=1;j<jmax-1;j++)
	{
		for(i=1;i<imax-1;i++)
		{
			cnt+=1;
			sum+=fabs(T[j][i]-TOLD[j][i]);
		}
	}
	sum=sum/cnt;
	sum=sqrt(sum);
	return sum;
}
void printit(int iter)
{
	char tem[80]={0};
	int aa;
	char ch[10];
	aa = sprintf(ch, "%d",ptime);
	strcat(tem,ch);
	strcat(tem,".dat");
	FILE *fs;
	fs=fopen(tem,"w");
	for(i=0;i<imax;i++)
	{
		for(j=0;j<jmax;j++)
		{
			if(i==0&&j==0)
			{
			fprintf(fs,"VARIABLES = \"X\", \"Y\", \"T\"\n");
			fprintf(fs,"ZONE I=%d, J=%d, F=POINT",imax,jmax);	
			}
			fprintf(fs,"\n%0.6f %0.6f %0.6f ",r[j][i],z[j][i],T[j][i]);
		}
	}
	fclose(fs);
	ptime++;
}