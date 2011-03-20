#import <WebKit/WebView.h>
#import <WebKit/WebFrame.h>
#import "WebViewWindow.h"

@implementation WebViewWindow
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
	//
	if( self = [super initWithContentRect:contentRect
								styleMask:aStyle//NSBorderlessWindowMask 
								  backing:bufferingType 
									defer:flag] ) {        
		[self setBackgroundColor: [NSColor clearColor]];
		[self setLevel: NSStatusWindowLevel];
		[self setAlphaValue: 1.0];
		[self setOpaque: NO];
		[self setHasShadow: NO];
	}
	return self;
}

- (void)awakeFromNib {
	NSLog(@"WebViewWindow awakes from Nib");
	[self setDrawsBackgroundSettings];
}

- (void)setDrawsBackgroundSettings {
	[thisWebView setDrawsBackground: NO];
	[self setView: thisWebView onWindow: self]; 
}

- (void)setView:(WebView*)view onWindow: (NSWindow*) window {
	//
	[view setFrameLoadDelegate:window];
	[view setUIDelegate:window];
	[view setResourceLoadDelegate:window];
	
	/*
	// NOW all performed in App Delegate:
	NSURL *url = [NSURL URLWithString:@"http://localhost:8080/"];
	NSURLRequest *urlReq = [NSURLRequest requestWithURL:url];

	WebFrame* webFrame = [view mainFrame];
	[webFrame loadRequest: urlReq];
	*/
}

@end
