//
//  VideoCache.h
//  VideoBox
//
//  Created by Maxwell on 21/06/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^YDL_progressUpdate)(NSDictionary *updateData);
void YDL_setProgressCallback(YDL_progressUpdate callback);

@interface VideoCache : NSObject

- (void)download:(NSURL *)url outputDir:(NSURL *)outputDir;

- (void)runWeb;

@end

NS_ASSUME_NONNULL_END
