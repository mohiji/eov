//
//  EgobooObject.m
//  EOV
//
//  Created by Jonathan Fischer on 1/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EgobooObject.h"


@implementation EgobooObject
@synthesize model, textures;

- (id)init
{
	if (!(self = [super init]))
		return nil;
	
	textures = [NSDictionary dictionary];
	return self;
}

- (void)dealloc
{
	[model release];
	model = nil;
	
	[textures release];
	textures = nil;
	
	[super dealloc];
}

- (int)numTextures
{
	return [textures count];
}

@end
