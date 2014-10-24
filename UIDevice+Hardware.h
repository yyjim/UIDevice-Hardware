/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 
 Modified by yyjim on 12/31/13
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, UIDeviceFamily) {
    UIDeviceFamilyiPhone,
    UIDeviceFamilyiPod,
    UIDeviceFamilyiPad,
    UIDeviceFamilyAppleTV,
    UIDeviceFamilyUnknown,
};

typedef NS_ENUM(NSUInteger, UIDeviceMemoryClass) {
    UIDeviceMemoryClassLow,           // < 512MB
    UIDeviceMemoryClassMedium,        // >= 512MB
    UIDeviceMemoryClassHigh,          // >= 1GMB
    UIDeviceMemoryClassUnknown
};

typedef NS_ENUM(NSUInteger, UIDeviceModelType) {
    UIDeviceUnknown,
    
    UIDeviceiPhoneSimulator,
    UIDeviceiPhoneSimulatoriPhone,
    UIDeviceiPhoneSimulatoriPad,
    
    UIDevice1GiPhone,
    UIDevice3GiPhone,
    UIDevice3GSiPhone,
    UIDevice4iPhone,
    UIDevice4SiPhone,
    UIDevice5iPhone,
    UIDevice5CiPhone,
    UIDevice5SiPhone,
    UIDevice6iPhone,
    UIDevice6PlusiPhone,
    
    UIDevice1GiPod,
    UIDevice2GiPod,
    UIDevice3GiPod,
    UIDevice4GiPod,
    UIDevice5GiPod,
    
    UIDevice1GiPad,
    UIDevice2GiPad,
    UIDevice3GiPad,
    UIDevice4GiPad,
    
    UIDevice1GiPadMini,
    UIDevice2GiPadMini,
    
    UIDeviceAppleTV2,
    UIDeviceUnknownAppleTV,
    
    UIDeviceUnknowniPhone,
    UIDeviceUnknowniPod,
    UIDeviceUnknowniPad,
    UIDeviceIFPGA,
};

@interface UIDevice (Hardware)

/**
 Returns a machine-readable model name in the format of "iPhone4,1"
 */
- (NSString *)modelIdentifier;

/**
 Returns a human-readable model name in the format of "iPhone 4S". Fallback of the the `modelIdentifier` value.
 */
- (NSString *)modelName;

/**
 Returns the defined type as a `UIDeviceModelType`
 */
- (UIDeviceModelType)deviceType;

/**
 Returns the memory class as a `UIDeviceMemoryClass`
 */
- (UIDeviceMemoryClass)deviceMemoryClass;

/**
 Returns the device family as a `UIDeviceFamily`
 */
- (UIDeviceFamily)deviceFamily;

- (NSString *)hwmodel;
- (NSUInteger)cpuFrequency;
- (NSUInteger)busFrequency;
- (NSUInteger)totalMemory;
- (NSUInteger)userMemory;

- (NSNumber *)totalDiskSpace;
- (NSNumber *)freeDiskSpace;

- (NSString *)macaddress;
@end