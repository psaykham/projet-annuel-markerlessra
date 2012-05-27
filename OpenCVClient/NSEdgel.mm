//
//  NSEdgel.m
//  OpenCVClient
//
//  Created by Arnaud Phommasone on 29/04/12.
//  Copyright (c) 2012 Aptogo Limited. All rights reserved.
//

#import "NSEdgel.h"

@implementation NSEdgel

@synthesize position;
@synthesize slope;


- (bool) isOrientationCompatibleWithEdgel:(NSEdgel *)edgel{
    return slope * edgel->slope > 0.38f;
//    return (*slope) * *(edgel.slope) > 0.38f;
}

- (void) setPositionWithX:(int)x andWithY:(int)y{
    position = Vector2f(x,y);
}

- (Vector2f) getSlope
{
    return slope;
}

@end
