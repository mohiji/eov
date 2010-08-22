//
//  Md2Model.m
//  EOV
//
//  Created by Jonathan Fischer on 1/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Md2Model.h"
#import "ByteOrder.h"
#include "id_md2.h"
#import <OpenGL/gl.h>

static GLfloat blendVertices[MD2_MAX_VERTICES][3];
static GLfloat blendNormals[MD2_MAX_VERTICES][3];

@implementation Md2Model
@synthesize numVertices, numTexCoords, numTriangles, numSkins, numFrames;

- (id)init
{
	if (!(self = [super init]))
		return nil;
	
	return self;
}

- (void)dealloc
{
	if (skins) free(skins);
	if (texCoords) free(texCoords);
	if (triangles) free(triangles);
	if (frames) {
		int i;
		for (i = 0;i < numFrames; i++) {
			if (frames[i].vertices) free(frames[i].vertices);
		}
		
		free(frames);
	}
	
	[super dealloc];
}

- (const Md2SkinName*)skinAtIndex: (int)i
{
	if (i < 0 || i >= numSkins) return nil;
	else return &(skins[i]);
}

- (const Md2TexCoord*)texCoordAtIndex: (int)i
{
	if (i < 0 || i >= numTexCoords) return nil;
	else return &(texCoords[i]);
}

- (const Md2Triangle*)triangleAtIndex: (int)i
{
	if (i < 0 || i >= numTriangles) return nil;
	else return &(triangles[i]);
}

- (const Md2Frame*)frameAtIndex: (int)i
{
	if (i < 0 || i >= numFrames) return nil;
	else return &(frames[i]);
}

+ (Md2Model*)loadFromData:(NSData*)fileData
{
	struct md2_header header;
	NSRange range;
	char frame_buffer[MD2_MAX_FRAMESIZE];
	Md2Model *model;
	int i;
	
	// Copy out the file's header, and make sure that it's a valid MD2 file
	[fileData getBytes: &header length: sizeof(struct md2_header)];
		
	// Make sure the byte ordering of the header fields is correct
	header.magic = NSSwapLittleIntToHost(header.magic);
	header.version = NSSwapLittleIntToHost(header.version);
	
	// Make sure it's an MD2 file
	if (header.magic != MD2_MAGIC_NUMBER || header.version != MD2_VERSION)
	{
		return nil;
	}
	
	// Go ahead and make sure the rest of the header values are correct
	header.skinWidth = NSSwapLittleIntToHost(header.skinWidth);
	header.skinHeight = NSSwapLittleIntToHost(header.skinHeight);
	header.frameSize = NSSwapLittleIntToHost(header.frameSize);
	header.numSkins = NSSwapLittleIntToHost(header.numSkins);
	header.numVertices = NSSwapLittleIntToHost(header.numVertices);
	header.numTexCoords = NSSwapLittleIntToHost(header.numTexCoords);
	header.numTriangles = NSSwapLittleIntToHost(header.numTriangles);
	header.numGlCommands = NSSwapLittleIntToHost(header.numGlCommands);
	header.numFrames = NSSwapLittleIntToHost(header.numFrames);
	header.offsetSkins = NSSwapLittleIntToHost(header.offsetSkins);
	header.offsetTexCoords = NSSwapLittleIntToHost(header.offsetTexCoords);
	header.offsetTriangles = NSSwapLittleIntToHost(header.offsetTriangles);
	header.offsetFrames = NSSwapLittleIntToHost(header.offsetFrames);
	header.offsetGlCommands = NSSwapLittleIntToHost(header.offsetGlCommands);
	header.offsetEnd = NSSwapLittleIntToHost(header.offsetEnd);
	
	// Allocate memory to hold the model
	model = [[Md2Model alloc] init];
	model->numVertices = header.numVertices;
	model->numTexCoords = header.numTexCoords;
	model->numTriangles = header.numTriangles;
	model->numSkins = header.numSkins;
	model->numFrames = header.numFrames;
	
	model->texCoords = calloc(header.numTexCoords, sizeof(Md2TexCoord));
	model->triangles = calloc(header.numTriangles, sizeof(Md2Triangle));
	model->skins     = calloc(header.numSkins, sizeof(Md2SkinName));
	model->frames    = calloc(header.numFrames, sizeof(Md2Frame));
	
	// Allocate memory for each frame's vertices as well
	for (i = 0;i < header.numFrames; i++)
	{
		model->frames[i].vertices = calloc(header.numVertices, sizeof(Md2Vertex));
	}
	
	// Start loading data from the file.
	// Skins first
	range.location = header.offsetSkins;
	range.length = sizeof(Md2SkinName) * header.numSkins;
	[fileData getBytes: model->skins range: range];
	
	// Texture coordinates next
	range.location = header.offsetTexCoords;
	range.length = sizeof(struct md2_texcoord);
	for (i = 0;i < header.numTexCoords; i++)
	{
		// Convert the texture coordinates to normalized floats while
		// loading them
		struct md2_texcoord tc;
		[fileData getBytes: &tc range: range];
		
		tc.s = NSSwapLittleShortToHost(tc.s);
		tc.t = NSSwapLittleShortToHost(tc.t);
		
		model->texCoords[i].s = tc.s / (float)header.skinWidth;
		model->texCoords[i].t = tc.t / (float)header.skinHeight;
		
		range.location += sizeof(struct md2_texcoord);
	}
	
	// Triangles can be loaded directly; their format on disk is the
	// same as the format in memory
	range.location = header.offsetTriangles;
	range.length = sizeof(Md2Triangle) * header.numTriangles;
	[fileData getBytes:model->triangles range:range];
	
	// Byte-swap the triangles too
	for (int i = 0;i < header.numTriangles; i++)
	{
		for (int v = 0;v < 3; v++)
		{
			model->triangles[i].vertexIndices[v] = NSSwapLittleShortToHost(model->triangles[i].vertexIndices[v]);
			model->triangles[i].texCoordIndices[v] = NSSwapLittleShortToHost(model->triangles[i].texCoordIndices[v]);
		}
	}
	
	// Last, load the frames of animation
	range.location = header.offsetFrames;
	range.length = header.frameSize;
	for (int i = 0;i < header.numFrames; i++)
	{
		struct md2_frame *frame;
		
		// Read the current frame
		[fileData getBytes:frame_buffer range:range];
		frame = (struct md2_frame*)frame_buffer;
		
		// Byte-swap the scale and translate vectors
		frame->scale[0] = LittleFloatToHost(frame->scale[0]);
		frame->scale[1] = LittleFloatToHost(frame->scale[1]);
		frame->scale[2] = LittleFloatToHost(frame->scale[2]);
		
		frame->translate[0] = LittleFloatToHost(frame->translate[0]);
		frame->translate[1] = LittleFloatToHost(frame->translate[1]);
		frame->translate[2] = LittleFloatToHost(frame->translate[2]);
		
		memcpy(model->frames[i].name, frame->name, 16);
		
		// Unpack the vertices for this frame
		for (int v = 0; v < header.numVertices; v++)
		{
			model->frames[i].vertices[v].x =
			frame->vertices[v].vertex[0] * frame->scale[0] + frame->translate[0];
			model->frames[i].vertices[v].y =
			frame->vertices[v].vertex[1] * frame->scale[1] + frame->translate[1];
			model->frames[i].vertices[v].z =
			frame->vertices[v].vertex[2] * frame->scale[2] + frame->translate[2];
			
			model->frames[i].vertices[v].normal = frame->vertices[v].lightNormalIndex;
		}
		
		// Calculate the bounding box for this frame
		model->frames[i].min[0] = frame->translate[0];
		model->frames[i].min[1] = frame->translate[1];
		model->frames[i].min[2] = frame->translate[2];
		model->frames[i].max[0] = frame->translate[0] + (frame->scale[0] * 255.0f);
		model->frames[i].max[1] = frame->translate[1] + (frame->scale[1] * 255.0f);
		model->frames[i].max[2] = frame->translate[2] + (frame->scale[2] * 255.0f);
		
		range.location += header.frameSize;
	}

	// Done
	return model;
}

- (void)blendFramesFrom: (int)frame1 to: (int)frame2 lerp: (float)lerp
{
	int i;
	const Md2Frame *from, *to;
	
	from = [self frameAtIndex:frame1];
	to = [self frameAtIndex:frame2];
	
	if(lerp <= 0)
	{
		// copy the vertices in frame 'from' over
		for(i = 0;i < numVertices;i++)
		{
			blendVertices[i][0] = from->vertices[i].x;
			blendVertices[i][1] = from->vertices[i].y;
			blendVertices[i][2] = from->vertices[i].z;
			
			blendNormals[i][0] = kMd2Normals[from->vertices[i].normal][0];
			blendNormals[i][1] = kMd2Normals[from->vertices[i].normal][1];
			blendNormals[i][2] = kMd2Normals[from->vertices[i].normal][2];
		}
	} else if(lerp >= 1.0f)
	{
		// copy the vertices in frame 'to'
		for(i = 0;i < numVertices;i++)
		{
			blendVertices[i][0] = to->vertices[i].x;
			blendVertices[i][1] = to->vertices[i].y;
			blendVertices[i][2] = to->vertices[i].z;
			
			blendNormals[i][0] = kMd2Normals[to->vertices[i].normal][0];
			blendNormals[i][1] = kMd2Normals[to->vertices[i].normal][1];
			blendNormals[i][2] = kMd2Normals[to->vertices[i].normal][2];
		}
	} else
	{
		// mix the vertices
		for(i = 0;i < numVertices;i++)
		{
			blendVertices[i][0] = from->vertices[i].x +
			(to->vertices[i].x - from->vertices[i].x) * lerp;
			blendVertices[i][1] = from->vertices[i].y +
			(to->vertices[i].y - from->vertices[i].y) * lerp;
			blendVertices[i][2] = from->vertices[i].z +
			(to->vertices[i].z - from->vertices[i].z) * lerp;
			
			blendNormals[i][0] = kMd2Normals[from->vertices[i].normal][0] +
			(kMd2Normals[to->vertices[i].normal][0] - kMd2Normals[from->vertices[i].normal][0]) * lerp;
			blendNormals[i][0] = kMd2Normals[from->vertices[i].normal][1] +
			(kMd2Normals[to->vertices[i].normal][1] - kMd2Normals[from->vertices[i].normal][1]) * lerp;
			blendNormals[i][0] = kMd2Normals[from->vertices[i].normal][2] +
			(kMd2Normals[to->vertices[i].normal][2] - kMd2Normals[from->vertices[i].normal][2]) * lerp;
		}
	}
}

- (void)drawBlendedFramesFrom: (int)frame1 to: (int)frame2 lerp: (float)lerp
{
	if (frame1 < 0 || frame1 >= numFrames) return;
	if (frame2 < 0 || frame2 >= numFrames) return;
	
	[self blendFramesFrom:frame1 to:frame2 lerp:lerp];
	
	int i;
	Md2Triangle *tri;
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);
	
	glVertexPointer(3, GL_FLOAT, 0, blendVertices);
	glNormalPointer(GL_FLOAT, 0, blendNormals);
	
	glBegin(GL_TRIANGLES);
	{
		for(i = 0;i < numTriangles;i++)
		{
			tri = &triangles[i];
			
			glTexCoord2fv((const GLfloat*)&(texCoords[tri->texCoordIndices[0]]));
			glArrayElement(tri->vertexIndices[0]);
			
			glTexCoord2fv((const GLfloat*)&(texCoords[tri->texCoordIndices[1]]));
			glArrayElement(tri->vertexIndices[1]);
			
			glTexCoord2fv((const GLfloat*)&(texCoords[tri->texCoordIndices[2]]));
			glArrayElement(tri->vertexIndices[2]);
		}
	}
	glEnd();
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);
}

- (void)drawFrame: (int)frame
{
	[self drawBlendedFramesFrom:frame to:frame lerp:0];
}

@end
