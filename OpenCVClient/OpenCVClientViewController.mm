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
#import "buffer.h"
#include <iostream>

#define THRESHOLD (16*16)
#define EDGELSONLINE 5

using namespace std;

// Aperture value to use for the Canny edge detection
const int kCannyAperture = 7;

@interface OpenCVClientViewController ()
- (void)processFrame;
@end

@implementation OpenCVClientViewController

@synthesize imageView = _imageView;
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
    
    // Load a test image and demonstrate conversion between UIImage and cv::Mat
    UIImage *testImage = [UIImage imageNamed:@"testimage3.png"];
    
    double t;
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
    _lastFrame = testMat;
    [self sliderChanged:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.imageView = nil;
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
    if (_videoCapture && _videoCapture->grab())
    {
        (*_videoCapture) >> _lastFrame;
        [self processFrame];
    }
    else
    {
        NSLog(@"Failed to grab frame");        
    }
}

- (int) edgeKernelWithOffset:(unsigned char *)offset withPitch:(const int)pitch
{
    int ver = -3 * offset[ -2*pitch ];
	ver += -5 * offset[ -pitch ];
	ver += 5 * offset[ pitch ];
	ver += 3 * offset[ 2*pitch ]; 
	
	return abs( ver );
}

//Fonction qui permet d'afficher les grilles de debug
- (void) debugGridWithI:(int)i andJ:(int)j
{
    CvScalar color = CV_RGB(122,122,122);
    
    //on trace les grilles de 5pixels
    for(int k=i; k<(i + std::min( 40, _lastFrame.rows-i-3)); k+=5) {
        cv::line(_lastFrame, cvPoint(j, k), cvPoint(j+std::min( 40, _lastFrame.cols-j-3), k), color);
    }
    
    for(int k=j; k<(j+std::min( 40, _lastFrame.cols-j-3)); k+=5) {
        cv::line(_lastFrame, cvPoint(k, i), cvPoint(k, i + std::min( 40, _lastFrame.rows-i-3)), color);
    }
    
    //on trace la grille de 40 pixels
    cv::line(_lastFrame, cvPoint(j, i), cvPoint(j+std::min( 40, _lastFrame.cols-j-3), i), color);
    cv::line(_lastFrame, cvPoint(j, i), cvPoint(j, i + std::min( 40, _lastFrame.rows-i-3)), color);
    cv::line(_lastFrame, cvPoint(j, i + std::min( 40, _lastFrame.rows-i-3)), cvPoint(j+std::min( 40, _lastFrame.cols-j-3), i + std::min( 40, _lastFrame.rows-i-3)), color);
    cv::line(_lastFrame, cvPoint(j+std::min( 40, _lastFrame.cols-j-3), i + std::min( 40, _lastFrame.rows-i-3)), cvPoint(j+std::min( 40, _lastFrame.cols-j-3), i + std::min( 40, _lastFrame.rows-i-3)), color);

}

//Permet de trouver les points d'intérêt des contours
- (NSMutableArray *) findEdgePointsWithLeftBorder:(int)j andTopBorder:(int)i andWidth:(const int)width andHeight:(int)height
{
//    vector<Edgel> edgelsList;
    NSMutableArray * edgelsList = [[NSMutableArray alloc] init];
    CvScalar colorRed = CV_RGB(0,0,255);
    float prev1, prev2;
    
    //points horizontaux
    for(int k=0; k<height; k+=5) {
        unsigned char* offset = buffer->getBuffer() + (j + (k + i)*buffer->getWidth()) * 3;
        prev1 = prev2 = 0.0f;
        const int pitch = 3;
        
        for(int m=0; m<width; m++) {    
            int current = [self edgeKernelWithOffset:offset withPitch:pitch];
            if(current > THRESHOLD && [self edgeKernelWithOffset:offset+1 withPitch:pitch] > THRESHOLD && [self edgeKernelWithOffset:offset+2 withPitch:pitch] > THRESHOLD) {
                //on a trouvé un edge
            }else{
                current = 0.0f;
            }
            
            //find local maximum
            if(prev1 > 0.0f && prev1 > prev2 && prev1 > current) {
                NSEdgel * edgel = [[NSEdgel alloc] init];
                [edgel setPositionWithX:j+m-1 andWithY:i+k];
                edgel.slope = *[self determineEdgelOrientiationWithX:edgel.position.x andY:edgel.position.y];
                [edgelsList addObject:edgel];
                cv::circle(_lastFrame, cvPoint(j+m-1, i+k), 1, colorRed);
            }
            
            prev2 = prev1;
            prev1 = current;
            
            offset += pitch;
        }
    }
    
    //points verticaux
    for(int k=0; k<width; k+=5) {
        unsigned char* offset = buffer->getBuffer() + (j + k + (i * buffer->getWidth())) * 3;
        prev1 = prev2 = 0.0f;
        const int pitch = 3 * buffer->getWidth();
        
        //points horizontaux
        for(int m=0; m<height; m++) {    
            int current = [self edgeKernelWithOffset:offset withPitch:pitch];
            if(current > THRESHOLD && [self edgeKernelWithOffset:offset+1 withPitch:pitch] > THRESHOLD && [self edgeKernelWithOffset:offset+2 withPitch:pitch] > THRESHOLD) {
                //on a trouvé un edge
            }else{
                current = 0.0f;
            }
            
            //find local maximum
            if(prev1 > 0.0f && prev1 > prev2 && prev1 > current) {
                NSEdgel * edgel = [[NSEdgel alloc] init];
                [edgel setPositionWithX:j+k andWithY:i+m-1];
                edgel.slope = *[self determineEdgelOrientiationWithX:edgel.position.x andY:edgel.position.y];
                [edgelsList addObject:edgel];
                cv::circle(_lastFrame, cvPoint(j+k, i+m-1), 1, colorRed);
            }
            
            prev2 = prev1;
            prev1 = current;
            
            offset += pitch;
        }
    }

    return edgelsList;
}

- (Vector2f)determineEdgelOrientiationWithX:(int)x andY:(int)y
{
    int gx =  buffer->getPixelColor( x-1, y-1, 0 );
	gx += 2 * buffer->getPixelColor( x, y-1, 0 );
	gx += buffer->getPixelColor( x+1, y-1, 0 );
	gx -= buffer->getPixelColor( x-1, y+1, 0 );
	gx -= 2 * buffer->getPixelColor( x, y+1, 0 );
	gx -= buffer->getPixelColor( x+1, y+1, 0 );
    
	int gy = buffer->getPixelColor( x-1, y-1, 0 );
	gy += 2 * buffer->getPixelColor( x-1, y, 0 );
	gy += buffer->getPixelColor( x-1, y+1, 0 );
	gy -= buffer->getPixelColor( x+1, y-1, 0 );
	gy -= 2 * buffer->getPixelColor( x+1, y, 0 );
	gy -= buffer->getPixelColor( x+1, y+1, 0 );
    
    return Vector2f((float)gy, (float)gx).get_normalized();
}

- (NSMutableArray *) findLineSegmentInEdgelsList:(NSMutableArray *)edgels
{   
    NSMutableArray * lineSegments = [[NSMutableArray alloc] init];
    LineSegment * lineSegmentInRun = [[LineSegment alloc] init];
    
    srand(time(NULL));
    
    do {
        [lineSegmentInRun.supportEdgels removeAllObjects];
        
        for (int i=0; i<25; i++) {
            NSEdgel * r1;
            NSEdgel * r2;
            
            const int max_iterations = 100;
            int iteration = 0, ir1, ir2;
            
            do {
                ir1 = (rand()%([edgels count]));
				ir2 = (rand()%([edgels count]));
                
                r1 = [edgels objectAtIndex:ir1];
                r2 = [edgels objectAtIndex:ir2];
                
                iteration++;
            } while ((ir1 == ir2 || ![r1 isOrientationCompatibleWithEdgel:r2]) && iteration < max_iterations);
            
            if (iteration < max_iterations) {
                LineSegment * lineSegment = [[LineSegment alloc] init];
                lineSegment.start = r1;
                lineSegment.end = r2;
                [lineSegment setSlope:[r1 getSlope]];
                
                for(NSEdgel * edgel in edgels) {
                    if([lineSegment atLine:edgel]) {
                        [lineSegment addSupportedEdgel:edgel];
                    }
                }

                if ([lineSegment.supportEdgels count] > [lineSegmentInRun.supportEdgels count]) {
                    lineSegmentInRun = lineSegment;
                    NSLog(@"bonjour");
                }
            }
        }
        
    } while ([lineSegmentInRun.supportEdgels count] >= EDGELSONLINE && [edgels count] >= EDGELSONLINE);
    
    return lineSegments;
}

// Perform image processing on the last captured frame and display the results
- (void)processFrame
{
    double t = (double)cv::getTickCount();
    t = 1000 * ((double)cv::getTickCount() - t) / cv::getTickFrequency();
    
    IplImage* temp = new IplImage(_lastFrame);
    buffer = new Buffer();
    buffer->setBuffer( (unsigned char *) temp->imageData, temp->width, temp->height);
        
    //on procède par zone de 40*40pixels
    for(int i = 2; i <buffer->getHeight() - 3; i+=40)
    {
        for(int j = 2; j < buffer->getWidth() - 3; j+=40)
        {
            int height = std::min(40, buffer->getHeight()-i-3);
            int width = std::min(40, buffer->getWidth()-j-3);
            
            //on recherche des points de contours dans chaque zone
            NSMutableArray * edgelsList = [self findEdgePointsWithLeftBorder:j andTopBorder:i andWidth:width andHeight:height];
            
            NSMutableArray * lineSegmentsList;
                        
            if([edgelsList count] >= 5) {
                lineSegmentsList = [self findLineSegmentInEdgelsList:edgelsList];
            }
        }
    }
        
    // Display result 
    self.imageView.image = [UIImage imageWithCVMat:_lastFrame];
    self.elapsedTimeLabel.text = [NSString stringWithFormat:@"%.1fms", t];
}

// Called when the user changes either of the threshold sliders
- (IBAction)sliderChanged:(id)sender
{
    self.highLabel.text = [NSString stringWithFormat:@"%.0f", self.highSlider.value];
    self.lowLabel.text = [NSString stringWithFormat:@"%.0f", self.lowSlider.value];
    
    [self processFrame];
}

@end
