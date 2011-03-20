//
//  PreferenceController.h
//  TransparentWebView
//
//  Created by Dirk van Oosterbosch on 24-02-11.
//  Copyright 2011 IR labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *const TWVShouldAutomaticReloadKey;
extern NSString *const TWVAutomaticReloadIntervalKey;
extern NSString *const TWVAutomaticReloadChangedNotification;


@interface PreferenceController : NSWindowController {
	IBOutlet NSButton		*autoRefreshCheckBox;
	IBOutlet NSSlider		*autoRefreshIntervalSlider;
	IBOutlet NSTextField	*autoRefreshIntervalValueLabel;
	
	IBOutlet NSTextField	*autoRefreshInfoLabel;
	IBOutlet NSTextField	*autoRefreshRightMark;
	IBOutlet NSTextField	*autoRefreshMiddleMark;
	IBOutlet NSTextField	*autoRefreshLeftMark;
	
	float lastSliderValue;
	NSMutableArray *sliderDeltas;
}

- (IBAction)changeAutomaticRefresh:(id)sender;
- (IBAction)changeAutoRefreshValue:(id)sender;

- (BOOL)shouldAutomaticReload;
- (int)automaticReloadInterval;
- (void)setAutomaticReloadEnabled:(BOOL)enabledState;
- (void)setAutomaticIntervalLabelValue:(int)seconds;

@end
