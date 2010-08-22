//
//  GLTexture.h
//  Particles
//
//  Created by Jonathan Fischer on 10/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GLTexture : NSObject {
	GLuint textureID;
	int width;
	int height;
}

- (id)initWithContentsOfFile: (NSString*)filePath;
- (void)dealloc;

- (void)bind;

@property (readonly) GLuint textureID;

@end
