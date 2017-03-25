/* See LICENSE of license details. */

#include <stdint.h>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>

#include "../../monitor/uart.h"

ssize_t __wrap_write(int fd, const void* ptr, size_t len)
{
   const uint8_t * current = (const uint8_t *)ptr;


    for (size_t jj = 0; jj < len; jj++) {
        writechar(current[jj]);

      if (current[jj] == '\n') {
         writechar('\r');
      }
    }
    return len;

}
