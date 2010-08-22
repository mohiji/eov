//
//  SporkOpenGLView.m
//  Spork
//
//  Created by Jonathan Fischer on 1/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EOVOpenGLView.h"
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>

static const float kMouseSensitivity = 0.4f;
static const float kEgobooAnimationFPS = 10.0f;

@implementation EOVOpenGLView
@synthesize theModel, theTexture, framesToDraw;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
	
	return self;
}

- (void)awakeFromNib {
	rotateX = -90.0f;
}

- (void)dealloc
{
	[theModel release];
	[theTexture release];
	[super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
	double aspect;
	NSRect frame;
	
	frame = [self bounds];
	aspect = frame.size.width / frame.size.height;
	
	glViewport(0, 0, frame.size.width, frame.size.height);
	
	glEnable(GL_DEPTH_TEST);
	glDisable(GL_CULL_FACE);
	
	//    glClearColor(1.0f, 106.0f / 255.0f, 201.0f / 255.0f, 1.0f);
	glClearColor(0, 0, 0, 1);
	glClearDepth(1.0F);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(75, aspect, 1, 1024);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	glTranslatef(0, -15, -50);
	glRotatef(rotateX, 1, 0, 0);
	glRotatef(rotateZ, 0, 0, 1);
	
	if (theModel != nil)
	{
		if (theTexture != nil)
		{
			glEnable(GL_TEXTURE_2D);
			glEnable(GL_BLEND);
			glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
			[theTexture bind];
		} else {
			glDisable(GL_TEXTURE_2D);
			glDisable(GL_BLEND);
		}

		if (framesToDraw != nil && [framesToDraw count] > 1)
		{
			int frame1 = [[framesToDraw objectAtIndex:currentFrame] intValue];
			int frame2 = [[framesToDraw objectAtIndex:nextFrame] intValue];
			[theModel drawBlendedFramesFrom:frame1 to:frame2 lerp:frameLerp];			
		} else
		{
			if ([framesToDraw count] == 0) [theModel drawFrame: 0];
			else [theModel drawFrame:[[framesToDraw objectAtIndex:0] intValue]];
		}
	}

	[[self openGLContext] flushBuffer];
}

- (void)mouseDragged: (NSEvent*)event {
	rotateX += [event deltaY] * kMouseSensitivity;
	rotateZ += [event deltaX] * kMouseSensitivity;
	
	[self setNeedsDisplay: YES];
}

- (void)animationTimer: (NSTimer*)theTimer {
	if (framesToDraw == nil || [framesToDraw count] < 2) return;
	
	frameLerp += [theTimer timeInterval] * kEgobooAnimationFPS;
	if (frameLerp > 1.0f) {
		frameLerp -= 1.0f;
		currentFrame = nextFrame;
		nextFrame++;
		
		if (nextFrame >= [framesToDraw count]) nextFrame = 0;
	}
	[self setNeedsDisplay:YES];
}

- (void)setFramesToDraw:(NSArray *)frames {
	[framesToDraw release];
	framesToDraw = [frames retain];
	
	currentFrame = 0;
	nextFrame = 1;
	frameLerp = 0.0f;
}

@end
