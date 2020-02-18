#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface CVHelper : NSObject

+ (UIImage*)cropImage: (UIImage*)image withExtremePoints: (NSString*)points;

@end
