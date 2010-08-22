//
//  SDLTexture.h
//  EOV
//
//  Created by Jonathan Fischer on 1/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>
#include <SDL.h>

@interface SDLTexture : NSObject {
	SDL_Surface *sourceImage;
	int pixelsWide;
	int pixelsHigh;
	GLuint textureID;
}

@property(readonly) int pixelsWide;
@property(readonly) int pixelsHigh;
@property(readonly) GLuint textureID;

- (id)initWithData: (NSData*)data;
- (void)dealloc;

- (void)uploadToOpenGL;
- (void)bind;

@end
