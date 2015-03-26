#include<stdio.h>
#include<string.h>


FILE * file_print_float_array(FILE *fp, float *array, int length){
	int i;
	
	for(i=0;i<length;i++){
		fprintf(fp, "%f, ", array[i]);
	}
	
	return fp;
}



FILE * file_print_uint2_array(FILE *fp, unsigned short int *array, int length){
	int i;
	
	for(i=0;i<length;i++){
		fprintf(fp, "%d, ", array[i]);
	}
	
	return fp;
}


FILE * file_print_uint4_array(FILE *fp, unsigned long int *array, int length){
	int i;
	
	for(i=0;i<length;i++){
		fprintf(fp, "%d, ", array[i]);
	}
	
	return fp;
}


int main(int argc, char *argv[]){
	FILE *infile, *outfile;
	int cnt,i;
	char byte1, byte1_4[4], outfilename[1000];
	unsigned short int uint2, uint2_12[12], uint2_14[14];
	unsigned long int uint4, N_records, id, uint4_4[4];
	float float4, lat, lon;
	float float4_22[22];
	
	//infile = fopen("C:\\Users\\Constantinos\\Desktop\\smos\\SM_OPER_MIR_OSUDP2_20140426T030206_20140426T035525_550_001_1.DBL", "rb");
	infile = fopen(argv[1], "rb");
	if(!infile){
		printf("Error: Cannot read input file!");
		return 1;
	}
	
	strcpy(outfilename, argv[1]);
	strcat(outfilename, ".TXT\0");
	
	outfile = fopen(outfilename, "w");
	if(!outfile){
		printf("Error: Cannot create output file!");
		return 1;
	}
	
	fread(&N_records, sizeof(N_records), 1, infile);
	printf("N_records = %d\n", N_records);
	
	for(i=0;i<N_records;i++){
		fread(&id, sizeof(id), 1, infile);
		fread(&lat, sizeof(lat), 1, infile);
		fread(&lon, sizeof(lon), 1, infile);
		fprintf(outfile, "%d, %f, %f, ", id, lat, lon);
		
		fread(float4_22, sizeof(float4_22), 1, infile);
		outfile = file_print_float_array(outfile, float4_22, 22);
		
		fread(uint4_4, sizeof(uint4_4), 1, infile);
		outfile = file_print_uint4_array(outfile, uint4_4, 4);
		
		fread(uint2_12, sizeof(uint2_12), 1, infile);
		outfile = file_print_uint2_array(outfile, uint2_12, 12);
		
		fread(byte1_4, sizeof(byte1_4), 1, infile);
		fprintf(outfile, "%d, %d, %d, %d, ", byte1_4[0], byte1_4[1], byte1_4[2], byte1_4[3]);
		
		fread(uint2_14, sizeof(uint2_14), 1, infile);
		outfile = file_print_uint2_array(outfile, uint2_14, 14);
		
		fread(uint4_4, sizeof(uint4_4), 1, infile);
		outfile = file_print_uint4_array(outfile, uint4_4, 4);
		
		fread(&uint2, sizeof(uint2), 1, infile);
		fprintf(outfile, "%d\n", uint2);
	}

	fclose(infile);
	fclose(outfile);
	return 0;
}


