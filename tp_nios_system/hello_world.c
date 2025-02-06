/*
 * "Computation time of Square root" example.
 *
 * @author Fabien Quero
 * @version 1.0
 * @date 6 February 2025
 * @file
 * This file contains a program that measures the execution time of computing the square root
 * across various architecture configurations. The purpose of this program is to benchmark
 * the performance of the square root operation and assess how different system architectures
 * impact its computation time (Nios II F,S,E).
 *
 */
#include <stdio.h>
#include <system.h>
#include <HAL/inc/sys/alt_timestamp.h>
#include "alt_types.h"

// type défini pour remplacer stdint. Note: on pourrait utiliser directement stdint.
#define uint32_t unsigned int
#define int32_t int
#define uint16_t unsigned short

//--------------------------------------------- Pointeurs ------------------------------------------------------------------
// Pour outre passer le cache.
#define MSB   (1 << 31)
// define pour les LEDs et pour les SWITCHs.
#define LEDR  (*((volatile int *) (LEDR_BASE | MSB)))
#define SW    (*((volatile int *) (SW_BASE   | MSB)))
// Gestion du timer --> registre de control, valeur haute, valeur basse.
#define TIMER_CTRL (*((volatile int *) (TIMER_BASE | MSB | 0x4)))
#define TIMER_SNAPL (*((volatile int *) (TIMER_BASE | MSB | 0x10)))
#define TIMER_SNAPH (*((volatile int *) (TIMER_BASE | MSB | 0x14)))

//--------------------------------------------- Variable pour la gestion de l'algorithme square root -------------------------
#define NUMBER_OF_ELEMENTS 200
#define N 16

//--------------------------------------------- code square root ---------------------------------------------

/**
 * @brief compute the integer square root of a number A. A is on 32 bits, but the result is on 16 bits.
 * @param uint32_t: A number on which we want to compute the square root.
 * @return uint16_t : The value of the square root of A.
 */
uint16_t nios_square(uint32_t A){
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

/**
 * @brief Create an array tabSquarred of NUMBER_OF_ELEMENTS value: tabSquared[index] = index^2. Apply 100 times the square root on the values.
 * @return uint16_t* : an array of NUMBER_OF_ELEMENTS value containing the square root values.
 */
//uint16_t*
void applySquareRoot(){//uint16_t* tabResultSquareRoot){
	 uint32_t tabSquared[NUMBER_OF_ELEMENTS] = {0};
	 uint16_t tabResultSquareRoot[NUMBER_OF_ELEMENTS] = {0};

	  // on rempli un tableau de 200 element avec son carre
	  int i;
	  for (i = 0; i < NUMBER_OF_ELEMENTS; i++)
	  {
	    tabSquared[i] = i * i;
	  }

	  int j = 0;
	  for (j = 0; j < 100; j++){
		  int k = 0;
		  for (k = 0; k < NUMBER_OF_ELEMENTS; ++k) {
			  tabResultSquareRoot[NUMBER_OF_ELEMENTS] = 0;
		  }

		  for (i = 0; i < NUMBER_OF_ELEMENTS; i++){
			  tabResultSquareRoot[i] = nios_square(tabSquared[i]);
	  	  }
	  }
	  //return tabResultSquareRoot;
}

/**
 * @brief display the values of an array.
 * @param uint16_t* : The array to display.
 * @param uint32_t  : The size of the array.
 */
void displayArray(uint16_t* t, uint32_t number_element){
	int i = 0;
	for (i = 0; i < number_element; ++i) {
		printf("t[%d] = %d\n", i, t[i]);
	}
}

//------------------------------------ Timer code ------------------------------------------------------

/**
 * @brief Start the counter.
 */
void start_my_timestamp(){
	//0 jusqu'a 4, STOP=0, START = 1 (start counting down),CONT = 1 (keep counting when it reaches 0 if not stop by STOP bit),ITO = 0 (no irq)
	unsigned int start_counter_value = (0x6);
	TIMER_CTRL = start_counter_value;
}

// defini un masque pour garder les 16 valeurs qui nous intéressent.
#define HIGHs_AT_0 (0x0000ffff)

/**
 * @brief Get the value in cycle
 * @return uint32_t: The value in cycle
 */
uint32_t my_timestamp(){
	TIMER_SNAPL = 0;
	unsigned int low_value = (HIGHs_AT_0)& TIMER_SNAPL;
	unsigned int high_value = (HIGHs_AT_0)& TIMER_SNAPH;
	return (high_value<<16)|(low_value);
}

int main()
{
	printf("Hello from Nios II!\n");
	// INTEL PART
	//alt_timestamp_start();
	//unsigned int t1 = alt_timestamp();
	//unsigned int t2 = alt_timestamp();
	// max counter is
	unsigned int max_counter = 0xffffffff;
	// si on a boucle dans le compteur...
		//if(t1 > t2){
		//	t2 = t2 + max_counter;
		//}
	// affiche la valeur du compteur d'intel.
	//printf("valeur obtenu pour intel: %u", t2-t1);

	// SQUARE ROOT PART
	uint16_t tabResult[NUMBER_OF_ELEMENTS] = {0};
	//uint16_t* modifiedTab = 0;

	start_my_timestamp();
	unsigned int t1 = my_timestamp();

	//modifiedTab = applySquareRoot(tabResult);
	applySquareRoot(tabResult);

	unsigned int t2 = my_timestamp();

	// comme c'est un decompteur (decroissant), on doit avoir t1 > t2, sinon on a boucle.
	//if(t2 > t1){
	//	t2 =
	//}

	//displayArray(modifiedTab,NUMBER_OF_ELEMENTS);
	printf("value of t1 is %u and t2 is %u, then t1-t2 %u and mean for one value is %u", t1, t2, t1-t2, (t1-t2)/(100*200));

	while (1) LEDR = SW;
	return 0;
}
