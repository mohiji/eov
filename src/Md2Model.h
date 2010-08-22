//
//  Md2Model.h
//  EOV
//
//  Created by Jonathan Fischer on 1/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef struct Md2Vertex
{
	float x, y, z;
	unsigned normal;	// index to id-normal array
}Md2Vertex;

typedef struct Md2TexCoord
{
	float s, t;
}Md2TexCoord;

typedef struct Md2Triangle
{
	short vertexIndices[3];
	short texCoordIndices[3];
}Md2Triangle;

typedef struct Md2Frame
{
	char name[16];
	float min[3], max[3];		// axis-aligned bounding box limits
	Md2Vertex *vertices;
}Md2Frame;

typedef struct Md2SkinName
{
	char name[64];
}Md2SkinName;

@interface Md2Model : NSObject {
	int numVertices;
	int numTexCoords;
	int numTriangles;
	int numSkins;
	int numFrames;
	
	Md2SkinName *skins;
	Md2TexCoord *texCoords;
	Md2Triangle *triangles;
	Md2Frame    *frames;
}

@property(readonly) int numVertices;
@property(readonly) int numTexCoords;
@property(readonly) int numTriangles;
@property(readonly) int numSkins;
@property(readonly) int numFrames;

+ (Md2Model*)loadFromData: (NSData*)fileData;

- (id)init;
- (void)dealloc;

- (const Md2SkinName*)skinAtIndex: (int)i;
- (const Md2TexCoord*)texCoordAtIndex: (int)i;
- (const Md2Triangle*)triangleAtIndex: (int)i;
- (const Md2Frame*)frameAtIndex: (int)i;

- (void)drawFrame: (int)frame;
- (void)drawBlendedFramesFrom:(int)frame1 to:(int)frame2 lerp:(float)lerp;

- (void)blendFramesFrom: (int)frame1 to: (int)frame2 lerp: (float)lerp;

@end
