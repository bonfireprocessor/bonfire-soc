/* See LICENSE of license details. */

#include <stddef.h>

void *__wrap_sbrk(ptrdiff_t incr)
{
  extern char _end[];
 // extern char _heap_end[];
  static char *curbrk = _end;

  if (curbrk + incr < _end)
    return NULL - 1;

  curbrk += incr;
  return curbrk - incr;
}
