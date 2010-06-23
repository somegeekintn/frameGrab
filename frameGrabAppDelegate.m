//
//  frameGrabAppDelegate.m
//  frameGrab
//
//  Created by Casey Fleser on 6/22/10.
//  Copyright 2010 Griffin Technology, Inc. All rights reserved.
//

#import "frameGrabAppDelegate.h"

@implementation frameGrabAppDelegate

- (void) applicationDidFinishLaunching: (NSNotification *) inNotification
{
    NSError				*QTError = nil;

	_session = [[QTCaptureSession alloc] init];
	_device = [QTCaptureDevice defaultInputDeviceWithMediaType: QTMediaTypeVideo];
	
	if ([_device open: &QTError]) {
		_deviceInput = [[QTCaptureDeviceInput alloc] initWithDevice: _device];
		
		if ([_session addInput: _deviceInput error: &QTError]) {
			_videoOutput = [[QTCaptureDecompressedVideoOutput alloc] init];
			
			[_videoOutput setDelegate: self];
			if ([_session addOutput: _videoOutput error: &QTError])
				_initOK = YES;
		}
	}
	
	if (QTError != nil)
		[NSAlert alertWithError: QTError];
}


- (IBAction) grabFrame: (id) inSender
{
	if (_initOK) {
        [_session startRunning];
		
NSLog(@"starting");
			// Wait
		do {
			[NSApp nextEventMatchingMask: NSAnyEventMask untilDate: [NSDate dateWithTimeIntervalSinceNow: 0.1] inMode: NSDefaultRunLoopMode dequeue: YES];
//			[NSThread sleepForTimeInterval: 1.0];
NSLog(@"waiting");
		} while (!_frameRecieved);
		
NSLog(@"stopping");
        [_session stopRunning];
	}
}

- (void) captureOutput:( QTCaptureOutput *) inCaptureOutput
	didOutputVideoFrame: (CVImageBufferRef) inVideoFrame 
	withSampleBuffer: (QTSampleBuffer *) inSampleBuffer
	fromConnection: (QTCaptureConnection *) inConnection
{
	_frameRecieved = YES;
	
	NSLog(@"_frameRecieved");
	
//    // Store the latest frame
//	// This must be done in a @synchronized block because this delegate method is not called on the main thread
//    CVImageBufferRef imageBufferToRelease;
//    
//    CVBufferRetain(videoFrame);
//    
//    @synchronized (self) {
//        imageBufferToRelease = mCurrentImageBuffer;
//        mCurrentImageBuffer = videoFrame;
//    }
//    
//    CVBufferRelease(imageBufferToRelease);
}

@end
