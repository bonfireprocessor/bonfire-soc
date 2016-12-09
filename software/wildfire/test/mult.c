#include "wildfire.h"
#include "uart.h"

#include <stdlib.h>

void readnumstr(char *b,int sz) {
char c;
char *p;

   p=b;
   c=readchar();
   while (c!='\r') {

      if (c==8 && p>b) {// backspace
        p--;
        writestr("\b \b");
      } else if (((c>='0' && c<='9') || c=='-') && p<(b+sz-1) ) {
          *p++=c;
          writechar(c); // echo
      }
      else
        writechar('\a'); // beep

      c=readchar();
   }
   *p='\0';

}

void newline()
{
  writestr("\r\n");
}



int main() {
char buff[80];
int x,y;

  setDivisor(16);
  newline();
  writestr("Processor ID: ");
  writeHex(get_impid());
  newline();

  while(1) {
    writestr("Enter x (max 10 digits):");
    readnumstr(buff,11);
    x=atoi(buff);
    newline();

    writestr("Enter y (max 10 digits):");
    readnumstr(buff,11);
    y=atoi(buff);
    newline();

    itoa(x*y,buff,10);
    writestr(buff);
    newline();

  }
  return 0;

}
