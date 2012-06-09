//
//  OpenCVClientViewController.m
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

// UIImage extensions for converting between UIImage and cv::Mat
#import "UIImage+OpenCV.h"

#import "OpenCVClientViewController.h"

// Aperture value to use for the Canny edge detection
const int kCannyAperture = 7;

@interface OpenCVClientViewController ()
- (void)processFrame;
@end

@implementation OpenCVClientViewController

@synthesize imageTest;
@synthesize imageViewLeft = _imageViewLeft;
@synthesize imageViewRight = _imageViewRight;
@synthesize elapsedTimeLabel = _elapsedTimeLabel;
@synthesize highSlider = _highSlider;
@synthesize lowSlider= _lowSlider;
@synthesize highLabel = _highLabel;
@synthesize lowLabel = _lowLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialise video capture - only supported on iOS device NOT simulator
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"Video capture is not supported in the simulator");
#else
    _videoCapture = new cv::VideoCapture;
    if (!_videoCapture->open(CV_CAP_AVFOUNDATION))
    {
        NSLog(@"Failed to open video camera");
    }
#endif
    
    //CGSize frameSize;
    //frameSize.width = 640;
    //frameSize.height = 960;
    
    // Load a test image and demonstrate conversion between UIImage and cv::Mat
    //m_newFrame = [[[UIImage imageNamed:@"newFrame.jpg"] scaleToSize:frameSize] CVMat];
    //m_oldFrame = [[[UIImage imageNamed:@"oldFrame.jpg"] scaleToSize:frameSize] CVMat];
    
    //CvMat* test = cvCreateMat(960, 640, originalNewFrame.type());
    
    /*NSLog(@"%i", originalNewFrame.type());
    
    m_newFrame = cv::Mat(960, 640, originalNewFrame.type());
    cvResize(&originalNewFrame, &m_newFrame);*/
    
    /*m_oldFrame = cvCreateMat(960, 640, originalOldFrame.type());
    cvResize(&originalOldFrame, &m_oldFrame);*/
    
    /*double t;
    int times = 10;
    
    //--------------------------------
    // Convert from UIImage to cv::Mat
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    t = (double)cv::getTickCount();
    
    for (int i = 0; i < times; i++)
    {
        cv::Mat tempMat = [testImage CVMat];
    }
        
    t = 1000 * ((double)cv::getTickCount() - t) / cv::getTickFrequency() / times;
    
    [pool release];
    
    NSLog(@"UIImage to cv::Mat: %gms", t);
    
    //------------------------------------------
    // Convert from UIImage to grayscale cv::Mat
    pool = [[NSAutoreleasePool alloc] init];
    
    t = (double)cv::getTickCount();
    
    for (int i = 0; i < times; i++)
    {
        cv::Mat tempMat = [testImage CVGrayscaleMat];
    }
    
    t = 1000 * ((double)cv::getTickCount() - t) / cv::getTickFrequency() / times;
    
    [pool release];
    
    NSLog(@"UIImage to grayscale cv::Mat: %gms", t);
    
    //--------------------------------
    // Convert from cv::Mat to UIImage
    cv::Mat testMat = [testImage CVMat];

    t = (double)cv::getTickCount();
        
    for (int i = 0; i < times; i++)
    {
        UIImage *tempImage = [[UIImage alloc] initWithCVMat:testMat];
        [tempImage release];
    }
    
    t = 1000 * ((double)cv::getTickCount() - t) / cv::getTickFrequency() / times;
    
    NSLog(@"cv::Mat to UIImage: %gms", t);
    
    // Process test image and force update of UI 
    _lastFrame = testMat;*/
    //[self sliderChanged:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.imageViewLeft = nil;
    self.imageViewRight = nil;
    self.elapsedTimeLabel = nil;
    self.highLabel = nil;
    self.lowLabel = nil;
    self.highSlider = nil;
    self.lowSlider = nil;

    delete _videoCapture;
    _videoCapture = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Called when the user taps the Capture button. Grab a frame and process it
- (IBAction)capture:(id)sender
{
    //[self processFrame];
    if (_videoCapture && _videoCapture->grab())
    {
        //m_oldFrame = cv::Mat(m_newFrame);
        //m_newFrame.copyTo(m_oldFrame);
        //m_oldFrame = m_newFrame;
        (*_videoCapture) >> m_newFrame;
        m_newFrame.resize(m_newFrame.rows/4, m_newFrame.cols/4);
        [self processFrame];
        m_newFrame.copyTo(m_oldFrame);
        //std::cout << m_newFrame.rows << "/" << m_newFrame.cols << std::endl;
        /*if(m_oldFrame.empty())
            std::cout << "ok" << std::endl;
        else
            std::cout << "no" << std::endl;*/
        //std::cout << m_oldFrame.size << std::endl;
    }
    else
    {
        NSLog(@"Failed to grab frame");        
    }
}

// Perform image processing on the last captured frame and display the results
- (void)processFrame
{
    if(!m_oldFrame.empty() && !m_newFrame.empty())
    {
    NSLog(@"processFrame");
    
    double t = (double)cv::getTickCount();
    
    // Detecing Keypoints with FAST algorithme
    std::vector<cv::KeyPoint> oldKeypointList = [self DetectKeypoint: &m_oldFrame];
    std::vector<cv::KeyPoint> newKeypointList = [self DetectKeypoint: &m_newFrame];
    
    // Computing Descriptors
    cv::Mat oldDescriptor = [self ComputeDesciptor:&m_oldFrame :&oldKeypointList];
    cv::Mat newDescriptor = [self ComputeDesciptor:&m_newFrame :&newKeypointList];
    
    // Find closest matching between descriptors
   /* cv::BruteForceMatcher< cv::L2<float> > matcher;
    std::vector<cv::DMatch> good_matches;
    matcher.match(oldDescriptor, newDescriptor, good_matches);*/
    
    
  
    //-- Step 3: Matching descriptor vectors using FLANN matcher
    /*cv::FlannBasedMatcher matcher;
    std::vector<cv::DMatch> matches;
    matcher.match( oldDescriptor, newDescriptor, matches );
    
    double max_dist = 0; double min_dist = 100;
    
    //-- Quick calculation of max and min distances between keypoints
    for( int i = 0; i < oldDescriptor.rows; i++ )
    { 
        double dist = matches[i].distance;
        if( dist < min_dist ) min_dist = dist;
        if( dist > max_dist ) max_dist = dist;
    }
    
    printf("-- Max dist : %f \n", max_dist );
    printf("-- Min dist : %f \n", min_dist );
    
    //-- Draw only "good" matches (i.e. whose distance is less than 3*min_dist )
    std::vector<cv::DMatch> good_matches;
    
    for( int i = 0; i < oldDescriptor.rows; i++ )
    { 
        if(matches[i].distance < 3*min_dist)
            good_matches.push_back(matches[i]);
    }
    
    cv::Mat img_matches;
    drawMatches(m_oldFrame, oldKeypointList, m_newFrame, newKeypointList,
                good_matches, img_matches, cv::Scalar::all(-1), cv::Scalar::all(-1),
                std::vector<char>(), cv::DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS );
    
    //-- Localize the object
    std::vector<cv::Point2f> oldObj;
    std::vector<cv::Point2f> newObj;
    
    for( int i = 0; i < good_matches.size(); i++ )
    {
        //-- Get the keypoints from the good matches
        oldObj.push_back(oldKeypointList[ good_matches[i].queryIdx ].pt );
        newObj.push_back(newKeypointList[ good_matches[i].trainIdx ].pt );
    }*/
    
    //cv::Mat H = findHomography(oldObj, newObj, CV_RANSAC );
    
    //-- Get the corners from the image_1 ( the object to be "detected" )
    /*std::vector<cv::Point2f> obj_corners(4);
    obj_corners[0] = cvPoint(0,0); obj_corners[1] = cvPoint( m_oldFrame.cols, 0 );
    obj_corners[2] = cvPoint( m_oldFrame.cols, m_oldFrame.rows ); obj_corners[3] = cvPoint( 0, m_oldFrame.rows );
    std::vector<cv::Point2f> scene_corners(4);
    
    perspectiveTransform( obj_corners, scene_corners, H);*/
    
    //-- Draw lines between the corners (the mapped object in the scene - image_2 )
    /*line( img_matches, scene_corners[0] + cv::Point2f( m_oldFrame.cols, 0), scene_corners[1] + cv::Point2f( m_oldFrame.cols, 0), cv::Scalar(0, 255, 0), 4 );
    line( img_matches, scene_corners[1] + cv::Point2f( m_oldFrame.cols, 0), scene_corners[2] + cv::Point2f( m_oldFrame.cols, 0), cv::Scalar( 0, 255, 0), 4 );
    line( img_matches, scene_corners[2] + cv::Point2f( m_oldFrame.cols, 0), scene_corners[3] + cv::Point2f( m_oldFrame.cols, 0), cv::Scalar( 0, 255, 0), 4 );
    line( img_matches, scene_corners[3] + cv::Point2f( m_oldFrame.cols, 0), scene_corners[0] + cv::Point2f( m_oldFrame.cols, 0), cv::Scalar( 0, 255, 0), 4 );*/
    
    //-- Show detected matches
    //imshow( "Good Matches & Object detection", img_matches );
    
    
    
    
    
    
    /*cv::Mat output;
    drawMatches(m_oldFrame, oldKeypointList, m_newFrame, newKeypointList, matches, output);
    
    float ransacReprojThreshold = 3.0f;
    std::vector<cv::Point2f> points1, points2;
    for(int i=0; i<oldKeypointList.size(); i++)
    {
        points1.push_back(oldKeypointList[i].pt);
    }
    
    for(int i=0; i<oldKeypointList.size(); i++)
    {
        points2.push_back(newKeypointList[i].pt);
    }
    
    std::cout << points1.size() << "/"<< points2.size() << std::endl;*/
    
    /*points1.push_back(cv::Point2f(50,50));
    points1.push_back(cv::Point2f(100,100));
    
    points2.push_back(cv::Point2f(250,250));
    points2.push_back(cv::Point2f(300,300));*/
    /*cv::Mat H = findHomography(cv::Mat(points1), cv::Mat(points2), CV_RANSAC, ransacReprojThreshold);
    
    cv::Mat points1Projected; perspectiveTransform(Mat(points1), points1Projected, H);*/
    
    
    
    /*//-- Get the corners from the image_1 ( the object to be "detected" )
    std::vector<cv::Point2f> old_coners(4);
    old_coners[0] = cvPoint(0,230); 
    old_coners[1] = cvPoint( m_oldFrame.cols, 230 );
    old_coners[2] = cvPoint( m_oldFrame.cols, m_oldFrame.rows +230); 
    old_coners[3] = cvPoint( 0, m_oldFrame.rows+230 );
    std::vector<cv::Point2f> new_corners(4);
    
    perspectiveTransform( old_coners, new_corners, H);*/
    
    //-- Draw lines between the corners (the mapped object in the scene - image_2 )
    /*line(img_matches, new_corners[0] + cv::Point2f( m_oldFrame.cols, 0), new_corners[1] + cv::Point2f( m_oldFrame.cols, 0), cv::Scalar(0, 255, 0), 4 );
    line( img_matches, new_corners[1] + cv::Point2f( m_oldFrame.cols, 0), new_corners[2] + cv::Point2f( m_oldFrame.cols, 0), cv::Scalar( 0, 255, 0), 4 );
    line( img_matches, new_corners[2] + cv::Point2f( m_oldFrame.cols, 0), new_corners[3] + cv::Point2f( m_oldFrame.cols, 0), cv::Scalar( 0, 255, 0), 4 );
    line( img_matches, new_corners[3] + cv::Point2f( m_oldFrame.cols, 0), new_corners[0] + cv::Point2f( m_oldFrame.cols, 0), cv::Scalar( 0, 255, 0), 4 );*/
    
    
    // Display result 
    //self.imageTest.image = [UIImage imageWithCVMat:img_matches];
    self.imageViewLeft.image = [UIImage imageWithCVMat:m_oldFrame];
    self.imageViewRight.image = [UIImage imageWithCVMat:m_newFrame];
    t = 1000 * ((double)cv::getTickCount() - t) / cv::getTickFrequency();
    self.elapsedTimeLabel.text = [NSString stringWithFormat:@"%.1fms", t];
    
    
    
    
    /*double t = (double)cv::getTickCount();
    
    cv::Mat grayFrame, output;
  
    // Convert captured frame to grayscale
    cv::cvtColor(_lastFrame, grayFrame, cv::COLOR_RGB2GRAY);
    
    // Perform Canny edge detection using slide values for thresholds
    cv::Canny(grayFrame, output,
              _lowSlider.value * kCannyAperture * kCannyAperture,
              _highSlider.value * kCannyAperture * kCannyAperture,
              kCannyAperture);
    
    t = 1000 * ((double)cv::getTickCount() - t) / cv::getTickFrequency();
    
    // Display result 
    self.imageView.image = [UIImage imageWithCVMat:output];
    self.elapsedTimeLabel.text = [NSString stringWithFormat:@"%.1fms", t];*/
    }
}

// Fast detection of Keypoint
- (std::vector<cv::KeyPoint>) DetectKeypoint: (cv::Mat*) _mat
{
    //cv::RiffFeatureDetector detector(150);
    cv::FastFeatureDetector detector(150);
    
    std::vector<cv::KeyPoint> keypointList;
    detector.detect(*_mat, keypointList);

    return keypointList;
}

- (cv::Mat) ComputeDesciptor: (cv::Mat*) _mat :(std::vector<cv::KeyPoint>*) _keypointList
{
    //cv::BriefDescriptorExtractor extractor;
    cv::OrbDescriptorExtractor extractor;
    //cv::SurfDescriptorExtractor extractor;
    cv::Mat descriptor;
    extractor.compute(*_mat, *_keypointList, descriptor);
    
    return descriptor;
}

// Called when the user changes either of the threshold sliders
- (IBAction)sliderChanged:(id)sender
{
    self.highLabel.text = [NSString stringWithFormat:@"%.0f", self.highSlider.value];
    self.lowLabel.text = [NSString stringWithFormat:@"%.0f", self.lowSlider.value];
    
    //[self processFrame];
}

@end
