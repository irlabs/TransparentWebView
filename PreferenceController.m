//
//  PreferenceController.m
//  TransparentWebView
//
//  Created by Dirk van Oosterbosch on 24-02-11.
//  Copyright 2011 IR labs. All rights reserved.
//

#import "PreferenceController.h"

NSString *const TWVShouldAutomaticReloadKey = @"shouldAutomaticRelaod";
NSString *const TWVAutomaticReloadIntervalKey = @"automaticReloadInterval";
NSString *const TWVAutomaticReloadChangedNotification = @"TWVautomaticReloadChanged";


@implementation PreferenceController

- (id)init {
	if (![super initWithWindowNibName:@"Preferences"]) {
		return nil;
	}
	lastSliderValue = 0.0f;
	sliderDeltas = [[NSMutableArray alloc] init]; // Measure the last 5 deltas
	return self;
}


- (BOOL)shouldAutomaticReload {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults boolForKey:TWVShouldAutomaticReloadKey];
}


- (int)automaticReloadInterval {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults integerForKey:TWVAutomaticReloadIntervalKey];
}


- (void)windowDidLoad {
	BOOL shouldReloadState = [self shouldAutomaticReload];
	[autoRefreshCheckBox setState:shouldReloadState];
	[self setAutomaticReloadEnabled:shouldReloadState];
	int intervalSeconds = [self automaticReloadInterval];
	lastSliderValue = powf(intervalSeconds / (180.0 * 60.0), (1 / 2.0));
	[autoRefreshIntervalSlider setFloatValue:lastSliderValue];
	[self setAutomaticIntervalLabelValue:intervalSeconds];
}


- (void)setAutomaticReloadEnabled:(BOOL)enabledState {
	if (enabledState) {
		// On
		[autoRefreshIntervalSlider setEnabled:YES];
		[autoRefreshIntervalValueLabel setAlphaValue:1.0f];
		[autoRefreshInfoLabel setAlphaValue:1.0f];
		[autoRefreshRightMark setAlphaValue:1.0f];
		[autoRefreshMiddleMark setAlphaValue:1.0f];
		[autoRefreshLeftMark setAlphaValue:1.0f];
	} else {
		// Off
		[autoRefreshIntervalSlider setEnabled:NO];
		[autoRefreshIntervalValueLabel setAlphaValue:0.4f];
		[autoRefreshInfoLabel setAlphaValue:0.4f];
		[autoRefreshRightMark setAlphaValue:0.4f];
		[autoRefreshMiddleMark setAlphaValue:0.4f];
		[autoRefreshLeftMark setAlphaValue:0.4f];
	}
}

- (void)setAutomaticIntervalLabelValue:(int)secondsValue {
	int minutes = secondsValue / 60;
	int seconds = secondsValue - (minutes * 60);
	[autoRefreshIntervalValueLabel setStringValue:[NSString stringWithFormat:@"%d'%02d\" minutes", minutes, seconds]];
}


- (IBAction)changeAutomaticRefresh:(id)sender {
	int state = [autoRefreshCheckBox state];
	[self setAutomaticReloadEnabled:state];
	
	// Set the value in the Defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:state forKey:TWVShouldAutomaticReloadKey];
	
	// Send a notification
	[[NSNotificationCenter defaultCenter] postNotificationName:TWVAutomaticReloadChangedNotification object:self];
}


- (IBAction)changeAutoRefreshValue:(id)sender {
	float sliderValue = [autoRefreshIntervalSlider floatValue];
	float exponentialSeconds = (powf(sliderValue, 2.0)) * (180.0 * 60.0);
	float deltaSlider = fabsf(sliderValue - lastSliderValue);
	// Remembering the last 5 deltas
	float formerDeltaSlider = deltaSlider;
	if ([sliderDeltas count] > 0) {
		formerDeltaSlider = [[sliderDeltas lastObject] floatValue];
	}
	//NSLog(@"deltaSlider: %f formerDeltaSlider: %f %d deltas", deltaSlider, formerDeltaSlider, [sliderDeltas count]);
	if ([sliderDeltas count] > 6) {
		[sliderDeltas removeLastObject];
	}
	[sliderDeltas insertObject:[NSNumber numberWithFloat:deltaSlider] atIndex:0];
	int totalSeconds;
	if (formerDeltaSlider > 0.01) {
		// Round on 10 minutes
		totalSeconds = (roundf(exponentialSeconds / 600.0)) * 600;
	} else if (formerDeltaSlider > 0.002) {
		// Round on minutes
		totalSeconds = (roundf(exponentialSeconds / 60.0)) * 60;
//	} else if (formerDeltaSlider > 0.0004) {
	} else {
		// Round on 5 seconds
		totalSeconds = (roundf(exponentialSeconds / 5.0)) * 5;
//		// Round on single seconds
//		totalSeconds = roundf(exponentialSeconds);
	}
	[self setAutomaticIntervalLabelValue:totalSeconds];
	lastSliderValue = sliderValue;

	// Set the value in the Defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[NSNumber numberWithInt:totalSeconds] forKey:TWVAutomaticReloadIntervalKey];
	
	// Send a notification
	[[NSNotificationCenter defaultCenter] postNotificationName:TWVAutomaticReloadChangedNotification object:self];
}


- (void)dealloc {
	[sliderDeltas release];
	[super dealloc];
}

@end
