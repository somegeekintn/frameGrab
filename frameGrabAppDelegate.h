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
	QTCaptureSession					*_session;
	QTCaptureDevice						*_device;
	QTCaptureDeviceInput				*_deviceInput;
	QTCaptureDecompressedVideoOutput	*_videoOutput;
			
	BOOL								_initOK;
	BOOL								_frameRecieved;
}

- (IBAction)		grabFrame: (id) inSender;

@end
