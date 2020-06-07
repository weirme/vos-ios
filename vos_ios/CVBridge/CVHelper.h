#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface CVHelper : NSObject

+ (NSArray<UIImage*>*)makeOverlayMaskOfImage: (UIImage*)image withExtremePoints: (NSArray<NSArray*>*)coords
    NS_SWIFT_NAME(makeOverlayMask(image:coords:));

@end
