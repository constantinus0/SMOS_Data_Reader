// OUT = eqn_readSmosDBLx(filename), where "filename" is a string with the 
// name of the DBL file to be read, and OUT is a MATLAB array of doubles, 
// with as many rows as there are records in the data file and 12 columns.
// Columns correspond to the grid point id, latitude, longitude, time, SSS1, 
// sigmaSSS1, SSS2, sigmaSSS2, SSS3, sigmaSSS3, SST and sigmaSST. SSS stands
// for Sea Surface Salinity and the following number denotes the number of 
// the model used, where SST stands for Sea Surface Temperature.

#include <stdio.h>
#include <string.h>
#include "mex.h"

FILE *infile;
unsigned long int N_records, id;
float lat, lon, time, SSS, sigmaSSS, WS, sigmaWS;

int nChars;
char *s;
long int i, j, n;
double *ptr;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
    nChars = mxGetNumberOfElements(prhs[0]);
    s = (char *)malloc(nChars*sizeof(char) + 1);
    mxGetString(prhs[0], s, nChars*sizeof(char) + 1);
    mexPrintf("filename is: '%s'\n", s);
    
    
    
    infile = fopen(s, "rb");
	if(!infile){
		printf("Error: Cannot read input file!");
		return 1;
	}
	
	fread(&N_records, sizeof(N_records), 1, infile);
	printf("N_records = %d\n", N_records);
    
    // Prepare MATLAB output
    plhs[0] = mxCreateDoubleMatrix(N_records, 8, mxREAL);
    ptr = mxGetPr(plhs[0]);
	
	for(i=0;i<N_records;i++){
		fread(&id, 4, 1, infile);
		fread(&lat, 4, 1, infile);
		fread(&lon, 4, 1, infile);
		//fprintf(outfile, "%d, %f, %f, ", id, lat, lon);
        
        ptr[i] = (double) id;
        ptr[1*N_records + i] = (double) lat;
        ptr[2*N_records + i] = (double) lon;
        
        fseek(infile, 4, SEEK_CUR);
        
        fread(&time, 4, 1, infile);
        
        ptr[3*N_records + i] = (double) time;
        
        // SSS & their st.dev.
//         for(j=0;j<3;j++){
//             fread(&SSS, 4, 1, infile);
//             fread(&sigmaSSS, 4, 1, infile);
//             
//             ptr[(4+2*j)*N_records + i] = (double) SSS;
//             ptr[(5+2*j)*N_records + i] = (double) sigmaSSS;
//         }
        
        // OR ignore the SSS related values
        fseek(infile, 32, SEEK_CUR);
        
        // get WS
        fread(&WS, 4, 1, infile);
        fread(&sigmaWS, 4, 1, infile);

        ptr[4*N_records + i] = (double) SSS;
        ptr[5*N_records + i] = (double) sigmaSSS;
        
        // get SST (use the variable for SSS)
        fread(&SSS, 4, 1, infile);
        fread(&sigmaSSS, 4, 1, infile);

        ptr[6*N_records + i] = (double) SSS;
        ptr[7*N_records + i] = (double) sigmaSSS;
        
        fseek(infile, 122, SEEK_CUR);
	}

	fclose(infile);

    return 0;
}

