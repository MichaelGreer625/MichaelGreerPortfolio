////////////////////////////////////////////////////////////////////////////////
// Main File:        generate_magic.c
// This File:        generate_magic.c
// Other Files:      generate_magic.c
//									 verify_hetero.c
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

// Structure representing Square
// size: dimension(number of rows/columns) of the square
// array: 2D array of integers
typedef struct _Square {
	int size;
	int **array;
} Square;

int get_square_size();
Square * generate_magic(int size);
void write_to_file(Square * square, char *filename);

int main(int argc, char *argv[])
{

	// Check input arguments to get filename and do error handling.
	if(argc != 2){
		printf("Incorrect amount of arguments, incorrect use of code.\n");
		exit(1);
	}
	char *file = *(argv + 1);
	// Get size from user
	int size = get_square_size();
	
	// Generate the magic square
	Square *square_pointer = generate_magic(size);
	
	
	// Write the square to the output file
	write_to_file(square_pointer, file);
	
	//This frees up the memory in the heap.
	for(int i = square_pointer->size - 1; i >= 0; i--){
		free(*(square_pointer->array + i));
	}
	free(square_pointer->array);
	free(square_pointer);
	return 0;
}

/* get_square_size prompts the user for the magic square size
 * checks if it is an odd number >= 3 and returns the number
 */
int get_square_size()
{
	//promp the user.
	printf("Enter an odd number greater than or equal to 3\n");
	char numberarray[7];
	fgets(numberarray, 8, stdin);
	int number = atoi(numberarray);
	//This does the error handling.
	if (number < 3 || number%2 == 0){
		printf("Not a odd number greater than or equal to 3");
		exit(1);
	}
	return number;
}

/* generate_magic constructs a magic square of size n
 * using the Siamese algorithm and returns the Square struct
 */
Square * generate_magic(int n)
{
	
	
	int i;
	int j;
	int **returnarray;

	//Create the space in the heap.
	Square *returnSquare = malloc(sizeof(Square));
	if(returnSquare == NULL){
		printf("Could not find space in the heap for square");
		exit(1);
	}
	
	returnarray = malloc(sizeof(int*) * n);
	if(returnarray == NULL){
			printf("Could not find space in heap. Exiting");
			exit(1);		
	}
	for(i = 0; i < n; i = i + 1){
		*(returnarray + i) = calloc(n, sizeof(int));
		if(*(returnarray + i) == NULL){
			printf("Could not find space in heap. Exiting");
			exit(1);
		}
	}
	
	i = n - 1 - 1; // this is the second to last row(we will increment to the right row(last row) sortly. 
	j = n - ((n/2) + 1) - 1; //this is column before the middle column, we will increment to the correct column shortly.
	for(int k = 1; k <= n * n; k++){
		
		int l = (i+1)%n; //this is the incrementing to the correct column.
		int m = (j+1)%n;
		//this is how this logic works:
		//l and m are the coordinates of the next location in the 2d array after going down and to the right.
		//i and j are the coordinates of the last location writen into the 2d array.
		if(*(*(returnarray + l) + m) == 0){
			*(*(returnarray + l) + m) = k;
			i = l;
			j = m;
			continue;
		}	
		
		(i == 0) ? (i = n-1) : (i = i-1); // this code here is for wrap around.
		*(*(returnarray + i) + j) = k;
		
	}
	//set the values of the returnsquare and return the square.
	returnSquare->size = n;
	returnSquare->array = returnarray;
	return returnSquare;
}

/* write_to_file opens up a new file(or overwrites the existing file)
 * and writes out the square in the format expected by verify_hetero.c
 */
void write_to_file(Square * square, char *filename)
{
	FILE *fp = fopen(filename, "w");
	//This does the error handling.
	if(fp == NULL){
		printf("Could not open file for writing");
		exit(1);
	}
	int size = square->size;
	int **a = square->array;
	fprintf(fp, "%d\n", size);
	for(int i = 0; i < size; i++){
		for(int j = 0; j < size; j++){
			(j != size - 1) ? fprintf(fp, "%d,", *(*(a+i)+j)) : fprintf(fp, "%d\n", *(*(a+i)+j)); //interates through and writes to file.
		}
	}
	fclose(fp);
}
