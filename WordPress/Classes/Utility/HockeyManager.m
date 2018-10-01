#import "HockeyManager.h"

#ifdef HOCKEYAPP_ENABLED
@import HockeySDK;

#import "ApiCredentials.h"
#import "WordPressAppDelegate.h"
#import "WPLogger.h"

@interface HockeyManager () <BITHockeyManagerDelegate>
@end

@implementation HockeyManager

- (void)configure {
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:[ApiCredentials hockeyappAppId]
                                                           delegate:self];
    [[BITHockeyManager sharedHockeyManager].authenticator setIdentificationType:BITAuthenticatorIdentificationTypeDevice];
    [[BITHockeyManager sharedHockeyManager].updateManager setUpdateSetting: BITUpdateCheckDaily]; // Set up daily notifications on notmandatory updates
    [[BITHockeyManager sharedHockeyManager].updateManager setShowDirectInstallOption: true]; // Show the "direct update" button in the update dialog
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];

    // NB: Relocated this call as per https://github.com/bitstadium/HockeySDK-iOS/issues/517
    [[BITHockeyManager sharedHockeyManager] setDisableCrashManager: YES]; //disable crash reporting
}

- (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    NSString *sourceApplication = [options stringForKey:UIApplicationLaunchOptionsSourceApplicationKey];
    id annotation = [options objectForKey:UIApplicationLaunchOptionsAnnotationKey];

    return [[BITHockeyManager sharedHockeyManager].authenticator handleOpenURL:url
                                                          sourceApplication:sourceApplication
                                                                    annotation:annotation];

}

- (NSString *)applicationLogForCrashManager:(BITCrashManager *)crashManager
{
    WPLogger *logger = [[WordPressAppDelegate sharedInstance] logger];
    NSString *description = [logger getLogFilesContentWithMaxSize:5000]; // 5000 bytes should be enough!
    if ([description length] == 0) {
        return nil;
    }

    return description;
}

@end

#else

@implementation HockeyManager

- (void)configure {
}

- (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    return NO;
}

@end

#endif
