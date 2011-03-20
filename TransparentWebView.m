#import <WebKit/WebView.h>
#import <WebKit/WebFrame.h>
#import "TransparentWebView.h"

@implementation TransparentWebView
- (id)initWithFrame:(NSRect)frameRect frameName:(NSString *)frameName groupName:(NSString *)groupName
{
	if(self = [super initWithFrame:frameRect frameName:frameName groupName:groupName]){
		[self setDrawsBackground:NO];
		return self;
	}
	return nil;
}
@end
