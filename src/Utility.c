/*
 *  Utility.c
 *  EOV
 *
 *  Created by Jonathan Fischer on 1/20/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "Utility.h"

int NearestPowerOfTwo(int i)
{
	int value = 1;
	while (value < i) value *= 2;
	
	return value;
}
