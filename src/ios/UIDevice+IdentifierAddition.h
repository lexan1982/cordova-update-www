#import <UIKit/UIKit.h>

@interface UIDevice (IdentifierAddition)

- (NSString *) uniqueDeviceIdentifier;

- (NSString *) uniqueGlobalDeviceIdentifier;

@end
