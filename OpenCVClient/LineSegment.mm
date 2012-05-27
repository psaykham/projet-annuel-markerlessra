//
//  LineSegment.m
//  OpenCVClient
//
//  Created by SAYKHAM Patrick on 28/04/12.
//  Copyright (c) 2012 Aptogo Limited. All rights reserved.
//

#import "LineSegment.h"

@implementation LineSegment

@synthesize remove;
@synthesize startCorner;
@synthesize endCorner;

// C++ synthesize
@synthesize start;
@synthesize end;
@synthesize supportEdgels;
@synthesize slope;

- (id) init
{
    [super init];
//    start = [[NSEdgel alloc] init];
//    end = [[NSEdgel alloc] init];
    supportEdgels = [[NSMutableArray alloc] init];
    
    return self;
}

//- (void) setLineSegmentWithRemove:(bool)remove andStartCorner:(bool)startCorner andEndCorner:(bool)endCorner andStart:(NSEdgel *)start andEnd:(NSEdgel *)end andSupportEdgels:(NSMutableArray *)supportEdgels andSlope:(Vector2f)slope
//{
//    self.remove = remove;
//    self.startCorner = startCorner;
//    self.endCorner = endCorner;
//    self.start = start;
//    self.end = end;
//    self.supportEdgels = supportEdgels;
//    self->slope = slope;
//}

- (bool) atLine:(NSEdgel *)cmp
{
    if(![start isOrientationCompatibleWithEdgel:cmp]) return false;
    
    float cross = (float(end.position.x) - float(start.position.x)) * (float(cmp.position.y) - float(start.position.y));
    
    cross -= (float(end.position.y) - float(start.position.y)) * (float(cmp.position.x) - float(start.position.x));
    
    const float d1 = float(start.position.x) - float(end.position.x);
    
    const float d2 = float(start.position.y) - float(end.position.y);
    
    float distance = cross / Vector2f(d1, d2).get_length();
    
    return fabs(distance) < 0.75f;
}

- (void) addSupportedEdgel:(NSEdgel *)supportedEdgel
{
    [supportEdgels addObject:supportedEdgel];
}

- (bool) isOrientationCompatible:(LineSegment *)comparedLineSegment
{
//    return (*slope) * *(comparedLineSegment.slope) > 0.92f;
    return slope * comparedLineSegment->slope > 0.92f;
}

- (Vector2f) getIntersectionWithLineSegment:(LineSegment *)b
{
    Vector2f intersection;
	
	float denom = ((b.end.position.y - b.start.position.y)*(end.position.x - start.position.x)) -
    ((b.end.position.x - b.start.position.x)*(end.position.y - start.position.y));
	
	float nume_a = ((b.end.position.x - b.start.position.x)*(start.position.y - b.start.position.y)) -
    ((b.end.position.y - b.start.position.y)*(start.position.x - b.start.position.x));
	
	float ua = nume_a / denom;
	
	intersection.x = start.position.x + ua * (end.position.x - start.position.x);
	intersection.y = start.position.y + ua * (end.position.y - start.position.y);
	
	return intersection;
}

- (void) setSlope:(Vector2f)slopeToSet
{
    slope = slopeToSet;
}

//- (void) copyLineSegment:(LineSegment *)lineSegmentToCopy
//{
//    remove = lineSegmentToCopy.remove;
//    startCorner = lineSegmentToCopy.startCorner;
//    endCorner = lineSegmentToCopy.endCorner;
//    start = lineSegmentToCopy.start;
//    end = lineSegmentToCopy.end;
//    supportEdgels = lineSegmentToCopy.supportEdgels;
//    slope = lineSegmentToCopy.slope;
//}
//
//- (id) copyWithZone:(NSZone *)zone
//{
//    LineSegment * lineSegmentCopy = [[LineSegment allocWithZone:zone] init];
//    [lineSegmentCopy setLineSegmentWithRemove:remove andStartCorner:startCorner andEndCorner:endCorner andStart:start andEnd:end andSupportEdgels:supportEdgels andSlope:slope];
//    return lineSegmentCopy;
//}

@end
