#include "wildfire.h"
#include "uart.h"

// sample_clk = (f_clk / (baudrate * 16)) - 1
// (96.000.000 / (115200*16))-1 = 51,08


int main() {

  _setDivisor(51);
  while(1) {
    writestr("1234 ");
  }  

}
