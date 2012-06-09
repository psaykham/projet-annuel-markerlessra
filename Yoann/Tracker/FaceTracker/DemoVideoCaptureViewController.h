//
//  DemoVideoCaptureViewController.h
//  FaceTracker
//
//  Created by Robin Summerhill on 9/22/11.
//  Copyright 2011 Aptogo Limited. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "VideoCaptureViewController.h"

@interface DemoVideoCaptureViewController : VideoCaptureViewController
{
    cv::Mat m_lastFrame;
    cv::CascadeClassifier _faceCascade;
}

-(void)computeFrame:(cv::Mat &)newFrame;
- (std::vector<cv::KeyPoint>) DetectKeypoint: (cv::Mat*) _mat;
- (cv::Mat) ComputeDesciptor: (cv::Mat*) _mat :(std::vector<cv::KeyPoint>*) _keypointList;

- (IBAction)toggleFps:(id)sender;
- (IBAction)toggleTorch:(id)sender;
- (IBAction)toggleCamera:(id)sender;

@end
