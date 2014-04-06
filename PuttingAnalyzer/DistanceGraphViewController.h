//
//  DistanceGraphViewController.h
//  PuttingAnalyzer
//
//  Created by Bradley Weiers on 2014-01-06.
//  Copyright (c) 2014 University of Saskatchewan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DistanceGraphViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIWebView *webView;

// Chart properties.
@property (nonatomic, retain) NSMutableString       *htmlContent;
@property (nonatomic, retain) NSMutableString       *javascriptPath;
@property (nonatomic, retain) NSMutableString       *chartData;
@property (nonatomic, retain) NSMutableString       *chartType;
@property (nonatomic, assign) UIInterfaceOrientation currentOrientation;
@property (nonatomic, assign) CGFloat               chartWidth;
@property (nonatomic, assign) CGFloat               chartHeight;
@property (nonatomic, retain) NSMutableString       *debugMode;
@property (nonatomic, retain) NSMutableString       *registerWithJavaScript;

//
@property (strong, nonatomic) NSMutableArray        *heightValues;

// Chart methods
- (void)displayDataError;
- (void)createChartData:(UIInterfaceOrientation)    interfaceOrientation;
- (void)plotChart;
- (void)removeChart;

@end
