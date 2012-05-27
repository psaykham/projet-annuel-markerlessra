//
//  NSEdgel.h
//  OpenCVClient
//
//  Created by Arnaud Phommasone on 29/04/12.
//  Copyright (c) 2012 Aptogo Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "vector2f.h"

@interface NSEdgel : NSObject{
    Vector2f position;
    Vector2f slope;
}

@property (nonatomic, assign) Vector2f position;
@property (nonatomic, assign) Vector2f slope;

- (bool) isOrientationCompatibleWithEdgel:(NSEdgel *)edgel;
- (void) setPositionWithX:(int)x andWithY:(int)y;
- (Vector2f) getSlope;

@end