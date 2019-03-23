/*   Include Files */ 

#include <stdio.h>
#include <termios.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <sys/time.h>
#include <errno.h>
#include <stdlib.h>

int main(void){  

  int fdSer;
  struct termios t;
 

  /* Open serial output dev */
  if ((fdSer = open("/dev/ttyUSB0",O_RDWR))<0) {
    perror("Cannot open device");
    exit(1);}

    /* set serial device flags */
  tcgetattr(fdSer,&t);
  t.c_iflag =  IGNPAR | BRKINT;
  t.c_oflag = 0;
  t.c_cflag = CS8 | CREAD | CLOCAL  ;
  t.c_lflag = 0;
  t.c_line = 0;
  cfsetospeed(&t,B115200);
  cfsetispeed(&t,B115200);
  tcsetattr(fdSer,TCSANOW,&t);
  close(fdSer);

  /* Open serial output dev */
  if ((fdSer = open("/dev/ttyUSB1",O_RDWR))<0) {
    perror("Cannot open device");
    exit(1);}

    /* set serial device flags */
  tcgetattr(fdSer,&t);
  t.c_iflag =  IGNPAR | BRKINT;
  t.c_oflag = 0;
  t.c_cflag = CS8 | CREAD | CLOCAL  ;
  t.c_lflag = 0;
  t.c_line = 0;
  cfsetospeed(&t,B2400);
  cfsetispeed(&t,B2400);
  tcsetattr(fdSer,TCSANOW,&t);
  close(fdSer);
  return 0;
}
