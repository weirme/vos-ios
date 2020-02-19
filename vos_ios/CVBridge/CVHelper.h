#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface CVHelper : NSObject

+ (UIImage*)makeOverlayMaskOfImage: (UIImage*)image withExtremePoints: (NSArray<NSArray*>*)coords
    NS_SWIFT_NAME(makeOverlayMask(image:coords:));

@end
