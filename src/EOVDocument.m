//
//  MyDocument.m
//  EOV
//
//  Created by Jonathan Fischer on 1/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EOVDocument.h"
#import "SDLTexture.h"

@implementation EOVDocument

- (id)init
{
	if (!(self = [super init]))
		return nil;
	
	myTextures = [[NSMutableArray alloc] initWithCapacity:4];
    return self;
}

- (void)dealloc
{
	[animationTimer invalidate];
	[animationTimer release];
	[myModel release];
	[myTextures removeAllObjects];
	[myTextures release];
	[super dealloc];
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"EOVDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
	[self updateView];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError **)outError
{
	NSDictionary *files;
	NSFileWrapper *modelFile;
	NSFileWrapper *textureFile;
	NSData *textureData;
	NSString *textureName;
	int i;
		
	// Make sure this is a directory wrapper first
	if (![fileWrapper isDirectory])
		return NO;
	
	// Grab the wrapper for the model file
	files = [fileWrapper fileWrappers];
	modelFile = [files objectForKey: @"tris.md2"];
	if (modelFile == nil || ![modelFile isRegularFile])
	{
		return NO;
	}
	
	// Load the model from the file on disk
	myModel = [Md2Model loadFromData: [modelFile regularFileContents]];
	
	// Try and load the model's textures
	[myTextures removeAllObjects];
	for (i = 0;i < 4; i++)
	{
		textureName = [NSString stringWithFormat: @"tris%d.bmp", i];
		textureFile = [files objectForKey:textureName];
		
		if (textureFile != nil && [textureFile isRegularFile])
		{
			SDLTexture *texture;
			textureData = [textureFile regularFileContents];
			texture = [[SDLTexture alloc] initWithData:textureData];
			[myTextures addObject: texture];
			[texture release];
		}
	}
	[self updateView];
	
	if (myModel == nil) return NO;
	return YES;
}

- (void)updateView
{
	if (myModel)
	{
		[glView setTheModel: myModel];
	}
	
	if (myTextures && [myTextures count] > 0)
	{
		[glView setTheTexture: [myTextures objectAtIndex:0]];
	}
	
	// Schedule a timer to update the view on a regular basis.
	animationTimer = [[NSTimer scheduledTimerWithTimeInterval:0.01 
													   target:glView 
													 selector:@selector(animationTimer:) 
													 userInfo:nil 
													  repeats:YES] retain];
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView {
	return [myModel numFrames];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)rowIndex {
	const Md2Frame* frame = [myModel frameAtIndex: rowIndex];
	if (frame != nil) {
		return [NSString stringWithFormat: @"%s", frame->name];
	} else {
		return @"Invalid Frame";
	}
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
	NSIndexSet *selected = [animationTable selectedRowIndexes];
	if (selected == nil) return;
	
	NSMutableArray *rows = [NSMutableArray arrayWithCapacity: [selected count]];
	for (NSUInteger row = [selected firstIndex]; row != NSNotFound; row = [selected indexGreaterThanIndex:row]) {
		[rows addObject: [NSNumber numberWithInt: row]];
	}
	
	[glView setFramesToDraw:rows];
	[glView setNeedsDisplay:YES];
}

@end
