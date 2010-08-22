/*
 *  ByteOrder.mm
 *  Spork
 *
 *  Created by Jonathan Fischer on 1/18/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include <stdint.h>
#import "ByteOrder.h"
#import <Foundation/NSByteOrder.h>

float LittleFloatToHost(float f)
{
	union
	{
		float f32;
		uint32_t u32;
	} u;
	
	u.f32 = f;
	u.u32 = NSSwapLittleIntToHost(u.u32);
	return u.f32;
}
