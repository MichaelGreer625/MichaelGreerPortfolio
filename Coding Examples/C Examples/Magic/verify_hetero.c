////////////////////////////////////////////////////////////////////////////////
// Main File:        verify_hetero.c
// This File:        verify_hetero.c
// Other Files:      
// Semester:         CS 354 Fall 2017
//
// Author:           Michael Greer
// Email:            mgreer2@madison.wisc.edu
// CS Login:         greer
//
/////////////////////////// OTHER SOURCES OF HELP //////////////////////////////
//                   fully acknowledge and credit all sources of help,
//                   other than Instructors and TAs.
//
// Persons:          Identify persons by name, relationship to you, and email.
//                   Describe in detail the the ideas and help they provided.
//
// Online sources:   avoid web searches to solve your problems, but if you do
//                   search, be sure to include Web URLs and description of 
//                   of any information you find.
////////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Structure representing Square
// size: dimension(number of rows/columns) of the square
// array: 2D array of integers
typedef struct _Square {
	int size;
	int **array;
} Square;

Square * construct_square(char *filename);
void insertion_sort(int* arr, int size);
int verify_hetero(Square * square);

int main(int argc, char *argv[])
{
	// Check input arguments to get filename
	if(argc != 2){
		printf("Incorrect amount of arguments, incorrect use of code.\n");
		exit(1);
	}
	// Construct square

	
	// Verify if it's a heterosquare and print true or false
	Square *square = construct_square(argv[1]);
	int test = verify_hetero(square);
	int i;
	for(i = square->size - 1; i >= 0; i--){
		free(*(square->array + i)); //This code here and the proceeding frees the pointers.
	}
	free(square->array);
	free(square);
	if (test){
		printf("true\n");
		return 1;
	}
	else {
		printf("false\n");
		return 0;
	}
}

/* construct_square reads the input file to initialize a square struct
 * from the contents of the file and returns the square.
 * The format of the file is defined in the assignment specifications
 */
Square * construct_square(char *filename)
{
	
	// Open and read the file
  FILE *fp;
  fp = fopen(filename, "r");
	//These are the assorted error handling.
  if(fp == NULL){
    printf("There was an error opening the file");
    return NULL;
  }

  Square *returnsquare = malloc(sizeof(Square));
	if(returnsquare == NULL){
		printf("Could not find space in the heap for square");
		exit(1);
	}
	
  char readstring[500];
  char *test;
	char *tokenpointer;
	char *count_s;
	// Read the first line to get the square size
	count_s = fgets(readstring, 500, fp);
	int count = atoi(count_s);
  returnsquare->size = count;
	
	// Initialize a new Square struct of that size
	int i;
	int j;
	int **returnarray;
	returnarray = malloc(sizeof(int*) * count);
	if(returnarray == NULL){
			printf("Could not find space in heap. Exiting");
			exit(1);		
	}
	for(i = 0; i < count; i = i + 1){
		*(returnarray + i) = malloc(sizeof(int) * count);
		if(*(returnarray + i) == NULL){
			printf("Could not find space in heap. Exiting");
			exit(1);
		}
	}
		
		
	
	
	
	
	// Read the rest of the file to fill up the square
	test = fgets(readstring, count*3, fp);
	for(i=0; test != NULL; i=i+1){
		tokenpointer = strtok(readstring, ",");
		for(j=0; tokenpointer != NULL; j=j+1){
			//Code here tokens the sting and places the values into a 2d returnarray.
			*(*(returnarray+i) + j) = atoi(tokenpointer);
			tokenpointer = strtok(NULL, ",");
		}	
		test = fgets(readstring, count*3, fp);		
	}

	//set the array in the structure equal to the return array.
	returnsquare->array = returnarray;
	fclose(fp);
	return returnsquare;
		
}

/* insertion_sort sorts the arr in ascending order
 *
 */
void insertion_sort(int* arr, int size)
{
  //basic insertion sort algorithum.
	int i = 1;
	int j;
	while (i<size){
		j = i;
		while((j>0) & (*(arr + j) < *(arr + j - 1))){
				int temp = *(arr + j);
				*(arr + j) = *(arr + j - 1); 
				*(arr + j - 1) = temp;
				j = j-1;
		}
		i++;	
	}
	
	
	
	
	
	
}

/* verify_hetero verifies if the square is a heterosquare
 * 
 * returns 1(true) or 0(false)
 */
int verify_hetero(Square * square)
{
	// Calculate sum of the following and store it in an array
	// all rows and cols
	// main diagonal
	// secondary diagonal
	int i;
	int j;
	int size = square->size;
	int **s_array = square->array;
	int sum = 0;
	int sum_array[(size * 2) + 2];
	
	
	//this does the rows
	for(i=0; i < size; i=i+1){
		for(j=0; j < size; j=j+1){
			sum += *(*(s_array+i) + j);
		}	
		//printf("%d", sum);
		*(sum_array + i) = sum;
		sum = 0;
	}
	//this does the columns.
	sum = 0;
	for(j=0; j < size; j=j+1){
		for(i=0; i < size; i=i+1){
			sum += *(*(s_array+i) + j);
		}	
		*(sum_array + j + size) = sum;
		sum = 0;
	}
	//this does a diagonal.
	sum = 0;
	for(i=0; i < size; i=i+1){
		for(j=0; j < size; j=j+1){
			if (i == j)
				sum += *(*(s_array+i) + j);
		}	
	}
	*(sum_array + size * 2) = sum;
	//this does the other diagonal.
	sum = 0;
	j = 0;
	for(i=size-1; i >= 0; i=i-1){
		sum += *(*(s_array+i) + j);
		j++;
		
	}
	*(sum_array + size * 2 + 1) = sum;

	//this sorts the array.
	// Pass the array to insertion_sort func
	insertion_sort(sum_array, (size * 2) + 2);

	

  // Check the sorted array for duplicates
	for(i = 0; i < ((size*2) + 2 -1); i++){
		if(*(sum_array + i) == *(sum_array + i + 1))
			return 0;
	}
	return 1;

}
