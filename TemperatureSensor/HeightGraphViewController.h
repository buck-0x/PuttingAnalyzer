//
//  HeightGraphViewController.h
//  TemperatureSensor
//
//  Created by redthrawn on 2014-03-23.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeightGraphViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIWebView *webView;


// Chart properties.
@property (nonatomic, retain) NSMutableString *htmlContent;
@property (nonatomic, retain) NSMutableString *javascriptPath;
@property (nonatomic, retain) NSMutableString *chartData;
@property (nonatomic, retain) NSMutableString *chartType;
@property (nonatomic, assign) UIInterfaceOrientation currentOrientation;
@property (nonatomic, assign) CGFloat chartWidth;
@property (nonatomic, assign) CGFloat chartHeight;
@property (nonatomic, retain) NSMutableString *debugMode;
@property (nonatomic, retain) NSMutableString *registerWithJavaScript;

@property (strong, nonatomic) NSMutableArray            *heightValues;

- (void)displayDataError;
- (void)createChartData:(UIInterfaceOrientation)interfaceOrientation;
- (void)plotChart;
- (void)removeChart;

@end
