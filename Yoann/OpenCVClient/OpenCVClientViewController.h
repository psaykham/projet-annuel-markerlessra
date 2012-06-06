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
#import <vector>

@interface OpenCVClientViewController : UIViewController
{
    cv::VideoCapture *_videoCapture;
    cv::Mat m_newFrame;
    cv::Mat m_oldFrame;
}

@property (nonatomic, retain) IBOutlet UIImageView* imageTest;
@property (nonatomic, retain) IBOutlet UIImageView *imageViewLeft;
@property (nonatomic, retain) IBOutlet UIImageView *imageViewRight;
@property (nonatomic, retain) IBOutlet UILabel *elapsedTimeLabel;
@property (nonatomic, retain) IBOutlet UISlider *highSlider;
@property (nonatomic, retain) IBOutlet UISlider *lowSlider;
@property (nonatomic, retain) IBOutlet UILabel *highLabel;
@property (nonatomic, retain) IBOutlet UILabel *lowLabel;

- (IBAction)capture:(id)sender;
- (IBAction)sliderChanged:(id)sender;

- (std::vector<cv::KeyPoint>) DetectKeypoint: (cv::Mat*) _mat;
- (cv::Mat) ComputeDesciptor: (cv::Mat*) _mat :(std::vector<cv::KeyPoint>*) _keypointList;

@end
