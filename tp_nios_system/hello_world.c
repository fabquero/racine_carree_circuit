/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */
#include <stdio.h>
#include <system.h>
#include <HAL/inc/sys/alt_timestamp.h>
#include "alt_types.h"


#define uint32_t unsigned int
#define int32_t int
#define uint16_t unsigned short

#define SIZE_WORD 32

#define MSB   (1 << 31)
#define LEDR  (*((volatile int *) (LEDR_BASE | MSB)))
#define SW    (*((volatile int *) (SW_BASE   | MSB)))
#define TIMER_CTRL (*((volatile int *) ((TIMER_BASE)| MSB | 0x4)))
#define TIMER_SNAPL (*((volatile int *) ((TIMER_BASE)| MSB | 0x10)))
#define TIMER_SNAPH (*((volatile int *) ((TIMER_BASE)| MSB | 0x14)))

#define NUMBER_OF_ELEMENTS 200
#define N 16

int nios_square(uint32_t A){
    uint32_t D = A;
    int32_t R = 0;
    uint16_t Z = 0;
    uint32_t i;
    for (i = 0; i < N ; i++)
    {
        if(R>=0){
            R = (R << 2) + (D >> 30) - ((Z << 2) + 1);
        } else {
            R = (R << 2) + (D >> 30) + ((Z << 2) + 3);
        }

        if(R >= 0){
            Z = (Z << 1) + 1;
        } else {
            Z = (Z << 1);
        }
        D = D << 2;
    }
    return Z;
}

void applySquareRoot(){
	 uint32_t tabSquared[NUMBER_OF_ELEMENTS];
	  // on rempli un tableau de 200 element avec son carre
	  int i;
	  for (i = 0; i < NUMBER_OF_ELEMENTS; i++)
	  {
	    tabSquared[i] = i * i;
	  }

	  for (i = 0; i < NUMBER_OF_ELEMENTS; i++)
	  {
	    nios_square(tabSquared[i]);
	  }
}

#define MSBs_AT_0 (0x0000ffff)

uint32_t start_my_timestamp(){
	//0 jusqu'a 4, STOP=0, START = 1 (start counting down),CONT = 1 (keep counting when it reaches 0 if not stop by STOP bit),ITO = 0 (no irq)
	unsigned int start_counter_value = (0x6);
	TIMER_CTRL = start_counter_value;
}

uint32_t my_timestamp(){
	TIMER_SNAPL = 0;
	unsigned int low_value = (MSBs_AT_0)& TIMER_SNAPL;
	unsigned int high_value = (MSBs_AT_0)& TIMER_SNAPH;
	printf("inside is %u and %u ;",low_value,high_value);
	return (high_value<<16)|(low_value&0x0000ffff);
}

int main()
{
	printf("Hello from Nios II!\n");
	//alt_timestamp_start();
	//unsigned int t1 = alt_timestamp();
	//unsigned int t2 = alt_timestamp();
	// max counter is
	//unsigned int max_counter = 0xffffffff;
	start_my_timestamp();
	unsigned int t1 = my_timestamp();
	unsigned int t2 = my_timestamp();
	// si on a boucle dans le compteur...
	//if(t1 > t2){
	//	t2 = t2 + max_counter;
	//}
	// affiche la valeur du compteur d'intel.
	printf("val t1-t2 %u", t2-t1);

	while (1) LEDR = SW;
	return 0;
}
