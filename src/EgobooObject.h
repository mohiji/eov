//
//  EgobooObject.h
//  EOV
//
//  Created by Jonathan Fischer on 1/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Md2Model.h"
#import "GLTexture.h"

@interface EgobooObject : NSObject {
	Md2Model *model;
	NSDictionary *textures;
}

@property(retain) Md2Model *model;
@property(retain) NSDictionary *textures;

- (id)init;
- (void)dealloc;
- (int)numTextures;

@end
