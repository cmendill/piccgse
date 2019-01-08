/*   Include Files */ 

#include <stdio.h>
#include <termios.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <sys/time.h>
#include <errno.h>
#include <stdlib.h>

#define SERIAL "/dev/ttyUSB0"

int main(void){  

  int fdSer;
  struct termios t;
 

  /* Open serial output dev */
  if ((fdSer = open(SERIAL,O_RDWR))<0) {
    perror("Cannot open device");
    exit(1);}

    /* set serial device flags */
  tcgetattr(fdSer,&t);
  t.c_iflag =  IGNPAR | BRKINT;
  t.c_oflag = 0;
  t.c_cflag = CS8 | CREAD | CLOCAL  ;
  t.c_lflag = 0;
  t.c_line = 0;
  cfsetospeed(&t,B1200);
  cfsetispeed(&t,B1200);
  tcsetattr(fdSer,TCSANOW,&t);
  close(fdSer);
  return 0;
}
