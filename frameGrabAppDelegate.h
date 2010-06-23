//
//  frameGrabAppDelegate.h
//  frameGrab
//
//  Created by Casey Fleser on 6/22/10.
//  Copyright 2010 Griffin Technology, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

@interface frameGrabAppDelegate : NSObject <NSApplicationDelegate>
{
	CVImageBufferRef		_currentImageBuffer;
	
	BOOL					_frameRecieved;
	BOOL					_busy;
}

- (IBAction)		grabFrame: (id) inSender;

@property (assign) BOOL		busy;

@end
