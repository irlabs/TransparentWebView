
#import <Cocoa/Cocoa.h>

@interface WebViewWindow : NSWindow
{
   IBOutlet WebView* thisWebView;
}

- (void)setDrawsBackgroundSettings;
- (void)setView:(WebView*)view onWindow: (NSWindow*) window;
@end
