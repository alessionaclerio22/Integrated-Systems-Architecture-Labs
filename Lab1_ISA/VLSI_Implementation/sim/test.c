#include<stdio.h>
#include<stdlib.h>

int main(){
	FILE *fp_output;
	FILE *fp_results;
	FILE *fp_test;
	int r, s;
	
	fp_output = fopen("output.txt", "r");
	fp_results = fopen("results_VHDL.txt", "r");
	fp_test    = fopen("test.txt", "w");
	
	
	fscanf(fp_output, "%d", &s);
	fscanf(fp_results, "%d", &r);
	do{	
		fprintf(fp_test,"%d(r) -%d(s) = %d\n", r, s, r-s);
		fscanf(fp_output, "%d", &s);
		fscanf(fp_results, "%d", &r);
	} while (!feof(fp_output));
	
	fclose(fp_output);
	fclose(fp_results);
	fclose(fp_test);
}