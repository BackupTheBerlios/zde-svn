#include "../src/obj-xcb.h"

int main(void)
{
	ObjXCBConnection *c = [ObjXCBConnection alloc];

	[c init];

	[c free];

	return 0;
}
