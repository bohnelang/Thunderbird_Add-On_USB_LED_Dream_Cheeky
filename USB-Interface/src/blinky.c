#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <signal.h>
#include <unistd.h> // no good for Windows?

#include "hidapi.h"


#if defined (__linux__)
#include "hid_lin.c"
#elif defined(__MINGW32__) || defined(__MINGW64__)  || defined(_WIN64) || defined(_WIN32) 
#include <windows.h>
#include "hid_win.c"
#elif defined(__APPLE__)
#include "hid_mac.c"
#endif


#define VENDOR_ID 0x1294
#define PRODUCT_ID 0x1320
#define MAX_BLINKIES  16

/*
[0] = 0, 
[1] = 2,  red     
[2] = 1,  green   
[3] = 5,  yellow  
[4] = 3,  blue    
[5] = 6,  magenta 
[6] = 4,  cyan   
[7] = 7   white   
*/

// a simple array of pointers to the blinky device handles
hid_device *blinkies[MAX_BLINKIES];
int blinky_count = 0;


/*
  use hid_enumerate to find blinkies and open them by their path.
  Use path, because no serial number, so its the only way to open more than one blinky
  attached to the machine
 */
void scan_blinkies() {
  struct hid_device_info *devs, *cur_dev;

  devs = hid_enumerate(VENDOR_ID, PRODUCT_ID);
  cur_dev = devs;
  while (cur_dev) {
	  /*
    printf("Device Found\n  type: %04hx %04hx\n  path: %s\n  serial_number: %ls",
      cur_dev->vendor_id, cur_dev->product_id, cur_dev->path, cur_dev->serial_number);
    printf("\n");
    printf("  Manufacturer: %ls\n", cur_dev->manufacturer_string);
    printf("  Product:      %ls\n", cur_dev->product_string);
    printf("\n");
	*/

    if(blinky_count < MAX_BLINKIES) {
      blinkies[blinky_count++] = hid_open_path(cur_dev->path);
    }

    cur_dev = cur_dev->next;
  }
  hid_free_enumeration(devs);
}

/*
  set the +color+ of the +blinky+
 */
void set_color(hid_device *blinky, int color) {
  unsigned char buf[6] = {0x0, color, 0x0, 0x0, 0x0, 0x0 };
  hid_write(blinky,buf,6);
}

/*
  close the blinky handles
 */
void close_blinkies() {
  for(int i=0; i<blinky_count; i++) {
    set_color(blinkies[i], 0);
    hid_close(blinkies[i]);
  }
}

static volatile int keepRunning = 1;

/*
  handle ctrl-c
 */
void interrutHandler(int dummy) {
  keepRunning = 0;
}

/*
  basic demo to cycle through the colors on the notifier
 */
void demo_cycle() {
  signal(SIGINT, interrutHandler);
  printf("Running a blinking demo; ctrl-c to end ..\n");

//  while (keepRunning) {
    for(int color=1; color<8; color++) {
      for(int blinky=0; blinky<blinky_count; blinky++) {
        set_color(blinkies[blinky], color);
        usleep(120 * 1000);
      }
      usleep(240 * 1000);
    }
//  }
}

/*
  main program - just scan for blinkies, run the demo and say goodbye
 */
#if defined(__MINGW32__) || defined(__MINGW64__)  || defined(_WIN64) || defined(_WIN32)
int WINAPI WinMain ( HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow ){

int argc=0;
char** argv=NULL;

argc=__argc;
argv=__argv;
#else
int main(int argc, char* argv[]) {
#endif

 int color = 0;

  srand(time(NULL));

  scan_blinkies();
  if(blinky_count == 0) {
    printf("No blinkies found, sorry!\n");
    return 1;
  }

  if(argc==2) { 
	color = atoi( argv[1]);
  }
  if(color == 0) color= ( rand() % 6 )+1;	


  set_color(blinkies[0], color);
  sleep(2);

  //demo_cycle();
  close_blinkies();

  return 0;
}
