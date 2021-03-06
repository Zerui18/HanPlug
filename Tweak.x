#import <AVFoundation/AVFoundation.h>

@interface NSUserDefaults (Tweak_Category)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

static NSString * nsDomainString = @"com.zx02.hanplug";
static NSString * nsNotificationString = @"com.zx02.hanplug/preferences.changed";
static bool enabled;

static AVAudioPlayer *pluggedPlayer;
static AVAudioPlayer *unpluggedPlayer;
static id observer;

static void playSound(bool isPlugged) {
	if (!enabled) return;
	[pluggedPlayer stop];
	[unpluggedPlayer stop];
	if (isPlugged) {
		pluggedPlayer.currentTime = 0;
		[pluggedPlayer play];
	}
	else {
		unpluggedPlayer.currentTime = 0;
		[unpluggedPlayer play];
	}
}

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	NSNumber * enabledValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled" inDomain:nsDomainString];
	enabled = (enabledValue)? [enabledValue boolValue] : true;

	if (enabled) {
		// Begin observation.
		observer = (__bridge void *)[NSNotificationCenter.defaultCenter addObserverForName: UIDeviceBatteryStateDidChangeNotification 
			object: nil
			queue: nil
			usingBlock: ^(NSNotification* notification) {
				long currentBatteryState = UIDevice.currentDevice.batteryState;
				// Unplugged.
				if (currentBatteryState == UIDeviceBatteryStateUnplugged) {
					playSound(false);
				}
				// Plugged-in.
				else if (currentBatteryState == UIDeviceBatteryStateCharging || currentBatteryState == UIDeviceBatteryStateFull) {
					playSound(true);
				}
		}];
	}
	else {
		// Remove observer if found.
		if (observer)
			[NSNotificationCenter.defaultCenter removeObserver: (__bridge id _Nonnull) observer];
	}
}

%ctor {
	// Prepare players.
	pluggedPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: [NSURL fileURLWithPath: @"/Library/PreferenceLoader/Preferences/HanPlug/plugged.mp3"] error: nil];
	unpluggedPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: [NSURL fileURLWithPath: @"/Library/PreferenceLoader/Preferences/HanPlug/unplugged.mp3"] error: nil];

	notificationCallback(NULL, NULL, NULL, NULL, NULL);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, notificationCallback, (CFStringRef)nsNotificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);
}
