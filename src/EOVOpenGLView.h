//
//  SporkOpenGLView.h
//  Spork
//
//  Created by Jonathan Fischer on 1/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Md2Model.h"
#import "SDLTexture.h"

@interface EOVOpenGLView : NSOpenGLView {
	Md2Model *theModel;
	SDLTexture *theTexture;
	
	float rotateX;
	float rotateZ;
	
	NSArray *framesToDraw;
	int currentFrame;
	int nextFrame;
	float frameLerp;
}

@property(retain) Md2Model *theModel;
@property(retain) SDLTexture *theTexture;
@property(retain) NSArray *framesToDraw;

//// Mouse Events
- (void)mouseDragged:(NSEvent *)theEvent;

//// Animation handling
- (void)animationTimer: (NSTimer*)theTimer;

@end
