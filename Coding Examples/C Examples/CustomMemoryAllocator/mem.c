////////////////////////////////////////////////////////////////////////////////
// Main File:        mem.c
// This File:        mem.c
// Other Files:      mem.c
//									 mem.h
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
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <string.h>
#include "mem.h"
//these commands get the assorted values from the header
#define GET_SIZE(blk_pointer) ((int)((*(int *)(blk_pointer)) & ~0x7))
#define GET_ALLOC(blk_pointer) ((int)((*(int *)(blk_pointer)) & 0x01))
#define GET_PREV(blk_pointer) (((int)((*(int *)(blk_pointer)) & 0x02)) >> 1)

//this command places a int value into the memory location starting at blk_pointer.
#define PLACE(blk_pointer, size, prev, alloc) (*(int *)(blk_pointer) = ((size)|(prev<<1)|alloc))
	

//given the pointer to the load, calculate the address of the pointer.
#define GET_HDR(load_pointer)	((int *)((char *)load_pointer - 4))
//given the pointer to the load, calculate the address of the pointer.
#define GET_FOOTER(load_pointer)	((int *)((char *)load_pointer - 8 + GET_SIZE(GET_HDR(load_pointer))))
	
	//given the pointer to the load, calculate the address of the next blocks load.
//#define GET_NEXTBLK(load_pointer) = ((char *)(load_pointer) + GET_SIZE(GET_HDR(load_pointer))
#define GET_NEXTBLK(blk_pointer) ((int *)((char *)(blk_pointer) + GET_SIZE(blk_pointer)))
#define GET_PREVSIZE(load_pointer) GET_SIZE((int *)((char *)load_pointer - 8))

/*
 * This structure serves as the header for each allocated and free block
 * It also serves as the footer for each free block
 * The blocks are ordered in the increasing order of addresses 
 */
typedef struct blk_hdr {   	    

    int size_status;
  
    /*
    * Size of the block is always a multiple of 8
    * => last two bits are always zero - can be used to store other information
    *
    * LSB -> Least Significant Bit (Last Bit)
    * SLB -> Second Last Bit 
    * LSB = 0 => free block
    * LSB = 1 => allocated/busy block
    * SLB = 0 => previous block is free
    * SLB = 1 => previous block is allocated/busy
    * 
    * When used as the footer the last two bits should be zero
    */

    /*
    * Examples:
    * 
    * For a busy block with a payload of 20 bytes (i.e. 20 bytes data + an additional 4 bytes for header)
    * Header:
    * If the previous block is allocated, size_status should be set to 27
    * If the previous block is free, size_status should be set to 25
    * 
    * For a free block of size 24 bytes (including 4 bytes for header + 4 bytes for footer)
    * Header:
    * If the previous block is allocated, size_status should be set to 26
    * If the previous block is free, size_status should be set to 24
    * Footer:
    * size_status should be 24
    * 
    */

} blk_hdr;

/* Global variable - This will always point to the first block
 * i.e. the block with the lowest address */
blk_hdr *first_block = NULL;

// Global variable - Total available memory 
int total_mem_size = 0;

/* 
 * Function for allocating 'size' bytes
 * Returns address of allocated block on success 
 * Returns NULL on failure 
 * Here is what this function should accomplish 
 * - Check for sanity of size - Return NULL when appropriate 
 * - Round up size to a multiple of 8 
 * - Traverse the list of blocks and allocate the best free block which can accommodate the requested size 
 * - Also, when allocating a block - split it into two blocks
 * Tips: Be careful with pointer arithmetic 
 */
void* Mem_Alloc(int size) {   	   
  
	int found = 1;
	int previous = 1;
	int atleastonebestfit = 0;
	int *bestfit = NULL;
	
	
	if(size <= 4)
		size = 8;
	else
		size = ((size+11)/8) * 8;

	int *searchpointer = (int *)first_block;
	
	while(((char *)searchpointer - (char *)first_block) <  (total_mem_size - 4 - 8)){
			
		found = 1;	
		while(found){
			while(GET_ALLOC(searchpointer)){
				previous = GET_ALLOC(searchpointer);
				searchpointer = GET_NEXTBLK(searchpointer);
			}
			if(GET_SIZE(searchpointer) < size){
				previous = GET_ALLOC(searchpointer);
				searchpointer = GET_NEXTBLK(searchpointer);
			}
			else
				found = 0;
			
			//printf("***%d****", (int)(((char *)searchpointer - (char *)first_block) >  (total_mem_size - 4 - 8))
			if((((char *)searchpointer + size - (char *)first_block) >  (total_mem_size - 4 - 8)) && (bestfit == NULL)){  
			//above logic is that the amount of bytes between the first and the next
			//block ((char *)searchpointer + size)
			//needs to be less than or equal to total_mem_size minus a four byte offset for the initial
			//block header at the start of our heap, minus 8 bytes(which is the smallest block
			//we can allocate). (total_mem_size - 4 - 8) marks the last-most block that could
			//possibly be allocated given any total_mem_size. If block cannot be found past this 
			//point, then we cannot allocate memory for that block size.
				//printf("Could not allocate the memory.\n");
				return NULL;
			}
		}
			
		//Assorted checks here that are self explanitory.
		if(!atleastonebestfit){
			bestfit = searchpointer;
			atleastonebestfit = 1;
			searchpointer = GET_NEXTBLK(searchpointer);
			continue;
		}
		if(GET_SIZE(bestfit) > GET_SIZE(searchpointer))
			bestfit = searchpointer;
		
		searchpointer = GET_NEXTBLK(searchpointer);
		
	}
	//check if there is a multiple of double word after the size. This means split
	
	// if there are more than 8 bytes after the payload required, then split;
	if((GET_SIZE(bestfit) - size) >=  8){
		PLACE((char *)bestfit + size, GET_SIZE(bestfit) - size, 1, 0);
		PLACE((char *)bestfit + GET_SIZE(bestfit) - 4, GET_SIZE(bestfit) - size, 1, 0);		
		PLACE(bestfit, size, previous, 1);		
	}
	else
		PLACE(bestfit, size, previous, 1);

	
	
	
	
	
    return ((char *)bestfit + 4);
}

/* 
 * Function for freeing up a previously allocated block 
 * Argument - ptr: Address of the block to be freed up 
 * Returns 0 on success 
 * Returns -1 on failure 
 * Here is what this function should accomplish 
 * - Return -1 if ptr is NULL or not within the range of memory allocated by Mem_Init()
 * - Return -1 if ptr is not 8 byte aligned or if the block is already freed
 * - Mark the block as free 
 * - Coalesce if one or both of the immediate neighbours are free 
 */
int Mem_Free(void *ptr) {   	   
		int prev_al = GET_PREV(GET_HDR(ptr));
		int next_al = GET_ALLOC(GET_NEXTBLK(GET_HDR(ptr)));
		int size = GET_SIZE(GET_HDR(ptr));
		int sizenextblk = GET_SIZE(GET_NEXTBLK(GET_HDR(ptr)));
		int prev_alspecial;
	//this here tests for all of the coal cases. 
	//1.Set the next block prev bit to 0
	//2.Place a new header
	//3.Place a new footer.
		if(prev_al && next_al){
			PLACE(GET_NEXTBLK(GET_HDR(ptr)), sizenextblk, 0, 1);
			PLACE(GET_HDR(ptr), size, prev_al, 0);
			PLACE(GET_FOOTER(ptr), size, prev_al, 0);
			return 0;
		}
		else if(prev_al && !next_al){
			size += sizenextblk;
			
			PLACE((char *)GET_NEXTBLK(GET_HDR(ptr)) + sizenextblk, GET_SIZE((char *)GET_NEXTBLK(GET_HDR(ptr)) + sizenextblk), 0, 1);
			PLACE((char *)GET_FOOTER(ptr) + sizenextblk, size, prev_al, 0);
			PLACE(GET_HDR(ptr), size, prev_al, 0);
			return 0;
			
		}
		else if(!prev_al && next_al){
			size += GET_PREVSIZE(ptr);
			prev_alspecial = GET_PREV((char *)GET_HDR(ptr) - GET_PREVSIZE(ptr));
			
			PLACE(GET_NEXTBLK(GET_HDR(ptr)), sizenextblk, 0, 1);
			PLACE(GET_FOOTER(ptr), size, prev_alspecial, 0);
			PLACE((char *)GET_HDR(ptr) - GET_PREVSIZE(ptr), size, prev_alspecial, 0);
			return 0;
			
		}
		else{
			size += GET_PREVSIZE(ptr) + sizenextblk;
			prev_al = GET_PREV((char *)GET_HDR(ptr) - GET_PREVSIZE(ptr));
			
			PLACE((char *)GET_NEXTBLK(GET_HDR(ptr)) + sizenextblk, GET_SIZE((char *)GET_NEXTBLK(GET_HDR(ptr)) + sizenextblk), 0, 1);
			PLACE((char *)GET_FOOTER(ptr) + sizenextblk, size, prev_al, 0);
			PLACE((char *)GET_HDR(ptr) - GET_PREVSIZE(ptr), size, prev_al, 0);
			return 0;
		}
	
	
	
	
	
	
	
	
    return -1;
}

/*
 * For testing purpose
 * To verify whether a block is double word aligned
 */
void *start_pointer;

/*
 * Function used to initialize the memory allocator
 * Not intended to be called more than once by a program
 * Argument - sizeOfRegion: Specifies the size of the chunk which needs to be allocated
 * Returns 0 on success and -1 on failure 
 */
int Mem_Init(int sizeOfRegion) {   	   
    int pagesize;
    int padsize;
    int fd;
    int alloc_size;
    void* space_ptr;
    static int allocated_once = 0;
  
    if(0 != allocated_once) {
        fprintf(stderr,"Error:mem.c: Mem_Init has allocated space during a previous call\n");
        return -1;
    }
    if(sizeOfRegion <= 0) {
        fprintf(stderr,"Error:mem.c: Requested block size is not positive\n");
        return -1;
    }

    // Get the pagesize
    pagesize = getpagesize();

    // Calculate padsize as the padding required to round up sizeOfRegion to a multiple of pagesize
    padsize = sizeOfRegion % pagesize;
    padsize = (pagesize - padsize) % pagesize;

    alloc_size = sizeOfRegion + padsize;

    // Using mmap to allocate memory
    fd = open("/dev/zero", O_RDWR);
    if(-1 == fd){
        fprintf(stderr,"Error:mem.c: Cannot open /dev/zero\n");
        return -1;
    }
    space_ptr = mmap(NULL, alloc_size, PROT_READ | PROT_WRITE, MAP_PRIVATE, fd, 0);
    if (MAP_FAILED == space_ptr) {
        fprintf(stderr,"Error:mem.c: mmap cannot allocate space\n");
        allocated_once = 0;
        return -1;
    }
  
    allocated_once = 1;
 
    // for double word alignement
    alloc_size -= 4;
 
    // Intialising total available memory size
    total_mem_size = alloc_size;

    // To begin with there is only one big free block
    // initialize heap so that first block meets double word alignement requirement
    first_block = (blk_hdr*) space_ptr + 1;
    start_pointer = space_ptr;
  
    // Setting up the header
    first_block->size_status = alloc_size;

    // Marking the previous block as busy
    first_block->size_status += 2;

    // Setting up the footer
    blk_hdr *footer = (blk_hdr*) ((char*)first_block + alloc_size - 4);
    footer->size_status = alloc_size;
  
    return 0;
}

/* 
 * Function to be used for debugging 
 * Prints out a list of all the blocks along with the following information for each block 
 * No.      : serial number of the block 
 * Status   : free/busy 
 * Prev     : status of previous block free/busy
 * t_Begin  : address of the first byte in the block (this is where the header starts) 
 * t_End    : address of the last byte in the block 
 * t_Size   : size of the block (as stored in the block header)(including the header/footer)
 */ 
void Mem_Dump() {   	   
    int counter;
    char status[5];
    char p_status[5];
    char *t_begin = NULL;
    char *t_end = NULL;
    int t_size;

    blk_hdr *current = first_block;
    counter = 1;

    int busy_size = 0;
    int free_size = 0;
    int is_busy = -1;

    fprintf(stdout,"************************************Block list***********************************\n");
    fprintf(stdout,"No.\tStatus\tPrev\tt_Begin\t\tt_End\t\tt_Size\n");
    fprintf(stdout,"---------------------------------------------------------------------------------\n");
  
    while ((current < (blk_hdr*) ((char*)first_block + total_mem_size)) && (counter < 15))  {
        t_begin = (char*)current;
        t_size = current->size_status;
    
        if (t_size & 1) {
            // LSB = 1 => busy block
            strcpy(status,"Busy");
            is_busy = 1;
            t_size = t_size - 1;
        }
        else {
            strcpy(status,"Free");
            is_busy = 0;
        }

        if (t_size & 2) {
            strcpy(p_status,"Busy");
            t_size = t_size - 2;
        }
        else 
            strcpy(p_status,"Free");

        if (is_busy) 
            busy_size += t_size;
        else 
            free_size += t_size;

        t_end = t_begin + t_size - 1;
    
        fprintf(stdout,"%d\t%s\t%s\t0x%08lx\t0x%08lx\t%d\n", counter, status, p_status, 
                    (unsigned long int)t_begin, (unsigned long int)t_end, t_size);
    
        current = (blk_hdr*)((char*)current + t_size);
        counter = counter + 1;
    }

    fprintf(stdout,"---------------------------------------------------------------------------------\n");
    fprintf(stdout,"*********************************************************************************\n");
    fprintf(stdout,"Total busy size = %d\n", busy_size);
    fprintf(stdout,"Total free size = %d\n", free_size);
    fprintf(stdout,"Total size = %d\n", busy_size + free_size);
    fprintf(stdout,"*********************************************************************************\n");
    fflush(stdout);

    return;
}
