//
//  DistanceGraphViewController.m
//  PuttingAnalyzer
//
//  Created by Bradley Weiers on 2014-01-06.
//  Copyright (c) 2014 University of Saskatchewan. All rights reserved.
//

#import "DistanceGraphViewController.h"

@implementation DistanceGraphViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //self.heightValues = [NSMutableArray arrayWithObjects:@1,@2,@3,nil];
    
    self.currentOrientation = self.interfaceOrientation;
    [self createChartData:self.currentOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES since we support all orientations.
    return YES;
}

// Handle interface rotation.
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // Check whether we have valid data.
    //if (self.twitterDataError) {
    //    [self displayDataError];
    //} else {
        // Valid data.
        
        // Store new orientation.
        self.currentOrientation = toInterfaceOrientation;
        
        // Remove existing chart and recreating it
        // as per the new orientation.
        [self removeChart];
        [self createChartData:self.currentOrientation];
    //}
}


- (void)displayDataError
{
    

}

- (void)createChartData:(UIInterfaceOrientation)interfaceOrientation
{
    // Valid data.
    
    // Set chart width and height depending on the screen's orientation.
    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        self.chartWidth = 300;
        self.chartHeight = 548;
    } else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        self.chartWidth = 548;
        self.chartHeight = 300;
    }
    
    NSLog(@"%@", self.heightValues);

    self.chartData = [NSMutableString string];
    [self.chartData appendFormat:@"<chart caption='Distance' showValues='0'>"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    for (int i = 0; i < [self.heightValues count]; i++) {
        [self.chartData appendFormat:@"<set label='%@' value='%@' />", [NSString stringWithFormat:@"%d", i], [self.heightValues objectAtIndex:i]];
    }
    [self.chartData appendFormat:@"</chart>"];
    //[dateFormatter release];
    
    // Setup chart HTML.
    self.htmlContent = [NSMutableString stringWithFormat:@"%@", @"<html><head>"];
    [self.htmlContent appendString:@"<script type='text/javascript' src='FusionCharts.js'></script>"];
    [self.htmlContent appendString:@"</head><body><div id='chart_container'>Chart will render here.</div>"];
    [self.htmlContent appendString:@"<script type='text/javascript'>"];
    [self.htmlContent appendFormat:@"var chart_object = new FusionCharts('Line.swf', 'twitter_data_chart', '%f', '%f', '0', '1');", self.chartWidth, self.chartHeight];
    [self.htmlContent appendFormat:@"chart_object.setXMLData(\"%@\");", self.chartData];
    [self.htmlContent appendString:@"chart_object.render('chart_container');"];
    [self.htmlContent appendString:@"</script></body></html>"];
    
    //NSLog(@"%@", self.chartData);
    
    //NSLog(@"%@", self.htmlContent);
 
    [self plotChart];
}

- (void)plotChart
{
    NSURL *baseURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@", [[NSBundle mainBundle] bundlePath]]];
    [self.webView loadHTMLString:self.htmlContent baseURL:baseURL];
}

- (void)removeChart
{
    NSString *emptyChartContainer = @"<script type='text/javascript'>document.getElementById('chart_container').innerHTML='';</script>";
	[self.webView stringByEvaluatingJavaScriptFromString:emptyChartContainer];
}

@end
