//
//  OpenCVWrapper.h
//  BioScope
//
//  Created by Timothy DenOuden on 3/15/17.
//  Copyright © 2017 Timothy DenOuden. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface OpenCVWrapper : NSObject

+ (NSString *) openCVVersionString;

+ (UIImage *) cvEdgeDetect:(UIImage*)inputImage;

+ (UIImage *) cvSmooth:(UIImage*)inputImage;

+ (UIImage *) cvSharpen:(UIImage*)inputImage;


@end
