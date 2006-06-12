#include "../src/obj-xcb.h"

/* XXX
 *
 * This is outdated testing code based on a testing implementation.  
 * While it should work now, it may not work in the future as 
 * ObjXCBWindow is not finalized.
 *
 * XXX
 */

int main(void)
{
	ObjXCBConnection *c = [ObjXCBConnection alloc];
	//ObjXCBWindow *w = [ObjXCBWindow alloc];

	[c init];
	
	//[w init:c];
	//[w map];

	pause();
	[c free];

	return 0;
}
