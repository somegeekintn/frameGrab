//
//  frameGrabAppDelegate.m
//  frameGrab
//
//  Created by Casey Fleser on 6/22/10.
//  Copyright 2010 Griffin Technology, Inc. All rights reserved.
//

#import "frameGrabAppDelegate.h"

@interface frameGrabAppDelegate (Private)

- (NSImage *)		imageWithCurrentFrame;

@end

@implementation frameGrabAppDelegate

@synthesize busy = _busy;

- (IBAction) grabFrame: (id) inSender
{
	QTCaptureSession	*session = [[QTCaptureSession alloc] init];
	QTCaptureDevice		*device = [QTCaptureDevice defaultInputDeviceWithMediaType: QTMediaTypeVideo];
    NSError				*qtError = nil;
	
	_frameRecieved = NO;
	self.busy = YES;
	
	if ([device open: &qtError]) {
		QTCaptureDeviceInput		*deviceInput = [[QTCaptureDeviceInput alloc] initWithDevice: device];
		
		if ([session addInput: deviceInput error: &qtError]) {
			QTCaptureDecompressedVideoOutput		*videoOutput = [[QTCaptureDecompressedVideoOutput alloc] init];
			
			if ([session addOutput: videoOutput error: &qtError]) {
				NSImage			*grabbedFrame;
				
				[videoOutput setDelegate: self];
				[session startRunning];
				
				do {
					// if we just sleep here, we'll never get a frame
					[NSApp nextEventMatchingMask: NSAnyEventMask untilDate: [NSDate dateWithTimeIntervalSinceNow: 0.1] inMode: NSDefaultRunLoopMode dequeue: YES];
				} while (!_frameRecieved);
				
				[session stopRunning];
				
				if ((grabbedFrame = [self imageWithCurrentFrame]) != nil)
					[[[NSBitmapImageRep imageRepWithData: [grabbedFrame TIFFRepresentation]] representationUsingType: NSPNGFileType properties: nil] writeToFile: [@"~/Desktop/framegrab.png" stringByExpandingTildeInPath] atomically: YES];
					
				[session removeOutput: videoOutput];
			}
			
			[videoOutput release];
			[session removeInput: deviceInput];
		}
		
		[deviceInput release];
		[device close];
	}
	
	[session release];
	
	if (qtError != nil)		// bummer
		[NSAlert alertWithError: qtError];
		
	self.busy = NO;
}

- (NSImage *) imageWithCurrentFrame
{
    CVImageBufferRef	imageBuffer;
    NSImage				*image = nil;
	
	// not strictly necessary since we've probably stopped the QTCaptureSession at this point,
	// but just in case it isn't, synchronize this since the delegate need not be called in the main thread.
    @synchronized (self) {
        imageBuffer = CVBufferRetain(_currentImageBuffer);
    }
    
    if (imageBuffer != NULL) {
        NSCIImageRep		*imageRep = [NSCIImageRep imageRepWithCIImage: [CIImage imageWithCVImageBuffer: imageBuffer]];
        
		image = [[[NSImage alloc] initWithSize: [imageRep size]] autorelease];
        [image addRepresentation:imageRep];
        CVBufferRelease(imageBuffer);
    }
	
	return image;
}

- (void) captureOutput:( QTCaptureOutput *) inCaptureOutput
	didOutputVideoFrame: (CVImageBufferRef) inVideoFrame 
	withSampleBuffer: (QTSampleBuffer *) inSampleBuffer
	fromConnection: (QTCaptureConnection *) inConnection
{
	_frameRecieved = YES;
	
    // Store the latest frame
	// This must be done in a @synchronized block because this delegate method is not called on the main thread
    CVImageBufferRef	imageBufferToRelease;
	
    CVBufferRetain(inVideoFrame);
    
    @synchronized (self) {
        imageBufferToRelease = _currentImageBuffer;
        _currentImageBuffer = inVideoFrame;
    }
    
    CVBufferRelease(imageBufferToRelease);
}

@end
