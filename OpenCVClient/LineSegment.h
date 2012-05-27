//
//  LineSegment.h
//  OpenCVClient
//
//  Created by SAYKHAM Patrick on 28/04/12.
//  Copyright (c) 2012 Aptogo Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSEdgel.h"
#include <vector>

using namespace std;

@interface LineSegment : NSObject{
    Vector2f slope;
}

@property (readwrite, nonatomic) bool remove;
@property (readwrite, nonatomic) bool startCorner;
@property (readwrite, nonatomic) bool endCorner;
@property (readwrite, nonatomic, retain) NSEdgel * start;
@property (readwrite, nonatomic, retain) NSEdgel * end;
@property (readwrite, nonatomic, retain) NSMutableArray * supportEdgels;
@property (readwrite, assign) Vector2f slope;

//- (void) setLineSegmentWithRemove:(bool)remove andStartCorner:(bool)startCorner andEndCorner:(bool)endCorner andStart:(NSEdgel *)start andEnd:(NSEdgel *)end andSupportEdgels:(NSMutableArray *)supportEdgels andSlope:(Vector2f)slope;
- (bool) atLine:(NSEdgel *) cmp;
- (void) addSupportedEdgel:(NSEdgel *) supportedEdgel;
- (bool) isOrientationCompatible:(LineSegment *)comparedLineSegment;
- (Vector2f) getIntersectionWithLineSegment:(LineSegment *)b;
- (void) setSlope:(Vector2f)slopeToSet;
//- (void) copyLineSegment:(LineSegment *)lineSegmentToCopy;

@end
