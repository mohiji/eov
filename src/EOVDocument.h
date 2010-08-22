//
//  MyDocument.h
//  EOV
//
//  Created by Jonathan Fischer on 1/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "EOVOpenGLView.h"
#import "Md2Model.h"

@interface EOVDocument : NSDocument
{
	IBOutlet EOVOpenGLView *glView;
	IBOutlet NSTableView *animationTable;
	NSTimer *animationTimer;
	
	Md2Model *myModel;
	NSMutableArray *myTextures;
}

- (void)updateView;

//// Table data source methods
- (int)numberOfRowsInTableView: (NSTableView*)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn*)tableColumn row:(int)rowIndex;
- (void)tableViewSelectionDidChange:(NSNotification*)aNotification;

@end
