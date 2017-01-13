//
//  GADNativeCustomTemplateAd.h
//  Google Mobile Ads SDK
//
//  Copyright 2015 Google Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <GoogleMobileAds/GADAdLoaderDelegate.h>
#import <GoogleMobileAds/GADMediaView.h>
#import <GoogleMobileAds/GADNativeAd.h>
#import <GoogleMobileAds/GADNativeAdImage.h>
#import <GoogleMobileAds/GADVideoController.h>
#import <GoogleMobileAds/GoogleMobileAdsDefines.h>

GAD_ASSUME_NONNULL_BEGIN

/// Native custom template ad. To request this ad type, you need to pass
/// kGADAdLoaderAdTypeNativeCustomTemplate (see GADAdLoaderAdTypes.h) to the |adTypes| parameter in
/// GADAdLoader's initializer method. If you request this ad type, your delegate must conform to the
/// GADNativeCustomTemplateAdLoaderDelegate protocol.
@interface GADNativeCustomTemplateAd : GADNativeAd

/// The ad's custom template ID.
@property(nonatomic, readonly) NSString *templateID;

/// Array of available asset keys.
@property(nonatomic, readonly) NSArray *availableAssetKeys;

/// Returns video controller for controlling receiver's video. Returns nil if receiver doesn't
/// has a video.
@property(nonatomic, readonly, strong, GAD_NULLABLE) GADVideoController *videoController;

/// Returns media view for rendering video loaded by the receiver. Returns nil if receiver doesn't
/// has a video.
@property(nonatomic, readonly, strong, GAD_NULLABLE) GADMediaView *mediaView;

/// Returns the native ad image corresponding to the specified key or nil if the image is not
/// available.
- (GADNativeAdImage *GAD_NULLABLE_TYPE)imageForKey:(NSString *)key;

/// Returns the string corresponding to the specified key or nil if the string is not available.
- (NSString *GAD_NULLABLE_TYPE)stringForKey:(NSString *)key;

/// Call when the user clicks on the ad. Provide the asset key that best matches the asset the user
/// interacted with. Provide |customClickHandler| only if this template is configured with a custom
/// click action, otherwise pass in nil. If a block is provided, the ad's built-in click actions are
/// ignored and |customClickHandler| is executed after recording the click.
- (void)performClickOnAssetWithKey:(NSString *)assetKey
                customClickHandler:(dispatch_block_t GAD_NULLABLE_TYPE)customClickHandler;

/// Call when the ad is displayed on screen to the user. Can be called multiple times. Only the
/// first impression is recorded.
- (void)recordImpression;

@end

#pragma mark - Loading Protocol

/// The delegate of a GADAdLoader object implements this protocol to receive
/// GADNativeCustomTemplateAd ads.
@protocol GADNativeCustomTemplateAdLoaderDelegate<GADAdLoaderDelegate>

/// Called when requesting an ad. Asks the delegate for an array of custom template ID strings.
- (NSArray *)nativeCustomTemplateIDsForAdLoader:(GADAdLoader *)adLoader;

/// Tells the delegate that a native custom template ad was received.
- (void)adLoader:(GADAdLoader *)adLoader
    didReceiveNativeCustomTemplateAd:(GADNativeCustomTemplateAd *)nativeCustomTemplateAd;

@end

GAD_ASSUME_NONNULL_END
