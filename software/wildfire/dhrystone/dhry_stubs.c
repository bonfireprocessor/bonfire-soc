#include "bonfire.h"

/* The functions in this file are only meant to support Dhrystone on an
 * embedded RV32 system and are obviously incorrect in general. */


uint64_t get_timer_value()
{
#if __riscv_xlen == 32
  while (1) {
    uint32_t hi = read_csr(mcycleh);
    uint32_t lo = read_csr(mcycle);
    if (hi == read_csr(mcycleh))
      return ((uint64_t)hi << 32) | lo;
  }
#else
  return read_csr(mcycle);
#endif
}

uint64_t get_timer_freq() {
  return SYSCLK;
}


long time(void)
{
  return get_timer_value() / get_timer_freq();
}

// set the number of dhrystone iterations
void __wrap_scanf(const char* fmt, int* n)
{
  *n = 10000000;
  //*n =1000000;
}


