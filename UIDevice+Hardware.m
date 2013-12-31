/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 6.x Edition
 BSD License, Use at your own risk
 
 Modified by yyjim on 12/31/13
 */

// Thanks to Emanuele Vulcano, Kevin Ballard/Eridius, Ryandjohnson, Matt Brown, etc.

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "UIDevice+Hardware.h"

@implementation UIDevice (Hardware)

#pragma mark - Sysctlbyname utils
- (NSString *)getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

- (NSString *)modelIdentifier
{
    return [self getSysInfoByName:"hw.machine"];
}

- (NSString *)modelName
{
    return [self modelNameForModelIdentifier:[self modelIdentifier]];
}

// Thanks, Tom Harrington (Atomicbird)
- (NSString *)hwmodel
{
    return [self getSysInfoByName:"hw.model"];
}

#pragma mark - Sysctl utils
- (NSUInteger)getSysInfo:(uint)typeSpecifier
{
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results;
}

- (NSUInteger)cpuFrequency
{
    return [self getSysInfo:HW_CPU_FREQ];
}

- (NSUInteger)busFrequency
{
    return [self getSysInfo:HW_BUS_FREQ];
}

- (NSUInteger)totalMemory
{
    return [self getSysInfo:HW_PHYSMEM];
}

- (NSUInteger)userMemory
{
    return [self getSysInfo:HW_USERMEM];
}

- (NSUInteger)maxSocketBufferSize
{
    return [self getSysInfo:KIPC_MAXSOCKBUF];
}

#pragma mark - File system -- Thanks Joachim Bean!

- (NSNumber *)totalDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemSize];
}

- (NSNumber *)freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeSize];
}

#pragma mark - Platform type and name utils

- (UIDeviceFamily)deviceFamily
{
    NSString *modelIdentifier = [self modelIdentifier];
    if ([modelIdentifier hasPrefix:@"iPhone"]) return UIDeviceFamilyiPhone;
    if ([modelIdentifier hasPrefix:@"iPod"]) return UIDeviceFamilyiPod;
    if ([modelIdentifier hasPrefix:@"iPad"]) return UIDeviceFamilyiPad;
    return UIDeviceFamilyUnknown;
}

- (UIDeviceModelType)deviceType
{
    NSString *modelIdentifier = [self modelIdentifier];
    
    // The ever mysterious iFPGA
    if ([modelIdentifier isEqualToString:@"iFPGA"])        return UIDeviceIFPGA;
    
    // iPhone http://theiphonewiki.com/wiki/IPhone
    
    if ([modelIdentifier isEqualToString:@"iPhone1,1"])    return UIDevice1GiPhone;
    if ([modelIdentifier isEqualToString:@"iPhone1,2"])    return UIDevice3GiPhone;
    if ([modelIdentifier hasPrefix:@"iPhone2"])            return UIDevice3GSiPhone;
    if ([modelIdentifier hasPrefix:@"iPhone3"])            return UIDevice4iPhone;
    if ([modelIdentifier hasPrefix:@"iPhone4"])            return UIDevice4SiPhone;
    if ([modelIdentifier isEqualToString:@"iPhone5,1"])    return UIDevice5iPhone;
    if ([modelIdentifier isEqualToString:@"iPhone5,2"])    return UIDevice5iPhone;
    if ([modelIdentifier isEqualToString:@"iPhone5,3"])    return UIDevice5CiPhone;
    if ([modelIdentifier isEqualToString:@"iPhone5,4"])    return UIDevice5CiPhone;
    if ([modelIdentifier isEqualToString:@"iPhone6,1"])    return UIDevice5SiPhone;
    if ([modelIdentifier isEqualToString:@"iPhone6,2"])    return UIDevice5SiPhone;
    
    // iPod http://theiphonewiki.com/wiki/IPod
    
    if ([modelIdentifier hasPrefix:@"iPod1"])              return UIDevice1GiPod;
    if ([modelIdentifier hasPrefix:@"iPod2"])              return UIDevice2GiPod;
    if ([modelIdentifier hasPrefix:@"iPod3"])              return UIDevice3GiPod;
    if ([modelIdentifier hasPrefix:@"iPod4"])              return UIDevice4GiPod;
    if ([modelIdentifier hasPrefix:@"iPod5"])              return UIDevice5GiPod;
    
    // iPad http://theiphonewiki.com/wiki/IPad
    
    if ([modelIdentifier hasPrefix:@"iPad1"])              return UIDevice1GiPad;
    if ([modelIdentifier isEqualToString:@"iPad2,1"])      return UIDevice2GiPad;
    if ([modelIdentifier isEqualToString:@"iPad2,2"])      return UIDevice2GiPad;
    if ([modelIdentifier isEqualToString:@"iPad2,3"])      return UIDevice2GiPad;
    if ([modelIdentifier isEqualToString:@"iPad2,4"])      return UIDevice2GiPad;
    if ([modelIdentifier hasPrefix:@"iPad3"])              return UIDevice3GiPad;
    if ([modelIdentifier hasPrefix:@"iPad4"])              return UIDevice4GiPad;
    
    // iPad Mini http://theiphonewiki.com/wiki/IPad_mini
    
    if ([modelIdentifier isEqualToString:@"iPad2,5"])      return UIDevice1GiPadMini;
    if ([modelIdentifier isEqualToString:@"iPad2,6"])      return UIDevice1GiPadMini;
    if ([modelIdentifier isEqualToString:@"iPad2,7"])      return UIDevice1GiPadMini;
    if ([modelIdentifier isEqualToString:@"iPad4,4"])      return UIDevice2GiPadMini;
    if ([modelIdentifier isEqualToString:@"iPad4,5"])      return UIDevice2GiPadMini;
    
    // Apple TV
    if ([modelIdentifier hasPrefix:@"AppleTV2"])           return UIDeviceAppleTV2;
    
    if ([modelIdentifier hasPrefix:@"iPhone"])             return UIDeviceUnknowniPhone;
    if ([modelIdentifier hasPrefix:@"iPod"])               return UIDeviceUnknowniPod;
    if ([modelIdentifier hasPrefix:@"iPad"])               return UIDeviceUnknowniPad;
    
    // Simulator thanks Jordan Breeding
    if ([modelIdentifier hasSuffix:@"86"] || [modelIdentifier isEqual:@"x86_64"])
    {
        BOOL smallerScreen = [[UIScreen mainScreen] bounds].size.width < 768.0;
        return smallerScreen ? UIDeviceiPhoneSimulatoriPhone : UIDeviceiPhoneSimulatoriPad;
    }
    
    return UIDeviceUnknown;
}

- (UIDeviceMemoryClass)deviceMemoryClass
{
    UIDeviceMemoryClass memoryClass;
    switch ([self deviceType]) {
        case UIDevice1GiPhone:
        case UIDevice3GiPhone:
        case UIDevice3GSiPhone:
        case UIDevice1GiPod:
        case UIDevice1GiPad:
        case UIDevice2GiPadMini:
            memoryClass = UIDeviceMemoryClassLow;
            break;
        case UIDevice4iPhone:
        case UIDevice4SiPhone:
        case UIDevice3GiPod:
        case UIDevice4GiPod:
        case UIDevice5GiPod:
        case UIDevice2GiPad:
        case UIDevice1GiPadMini:
            memoryClass = UIDeviceMemoryClassMedium;
            break;
        case UIDevice5iPhone:
        case UIDevice5SiPhone:
        case UIDevice5CiPhone:
        case UIDevice3GiPad:
        case UIDevice4GiPad:
            memoryClass = UIDeviceMemoryClassHigh;
            break;
        default:
            memoryClass = UIDeviceMemoryClassUnknown;
            break;
    }
    return memoryClass;
}

- (NSString *)modelNameForModelIdentifier:(NSString *)modelIdentifier
{
    // iPhone http://theiphonewiki.com/wiki/IPhone
    
    if ([modelIdentifier isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([modelIdentifier isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([modelIdentifier isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([modelIdentifier isEqualToString:@"iPhone3,1"])    return @"iPhone 4 (GSM)";
    if ([modelIdentifier isEqualToString:@"iPhone3,2"])    return @"iPhone 4 (GSM Rev A)";
    if ([modelIdentifier isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
    if ([modelIdentifier isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([modelIdentifier isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([modelIdentifier isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (Global)";
    if ([modelIdentifier isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([modelIdentifier isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (Global)";
    if ([modelIdentifier isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([modelIdentifier isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (Global)";
    
    // iPad http://theiphonewiki.com/wiki/IPad
    
    if ([modelIdentifier isEqualToString:@"iPad1,1"])      return @"iPad 1G";
    if ([modelIdentifier isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([modelIdentifier isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([modelIdentifier isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([modelIdentifier isEqualToString:@"iPad2,4"])      return @"iPad 2 (Rev A)";
    if ([modelIdentifier isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([modelIdentifier isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM)";
    if ([modelIdentifier isEqualToString:@"iPad3,3"])      return @"iPad 3 (Global)";
    if ([modelIdentifier isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([modelIdentifier isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([modelIdentifier isEqualToString:@"iPad3,6"])      return @"iPad 4 (Global)";
    
    if ([modelIdentifier isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([modelIdentifier isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    
    // iPad Mini http://theiphonewiki.com/wiki/IPad_mini
    
    if ([modelIdentifier isEqualToString:@"iPad2,5"])      return @"iPad mini 1G (WiFi)";
    if ([modelIdentifier isEqualToString:@"iPad2,6"])      return @"iPad mini 1G (GSM)";
    if ([modelIdentifier isEqualToString:@"iPad2,7"])      return @"iPad mini 1G (Global)";
    if ([modelIdentifier isEqualToString:@"iPad4,4"])      return @"iPad mini 2G (WiFi)";
    if ([modelIdentifier isEqualToString:@"iPad4,5"])      return @"iPad mini 2G (Cellular)";
    
    // iPod http://theiphonewiki.com/wiki/IPod
    
    if ([modelIdentifier isEqualToString:@"iPod1,1"])      return @"iPod touch 1G";
    if ([modelIdentifier isEqualToString:@"iPod2,1"])      return @"iPod touch 2G";
    if ([modelIdentifier isEqualToString:@"iPod3,1"])      return @"iPod touch 3G";
    if ([modelIdentifier isEqualToString:@"iPod4,1"])      return @"iPod touch 4G";
    if ([modelIdentifier isEqualToString:@"iPod5,1"])      return @"iPod touch 5G";
    
    // Simulator
    if ([modelIdentifier hasSuffix:@"86"] || [modelIdentifier isEqual:@"x86_64"])
    {
        BOOL smallerScreen = ([[UIScreen mainScreen] bounds].size.width < 768.0);
        return (smallerScreen ? @"iPhone Simulator" : @"iPad Simulator");
    }
    
    return modelIdentifier;
}

#pragma mark MAC addy
// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to mlamb.
- (NSString *) macaddress
{
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    // NSString *outstring = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X",
    //                       *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

// Illicit Bluetooth check -- cannot be used in App Store
/*
 Class  btclass = NSClassFromString(@"GKBluetoothSupport");
 if ([btclass respondsToSelector:@selector(bluetoothStatus)])
 {
 printf("BTStatus %d\n", ((int)[btclass performSelector:@selector(bluetoothStatus)] & 1) != 0);
 bluetooth = ((int)[btclass performSelector:@selector(bluetoothStatus)] & 1) != 0;
 printf("Bluetooth %s enabled\n", bluetooth ? "is" : "isn't");
 }
 */
@end