//
//  GLTexture.m
//  Particles
//
//  Created by Jonathan Fischer on 10/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "GLTexture.h"


@implementation GLTexture
@synthesize textureID;

- (id)initWithContentsOfFile:(NSString *)filePath {
	NSImage *sourceImage;
	NSBitmapImageRep *bitmap;
	int samplesPerPixel = 0;
	NSSize imgSize;
	
	if (!(self = [super init])) {
		return nil;
	}
	
	sourceImage = [[NSImage alloc] initWithContentsOfFile:filePath];
	if (!sourceImage) return nil;
	
	imgSize = [sourceImage size];
	bitmap = [NSBitmapImageRep alloc];
	
	[sourceImage lockFocus];
	[bitmap initWithFocusedViewRect: NSMakeRect(0, 0, imgSize.width, imgSize.height)];
	[sourceImage unlockFocus];
	
	// Set proper unpacking row length for bitmap.
    glPixelStorei(GL_UNPACK_ROW_LENGTH, [bitmap pixelsWide]);
	
    // Set byte aligned unpacking (needed for 3 byte per pixel bitmaps).
    glPixelStorei (GL_UNPACK_ALIGNMENT, 1);
	
	// Generate an OpenGL texture name
	glGenTextures(1, &textureID);
	glBindTexture(GL_TEXTURE_2D, textureID);
	
	// Non-mipmap filtering (redundant for texture_rectangle).
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,  GL_LINEAR);
    samplesPerPixel = [bitmap samplesPerPixel];
	
	// Nonplanar, RGB 24 bit bitmap, or RGBA 32 bit bitmap.
    if(![bitmap isPlanar] &&
	   (samplesPerPixel == 3 || samplesPerPixel == 4))
    {
        glTexImage2D(GL_TEXTURE_2D, 0,
					 samplesPerPixel == 4 ? GL_RGBA8 : GL_RGB8,
					 [bitmap pixelsWide],
					 [bitmap pixelsHigh],
					 0,
					 samplesPerPixel == 4 ? GL_RGBA : GL_RGB,
					 GL_UNSIGNED_BYTE,
					 [bitmap bitmapData]);
    }
    else
    {
        // Handle other bitmap formats.
    }
	
    // Clean up.
    [bitmap release];
	[sourceImage release];
	
	return self;
}

- (void)dealloc {
	if (textureID != 0) {
		glDeleteTextures(1, &textureID);
		textureID = 0;
	}
	[super dealloc];
}

- (void)bind {
	glBindTexture(GL_TEXTURE_2D, textureID);
}

@end
