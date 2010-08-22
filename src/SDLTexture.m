//
//  SDLTexture.m
//  EOV
//
//  Created by Jonathan Fischer on 1/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SDLTexture.h"
#include <SDL_image.h>
#include "Utility.h"

static BOOL kSDLWasInit = NO;

@implementation SDLTexture
@synthesize pixelsWide, pixelsHigh, textureID;

- (id)initWithData:(NSData *)data {
	if (!kSDLWasInit) {
		SDL_Init(0);
		IMG_Init(0);
		kSDLWasInit = YES;
	}
	
	if (!(self = [super init]))
		return nil;
	
	// Create an in-memory container for SDL to load the image data from
	SDL_RWops *rw;
	rw = SDL_RWFromMem((void*)[data bytes], [data length]);
	if (!rw) return nil;
	
	// Let the image loading library decode the texture
	SDL_Surface *src = IMG_Load_RW(rw, 1);
	if (src == NULL) return nil;
	
	// Use the surface width & height expanded to the next powers of two
	int w, h;
	w = NearestPowerOfTwo(src->w);
	h = NearestPowerOfTwo(src->h);
	
#if SDL_BYTEORDER == SDL_LIL_ENDIAN
	sourceImage = SDL_CreateRGBSurface(SDL_SWSURFACE, w, h, 32, 0x000000ff, 0x0000ff00, 0x00ff0000, 0xff000000);
#else
	sourceImage = SDL_CreateRGBSurface(SDL_SWSURFACE, w, h, 32, 0xff000000, 0x00ff0000, 0x0000ff00, 0x000000ff);
#endif
	
	if(sourceImage == NULL)
	{
		SDL_FreeSurface(src);
		return nil;
	}
	
	// Turn off source alpha on this image if it's on
	if ( (src->flags & SDL_SRCALPHA) == SDL_SRCALPHA )
	{
		SDL_SetAlpha(src, 0, 0);
	}
	
	// Copy the surface into the texture image
	SDL_Rect area;
	area.x = 0;
	area.y = 0;
	area.w = src->w;
	area.h = src->h;
	SDL_BlitSurface(src, &area, sourceImage, &area);
	
	// Don't need the extra image anymore
	SDL_FreeSurface(src);
	
	// Done for now.  Actual uploading of the data to OpenGL will be done later, when
	// I can be sure that an OpenGL context is active.
	pixelsWide = sourceImage->w;
	pixelsHigh = sourceImage->h;
	
	return self;
}

- (void)dealloc {
	if (sourceImage != NULL) {
		SDL_FreeSurface(sourceImage);
		sourceImage = NULL;
	}
	
	if (textureID != 0) {
		glDeleteTextures(1, &textureID);
		textureID = 0;
	}
	[super dealloc];
}

- (void)uploadToOpenGL {
	if (sourceImage == NULL) return;
	
	glGenTextures(1, &textureID);
	
	glBindTexture(GL_TEXTURE_2D, textureID);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexImage2D(GL_TEXTURE_2D,	0, GL_RGBA,	pixelsWide, pixelsHigh, 0,
				 GL_RGBA, GL_UNSIGNED_BYTE, sourceImage->pixels);
}

- (void)bind {
	if (textureID == 0 && sourceImage != NULL) {
		[self uploadToOpenGL];
	}
	
	if (textureID != 0) {
		glBindTexture(GL_TEXTURE_2D, textureID);
	}
}

@end
