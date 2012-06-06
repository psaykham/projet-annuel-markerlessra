//
//  OpenCVClientViewController.h
//  OpenCVClient
//
//  Created by Robin Summerhill on 02/09/2011.
//  Copyright 2011 Aptogo Limited. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <UIKit/UIKit.h>
#import "buffer.h"
#import "edgel.h"
#import "NSEdgel.h"
#import "LineSegment.h"
#import "fast.h"

@interface OpenCVClientViewController : UIViewController
{
    cv::VideoCapture *_videoCapture;
    cv::Mat _lastFrame;
    Buffer * buffer;
    int numCorners;
	xy *corners;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *elapsedTimeLabel;
@property (nonatomic, retain) IBOutlet UISlider *highSlider;
@property (nonatomic, retain) IBOutlet UISlider *lowSlider;
@property (nonatomic, retain) IBOutlet UILabel *highLabel;
@property (nonatomic, retain) IBOutlet UILabel *lowLabel;
@property (nonatomic) int numCorners;
@property (nonatomic) xy *corners;

- (IBAction)capture:(id)sender;
- (IBAction)sliderChanged:(id)sender;
- (Vector2f)determineEdgelOrientiationWithX:(int)x andY:(int)y;

@end
