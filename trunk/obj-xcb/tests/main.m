#include "../src/obj-xcb.h"

int main(void)
{
	ObjXCBConnection *c = [ObjXCBConnection alloc];
	ObjXCBWindow *w = [ObjXCBWindow alloc];

	[c init];
	
	[w init:c];
	[w map];

	pause();
	[c free];

	return 0;
}
