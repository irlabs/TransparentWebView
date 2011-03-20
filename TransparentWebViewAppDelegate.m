//
//  TransparentWebViewAppDelegate.m
//  TransparentWebView
//
//  Created by Dirk van Oosterbosch on 22-12-10.
//  Copyright 2010 IR labs. All rights reserved.
//

#import "TransparentWebViewAppDelegate.h"
#import "WebViewWindow.h"
#import "PreferenceController.h"

NSString *const TWVLocationUrlKey = @"WebViewLocationUrl";
NSString *const TWVBorderlessWindowKey = @"OpenBorderlessWindow";
NSString *const TWVDrawCroppedUnderTitleBarKey = @"DrawCroppedUnderTitleBar";
NSString *const TWVMainTransparantWindowFrameKey = @"MainTransparentWindow";

CGFloat const titleBarHeight = 22.0f;

@implementation TransparentWebViewAppDelegate

@synthesize window, theWebView;
@synthesize borderlessWindowMenuItem, cropUnderTitleBarMenuItem;
@synthesize locationSheet, urlString;
@synthesize preferenceController;


- (id) init {
	[super init];
	
	// Register the Defaults in the Preferences
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	[defaultValues setObject:@"http://localhost/" forKey:TWVLocationUrlKey];
	[defaultValues setObject:[NSNumber numberWithBool:NO] forKey:TWVBorderlessWindowKey];
	[defaultValues setObject:[NSNumber numberWithBool:NO] forKey:TWVDrawCroppedUnderTitleBarKey];
	
	[defaultValues setObject:[NSNumber numberWithBool:NO] forKey:TWVShouldAutomaticReloadKey];
	[defaultValues setObject:[NSNumber numberWithInt:15] forKey:TWVAutomaticReloadIntervalKey];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
	
	// Set the url from the Preferences file
	self.urlString = [[NSUserDefaults standardUserDefaults] objectForKey:TWVLocationUrlKey];
	
	// Register for Preference Changes
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleAutomaticReloadChange:)
												 name:TWVAutomaticReloadChangedNotification
											   object:nil];
	
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	NSLog(@"TransparentWebView app got launched ...");
	[self loadUrlString:self.urlString IntoWebView:self.theWebView];
	
	// Deal with the borderless and crop under title bar settings
	BOOL borderlessState = [[[NSUserDefaults standardUserDefaults] objectForKey:TWVBorderlessWindowKey] boolValue];
	BOOL cropUnderTitleState = [[[NSUserDefaults standardUserDefaults] objectForKey:TWVDrawCroppedUnderTitleBarKey] boolValue];
	
	// Set the state of the menu items
	[self setBorderlessWindowMenuItemState:borderlessState];
	[self setCropUnderTitleBarMenuItemState:cropUnderTitleState];
	
	// Make us the delegate of the Main Window
	[window setDelegate:self];
	
	// Set the window type and the content frame
	if (borderlessState) {
		NSRect borderlessContentRect = [[window contentView] frame];
		if (cropUnderTitleState) {
			borderlessContentRect = [window frame];
		}
		[self replaceWindowWithBorderlessWindow:YES WithContentRect:borderlessContentRect];
	} else {
		if (cropUnderTitleState) {
			[self cropContentUnderTitleBar:YES];
		}
	}
	
	// Start a timer if the Transparent Web View is set to reload with a given interval
	[self resetAutomaticReloadTimer];
}

#pragma mark -
#pragma mark Location Sheet

- (IBAction)showLocationSheet:(id)sender {
	//
	[NSApp beginSheet:locationSheet
	   modalForWindow:window
		modalDelegate:nil
	   didEndSelector:NULL
		  contextInfo:NULL];
}


- (IBAction)endLocationSheet:(id)sender {
	
	// Return to normal event handling and hide the sheet
	[NSApp endSheet:locationSheet];
	[locationSheet orderOut:sender];
	
	// Save the location url in the Preferences
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:self.urlString forKey:TWVLocationUrlKey];
	
	NSLog(@"Load the url: %@", urlString);
	[self loadUrlString:self.urlString IntoWebView:self.theWebView];
}

- (IBAction)cancelLocationSheet:(id)sender {
	// Return to normal event handling and hide the sheet
	[NSApp endSheet:locationSheet];
	[locationSheet orderOut:sender];
}

/*
 * The method to load any url string into a web view of choice
 */
- (void)loadUrlString:(NSString *)anUrlString IntoWebView:(WebView *)aWebView {
	
	// Make an URL from the String, and then a Request from the URL
	NSURL *url = [NSURL URLWithString:anUrlString];
	NSURLRequest *urlReq = [NSURLRequest requestWithURL:url];
	
	// Get the webFrame and load the request
	WebFrame* webFrame = [aWebView mainFrame];
	[webFrame loadRequest: urlReq];
}


#pragma mark -
#pragma mark Preferences Panel

- (IBAction)showPreferencePanel:(id)sender {
	// Lazy loading
	if (self.preferenceController == nil) {
		PreferenceController *prefController = [[PreferenceController alloc] init];
		self.preferenceController = prefController;
		[prefController release];
	}
	NSLog(@"showing %@", preferenceController);
	[preferenceController showWindow:self];
}


- (void)handleAutomaticReloadChange:(NSNotification *)notification {
	//NSLog(@"Received Notification %@", notification);
	[self resetAutomaticReloadTimer];
}


- (void)resetAutomaticReloadTimer {
	// Invalidate the previousTimer
	if (automaticReloadTimer != nil) {
		[automaticReloadTimer invalidate];
		[automaticReloadTimer release];
		automaticReloadTimer = nil;
	}
	
	// Do we need a timer?
	if ( [[NSUserDefaults standardUserDefaults] boolForKey:TWVShouldAutomaticReloadKey] ) {
		// Create a new timer
		int reloadInterval = [[[NSUserDefaults standardUserDefaults] objectForKey:TWVAutomaticReloadIntervalKey] intValue];
		automaticReloadTimer = [[NSTimer scheduledTimerWithTimeInterval:reloadInterval
																 target:self
															   selector:@selector(reloadWebView:)
															   userInfo:nil
																repeats:YES] retain];
	}
}


- (void)reloadWebView:(NSTimer *)timer {
	// Reload the web view
	NSLog(@"Reload the web view");
	[self.theWebView reload:self];
}


#pragma mark -
#pragma mark Borderless Window

- (IBAction)toggleBorderlessWindow:(id)sender {
	
	// Toggle the borderless Window state:
	BOOL newState = ([borderlessWindowMenuItem state] == NSOffState);
	
	// Set the MenuItemState
	[self setBorderlessWindowMenuItemState:newState];
	
	// Save the borderless Window state in the Preferences
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[NSNumber numberWithBool:newState] forKey:TWVBorderlessWindowKey];
	
	// Create a new window and reload the content
	NSLog(@"Create a new %@ window", newState ? @"BORDERLESS" : @"BORDERED");
	
	BOOL cropUnderTitleState = [[[NSUserDefaults standardUserDefaults] objectForKey:TWVDrawCroppedUnderTitleBarKey] boolValue];

	NSRect newContentRect = [window frame];
	if (newState) {
		if (cropUnderTitleState) {
			[self cropContentUnderTitleBar:NO];
		} else {
			newContentRect.size.height = newContentRect.size.height - titleBarHeight;
		}
	} else {
		if (cropUnderTitleState) {
			[self cropContentUnderTitleBar:YES];
		} else {
			// Fix the window frame (not the content frame)
			NSRect theWindowFrame = [window frame];
			theWindowFrame.size.height = theWindowFrame.size.height + titleBarHeight;
			[window setFrame:theWindowFrame display:NO];
		}
	}
	
	[self replaceWindowWithBorderlessWindow:newState WithContentRect:newContentRect];
}

- (IBAction)toggleCropUnderTitleBar:(id)sender {

	// Toggle the Crop Under Title Bar state:
	BOOL newState = ([cropUnderTitleBarMenuItem state] == NSOffState);

	// Set the MenuItemState
	[self setCropUnderTitleBarMenuItemState:newState];

	// Save the Crop Under Title Bar state in the Preferences
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[NSNumber numberWithBool:newState] forKey:TWVDrawCroppedUnderTitleBarKey];
	
	// Perform the content cropping change
	[self cropContentUnderTitleBar:newState];
}


/*
 * Methods sets the UI properties according to the state of the Borderless Window
 */
- (void)setBorderlessWindowMenuItemState:(BOOL)booleanState {
	
	if (booleanState) {
		// YES BorderlessWindow
		NSLog(@"Set borderless!");
		[borderlessWindowMenuItem setState:NSOnState];
		[borderlessWindowMenuItem setTitle:@"Hide Borderless"];
		[cropUnderTitleBarMenuItem setEnabled:NO];
	} else {
		// NO BorderlessWindow
		NSLog(@"Set NOT borderless!");
		[borderlessWindowMenuItem setState:NSOffState];
		[borderlessWindowMenuItem setTitle:@"Show Borderless"];
		[cropUnderTitleBarMenuItem setEnabled:YES];
	}
}

- (void)setCropUnderTitleBarMenuItemState:(BOOL)booleanState {
	
	if (booleanState) {
		// YES CropUnderTitleBar
		[cropUnderTitleBarMenuItem setState:NSOnState];
	} else {
		// NO CropUnderTitleBar
		[cropUnderTitleBarMenuItem setState:NSOffState];
	}
}
	
- (void)replaceWindowWithBorderlessWindow:(BOOL)borderlessFlag WithContentRect:(NSRect)contentRect {

	// Save the previous frame (to file and to string)
	[window saveFrameUsingName:TWVMainTransparantWindowFrameKey];
	NSString *savedFrameString = [window stringWithSavedFrame];
	
	// Get a pointer to the old window
	NSWindow *oldWindow = window;
	
	// Make the windowstyle
	NSUInteger newStyle;
	if (borderlessFlag) {
		newStyle = NSBorderlessWindowMask;
	} else {
		newStyle = NSTitledWindowMask |	NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask;
	}
	
	// Create the new window
	self.window = [[WebViewWindow alloc] initWithContentRect:contentRect
												   styleMask:newStyle
													 backing:NSBackingStoreBuffered
													   defer:NO];

	// Set the properties (as also set in Interface Builder)
	[window setContentView:[oldWindow contentView]];
	[window setTitle:@"Transparent Web View"];
	[window setFrameAutosaveName:TWVMainTransparantWindowFrameKey];

	// Restore the frame from the one save above
	[window setFrameFromString:savedFrameString];
	
	// Set us as the delegate
	[window setDelegate:self];

	// Order front (Show the Window)
	[window makeKeyAndOrderFront:self];
	
	// Call the same window as awakeFromNib would have
	[(WebViewWindow *)window setDrawsBackgroundSettings];
	
	// Close the old window
	[oldWindow close];
}

- (void)cropContentUnderTitleBar:(BOOL)cropUnderTitleFlag {
	// Set the new frame of the web view
	
	// The origin.y is measured from the bottom, so we only have to set the height	
	//		newFrame.origin.y = newFrame.origin.y + titleBarHeight;
	
	// Get the current frame of the WebView
	NSRect newFrame = theWebView.frame;

	// Change the frame 
	if (cropUnderTitleFlag) {
		newFrame.size.height = newFrame.size.height + titleBarHeight;
	} else {
		newFrame.size.height = newFrame.size.height - titleBarHeight;
	}
	
	// Set the frame back to the web view
	[theWebView setFrame:newFrame];
}

#pragma mark -
#pragma mark NSWindow Delegate Methods

- (void)windowDidResize:(NSNotification *)notification {
	// Save the frame (since it wasn't working out of the box on our own created windows)
	[window saveFrameUsingName:TWVMainTransparantWindowFrameKey];

}

- (void)windowDidMove:(NSNotification *)notification {
	// Save the frame (since it wasn't working out of the box on our own created windows)
	[window saveFrameUsingName:TWVMainTransparantWindowFrameKey];
}

#pragma mark -

- (void)dealloc {
	[urlString release];
	[preferenceController release];
	[automaticReloadTimer invalidate];
	[automaticReloadTimer release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
