/*
 *  LeStrokeDataService.h
 *  PuttingAnalyzer
 *
 *  Created by Bradley Weiers on Jan 6, 2014.
 *  Copyright University of Saskatchewan. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

extern NSString *kStrokeDataServiceEnteredBackgroundNotification;
extern NSString *kStrokeDataServiceEnteredForegroundNotification;

/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class LeStrokeDataService;

@protocol StrokeDataProtocol<NSObject>
- (void) strokeDataServiceDidChangeDistance:(LeStrokeDataService*)service;
- (void) strokeDataServiceDidChangeStatus:(LeStrokeDataService*)service;
- (void) strokeDataServiceDidReset;
@end


/****************************************************************************/
/*						Stroke Data Service.                          */
/****************************************************************************/
@interface LeStrokeDataService : NSObject

- (id) initWithPeripheral:(CBPeripheral *)peripheral controller:(id<StrokeDataProtocol>)controller;
- (void) reset;
- (void) start;

/* Querying Sensor */
@property (readonly) CGFloat distance;

/* Behave properly when heading into and out of the background */
- (void)enteredBackground;
- (void)enteredForeground;

@property (readonly) CBPeripheral *peripheral;
@end
