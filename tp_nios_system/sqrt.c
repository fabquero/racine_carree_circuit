#include <stdio.h>
#include <stdint.h>

#define NUMBER_OF_ELEMENTS 200
#define N 16

int nios_square(uint32_t A){
    uint32_t D = A;
    int32_t R = 0;
    uint16_t Z = 0;
    for (uint32_t i = 0; i < N ; i++)
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

int main(void) {
  uint32_t tabSquared[NUMBER_OF_ELEMENTS];
  // on rempli un tableau de 200 element avec son carre
  for (int i = 0; i < NUMBER_OF_ELEMENTS; i++)
  {
    tabSquared[i] = i * i;  
  }

  for (int i = 0; i < NUMBER_OF_ELEMENTS; i++)
  {
    nios_square(tabSquared[i]);
  }
  
}