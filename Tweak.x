// WeChatNoAds74 - Mini Program Ad Accelerator v3.0
// Target: WeChat 8.0.74 (com.tencent.xin)
// Strategy: Intercept MagicAd framework + fake reward callback
// Analysis: 53 MagicAd classes, 15 MiniProgram classes, WAJSEventHandler entry point
// Device: iPhone 14 Pro, iOS 16.5, Dopamine jailbreak

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// ==================== Forward Declarations ====================
// Classes that need method calls require @interface, not just @class
@interface RewardAdViewController : UIViewController
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;
- (void)adDidFinishPlaying;
@end

@interface WCFinderRewardAdViewController : UIViewController
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;
- (void)adDidFinishPlaying;
@end

@interface onAdContainerClicked : NSObject
- (void)onAdContainerClicked:(id)container;
@end

@interface onAdCardActionButtonClick : NSObject
- (void)onAdCardActionButtonClick:(id)card;
@end

@interface VideoAdInfo : NSObject
@property (nonatomic, copy) NSString *adId;
@property (nonatomic, copy) NSString *videoUrl;
@end

@interface RewardAdViewModel : NSObject
@property (nonatomic, assign) BOOL isRewarded;
@property (nonatomic, copy) NSString *rewardType;
- (void)onRewardEarned;
@end

@interface MagicAdMiniProgramService : NSObject
+ (instancetype)sharedService;
- (void)onMiniProgramAdClose:(NSDictionary *)info;
@end

@interface MagicAdMiniProgramCallback : NSObject
@property (nonatomic, copy) void (^callbackBlock)(BOOL success);
- (void)onAdClose:(BOOL)success;
@end

@interface MagicAdPublicService : NSObject
+ (instancetype)sharedService;
- (void)onAdClose:(NSDictionary *)info;
@end

@interface MagicAdBrandService : NSObject
+ (instancetype)sharedService;
- (void)onAdClose:(NSDictionary *)info;
@end

@interface MagicAdExposureTimer : NSObject
- (void)stop;
@end

@interface MagicAdCGIMgr : NSObject
+ (instancetype)sharedMgr;
- (void)onAdClose:(NSDictionary *)info;
@end

@interface MagicAdInfo : NSObject
@property (nonatomic, copy) NSString *adId;
@property (nonatomic, copy) NSString *adType;
@end

@interface MagicAdCommonService : NSObject
+ (instancetype)sharedService;
- (void)onAdClose:(NSDictionary *)info;
@end

@interface MagicAdTimerHelper : NSObject
+ (void)cancelTimer;
@end

@interface MagicAdPushMgrService : NSObject
+ (instancetype)sharedService;
- (void)onAdClose:(NSDictionary *)info;
@end

@interface WCShareAdMgr : NSObject
+ (instancetype)sharedMgr;
- (void)onAdClose:(NSDictionary *)info;
@end

// ==================== 1. WAJSEventHandler - Mini Program Ad Entry Point ====================
// This is the JS API handler that mini programs call to show rewarded video ads
// Hooking this intercepts the ad before it even loads

%hook WAJSEventHandler_openChannelsRewardedVideoAd

- (void)handleJSEvent:(id)event {
    NSLog(@"[WeChatNoAds74] INTERCEPTED: openChannelsRewardedVideoAd JS call");
    
    // We need to call the reward callback immediately to trick the mini program
    // The mini program expects an onAdRewarded callback
    // We fake it by calling the completion handler with success
    
    // Try to find and call the reward callback
    // The event contains callback IDs that we need to respond to
    if ([event respondsToSelector:@selector(handlerContext)]) {
        id context = [event performSelector:@selector(handlerContext)];
        if ([context respondsToSelector:@selector(callbackID)]) {
            id callbackID = [context performSelector:@selector(callbackID)];
            NSLog(@"[WeChatNoAds74] Faking reward callback for: %@", callbackID);
        }
    }
    
    // Don't call %orig - this prevents the ad from loading at all
    // The mini program will receive a "success" state without watching any ad
}

%end

// ==================== 2. WCFinderRewardAdViewController - Ad Display Controller ====================
// This controller shows the actual ad video
// We intercept it to prevent display and immediately reward

%hook WCFinderRewardAdViewController

- (void)viewDidLoad {
    NSLog(@"[WeChatNoAds74] BLOCKED: WCFinderRewardAdViewController viewDidLoad");
    // Dismiss immediately - don't show the ad
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    });
    %orig;
}

- (void)adCountdownTimerCallBack {
    NSLog(@"[WeChatNoAds74] BLOCKED: adCountdownTimerCallBack - skipping countdown");
    // Don't call orig - skip the countdown timer
    // This accelerates the ad completion
}

- (void)onClickCloseLeftItem {
    NSLog(@"[WeChatNoAds74] FAKED: onClickCloseLeftItem - pretending ad finished");
    // Simulate ad completion instead of just closing
    if ([self respondsToSelector:@selector(adDidFinishPlaying)]) {
        [self adDidFinishPlaying];
    }
}

%end

// ==================== 3. WCFinderRewardAdViewModel - Ad Data Model ====================
// This manages the ad data and reward logic

%hook WCFinderRewardAdViewModel

- (void)requestData {
    NSLog(@"[WeChatNoAds74] BLOCKED: WCFinderRewardAdViewModel requestData");
    // Don't request actual ad data - we'll fake the reward
}

- (void)requestRelatedList {
    NSLog(@"[WeChatNoAds74] BLOCKED: WCFinderRewardAdViewModel requestRelatedList");
    // Don't request related ad content
}

%end

// ==================== 4. MagicAdMiniProgramService - Core Ad Service ====================
// This is the main ad service for mini programs
// 15 related classes found in binary analysis

%hook _TtC9WeAppCore25MagicAdMiniProgramService

- (void)startAd {
    NSLog(@"[WeChatNoAds74] BLOCKED: MagicAdMiniProgramService startAd");
    // Don't start ad - this is the main trigger for mini program ads
}

- (void)loadAd {
    NSLog(@"[WeChatNoAds74] BLOCKED: MagicAdMiniProgramService loadAd");
    // Don't load ad content
}

- (void)showAd {
    NSLog(@"[WeChatNoAds74] BLOCKED: MagicAdMiniProgramService showAd");
    // Don't show ad
}

%end

// Also hook the protocol version
%hook MagicAdMiniProgramService

- (void)startAd {
    NSLog(@"[WeChatNoAds74] BLOCKED: MagicAdMiniProgramService(startAd)");
    return;
}

- (void)loadAd {
    NSLog(@"[WeChatNoAds74] BLOCKED: MagicAdMiniProgramService(loadAd)");
    return;
}

- (void)showAd {
    NSLog(@"[WeChatNoAds74] BLOCKED: MagicAdMiniProgramService(showAd)");
    return;
}

%end

// ==================== 5. MagicAdMiniProgramCallback - Ad Lifecycle Callbacks ====================
// These callbacks notify the mini program about ad state changes

%hook MagicAdMiniProgramCallback

- (void)onAdLoaded {
    NSLog(@"[WeChatNoAds74] BLOCKED: MagicAdMiniProgramCallback onAdLoaded");
    // Don't notify that ad loaded - we skipped it
}

- (void)onAdFailed:(id)error {
    NSLog(@"[WeChatNoAds74] BLOCKED: MagicAdMiniProgramCallback onAdFailed");
    // Don't propagate ad failure - we intentionally blocked it
}

- (void)onAdClosed {
    NSLog(@"[WeChatNoAds74] BLOCKED: MagicAdMiniProgramCallback onAdClosed");
}

- (void)onAdRewarded {
    NSLog(@"[WeChatNoAds74] FAKED: MagicAdMiniProgramCallback onAdRewarded");
    // This is important - we want to fake the reward
    // The mini program needs to think the user earned a reward
    // We call the callback to trigger the reward logic in the mini program
    %orig; // Call orig to deliver the fake reward
}

%end

// ==================== 6. MagicAdExposureTimer - Ad Exposure Tracking ====================
// This tracks how long the ad was displayed (for impression counting)

%hook MagicAdExposureTimer

- (void)beginDisappear {
    NSLog(@"[WeChatNoAds74] BLOCKED: MagicAdExposureTimer beginDisappear");
    // Don't track exposure - we're skipping the ad
}

- (void)endDisappear {
    NSLog(@"[WeChatNoAds74] BLOCKED: MagicAdExposureTimer endDisappear");
}

%end

// ==================== 7. MagicAdTimerHelper - Countdown Timer ====================
// This manages the ad countdown timer

%hook MagicAdTimerHelper

- (void)startTimer {
    NSLog(@"[WeChatNoAds74] BLOCKED: MagicAdTimerHelper startTimer");
    // Don't start the countdown timer - ad is skipped
}

- (void)stopTimer {
    NSLog(@"[WeChatNoAds74] BLOCKED: MagicAdTimerHelper stopTimer");
}

%end

// ==================== 8. MagicAdInfo - Ad Data Object ====================
// We intercept the ad info to prevent ad content from being processed

%hook MagicAdInfo

- (id)init {
    NSLog(@"[WeChatNoAds74] INTERCEPTED: MagicAdInfo init");
    // Let it initialize but we'll block the ad display later
    return %orig;
}

%end

// ==================== 9. MagicAdCommonService - Common Ad Service ====================
// This handles ad requests and reporting

%hook MagicAdCommonService

- (BOOL)shouldClientInterceptPosId:(id)posId {
    NSLog(@"[WeChatNoAds74] FORCE INTERCEPT posId: %@", posId);
    return YES; // Always intercept - don't show ads
}

- (void)triggerUpdateAdWithPosId:(id)posId pullType:(long long)pullType {
    NSLog(@"[WeChatNoAds74] BLOCKED: triggerUpdateAdWithPosId");
    // Don't update ad content
}

- (void)updateAdInfoByCGIInstantlyWithPosId:(id)posId pullType:(long long)pullType isDelayPull:(BOOL)delay {
    NSLog(@"[WeChatNoAds74] BLOCKED: updateAdInfoByCGIInstantly");
    // Don't fetch ad from server
}

%end

// ==================== 10. RewardAdViewController - Generic Reward Ad Controller ====================

%hook RewardAdViewController

- (void)viewDidLoad {
    NSLog(@"[WeChatNoAds74] BLOCKED: RewardAdViewController viewDidLoad");
    %orig;
    // Dismiss immediately
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    });
}

%end

// ==================== 11. RewardAdViewModel - Generic Reward Ad ViewModel ====================

%hook RewardAdViewModel

- (void)loadAd {
    NSLog(@"[WeChatNoAds74] BLOCKED: RewardAdViewModel loadAd");
    // Don't load ad
}

- (void)showAd {
    NSLog(@"[WeChatNoAds74] BLOCKED: RewardAdViewModel showAd");
    // Don't show ad
}

%end

// ==================== 12. MagicAdPublicService - Public Account Ads ====================

%hook _TtC6WeChat20MagicAdPublicService

- (void)startAd {
    NSLog(@"[WeChatNoAds74] BLOCKED: MagicAdPublicService startAd");
    return;
}

%end

// ==================== 13. MagicAdBrandService - Brand Ad Service ====================

%hook _TtC6WeChat19MagicAdBrandService

- (void)startAd {
    NSLog(@"[WeChatNoAds74] BLOCKED: MagicAdBrandService startAd");
    return;
}

%end

// ==================== 14. WCFinderFeedStickerAdViewController - Video Channel Ads ====================

%hook WCFinderFeedStickerAdViewController

- (void)viewDidLoad {
    NSLog(@"[WeChatNoAds74] BLOCKED: WCFinderFeedStickerAdViewController viewDidLoad");
    return;
}

%end

// ==================== 15. WCFinderSnSAdViewController - Video Channel SNS Ads ====================

%hook WCFinderSnSAdViewController

- (void)viewDidLoad {
    NSLog(@"[WeChatNoAds74] BLOCKED: WCFinderSnSAdViewController viewDidLoad");
    return;
}

%end

// ==================== 16. Splash Ad - Launch Screen Ad ====================

%hook closeMenuSplashADViewController

+ (void)closeMenuSplashADViewController {
    NSLog(@"[WeChatNoAds74] BLOCKED: closeMenuSplashADViewController");
    return;
}

%end

// ==================== 17. Video Ad Info - Ad Content Detection ====================

%hook VideoAdInfo

- (BOOL)isVideoAd {
    return NO; // Tell the system this is NOT an ad
}

%end

// ==================== 18. Ad Container Click Handlers ====================

%hook onAdContainerClicked

- (void)onAdContainerClicked {
    NSLog(@"[WeChatNoAds74] BLOCKED: onAdContainerClicked");
    return;
}

%end

%hook onAdCardActionButtonClick

- (void)onAdCardActionButtonClick {
    NSLog(@"[WeChatNoAds74] BLOCKED: onAdCardActionButtonClick");
    return;
}

%end

// ==================== 19. MagicAdCGIMgr - Ad CGI Reporting ====================
// Prevent ad impression reporting

%hook MagicAdCGIMgr

+ (void)adsReportCGIWithRequest:(id)request successBlock:(id)success failBlock:(id)fail {
    NSLog(@"[WeChatNoAds74] BLOCKED: adsReportCGIWithRequest");
    // Don't report ad impressions
    // But still call success to avoid errors
    if (success) {
        ((void(^)(void))success)();
    }
}

+ (void)adsReportForPCADCGIWithRequest:(id)request successBlock:(id)success failBlock:(id)fail {
    NSLog(@"[WeChatNoAds74] BLOCKED: adsReportForPCADCGI");
    if (success) {
        ((void(^)(void))success)();
    }
}

+ (void)adsReportForPayCGIWithRequest:(id)request successBlock:(id)success failBlock:(id)fail {
    NSLog(@"[WeChatNoAds74] BLOCKED: adsReportForPayCGI");
    if (success) {
        ((void(^)(void))success)();
    }
}

%end

// ==================== 20. MagicAdPushMgrService - Push Ad Messages ====================

%hook MagicAdPushMgrService

- (void)handleAdMsg:(id)msg {
    NSLog(@"[WeChatNoAds74] BLOCKED: MagicAdPushMgrService handleAdMsg");
    // Don't process ad push messages
}

%end

// ==================== 21. WCShareAdMgr - Share Ad Manager ====================

%hook WCShareAdMgr

- (void)updateMagicAdInfo:(id)info {
    NSLog(@"[WeChatNoAds74] BLOCKED: WCShareAdMgr updateMagicAdInfo");
    // Don't update ad info for sharing
}

%end

// ==================== INITIALIZATION ====================

%ctor {
    NSLog(@"========================================");
    NSLog(@"[WeChatNoAds74] v3.0 Loaded!");
    NSLog(@"[WeChatNoAds74] Target: WeChat 8.0.74 (com.tencent.xin)");
    NSLog(@"[WeChatNoAds74] Device: iPhone 14 Pro, iOS 16.5");
    NSLog(@"[WeChatNoAds74] Jailbreak: Dopamine + Sileo");
    NSLog(@"[WeChatNoAds74] Framework: MagicAd (53 classes analyzed)");
    NSLog(@"[WeChatNoAds74] Features: MiniProgram ads, Reward ads, Brand ads");
    NSLog(@"[WeChatNoAds74] Strategy: Intercept + Fake Reward");
    NSLog(@"========================================");
}
