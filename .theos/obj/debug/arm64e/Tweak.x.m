#line 1 "Tweak.x"
@interface NSUserDefaults (Tweak_Category)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

static NSString * nsDomainString = @"com.zx02.hanplug";
static NSString * nsNotificationString = @"com.zx02.hanplug/preferences.changed";
static BOOL enabled;

static id observer = NULL;
static long lastBatteryState = -999;

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	NSNumber * enabledValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled" inDomain:nsDomainString];
	enabled = (enabledValue)? [enabledValue boolValue] : YES;

	if (enabled) {
		
		observer = [NSNotificationCenter.defaultCenter addObserverForName: UIDeviceBatteryStateDidChangeNotification 
			object: nil
			queue: DispatchQueue.mainQueue
			usingBlock: ^(NSNotification* notification) {
				
				if (UIDevice.currentDevice.batteryState != lastBatteryState) {
					
					if (UIDevice.currentDevice.batteryState == UIDeviceBatteryStateUnplugged) {

					}
					
					else if (UIDevice.currentDevice.batteryState == UIDeviceBatteryStateCharging) {

					}
				}
		}];
	}
	else {
		
		if (observer)
			[NSNotificationCenter.defaultCenter removeObserver: observer];
	}
}

static __attribute__((constructor)) void _logosLocalCtor_9d1dd3f5(int __unused argc, char __unused **argv, char __unused **envp) {
	notificationCallback(NULL, NULL, NULL, NULL, NULL);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, notificationCallback, (CFStringRef)nsNotificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);
}
