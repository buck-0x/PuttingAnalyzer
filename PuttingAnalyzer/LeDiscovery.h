/*
 *  LeDiscovery.h
 *  PuttingAnalyzer
 *
 *  Created by Bradley Weiers on 2014-04-06.
 *  Copyright University of Saskatchewan. All rights reserved.
 *
 *  Abstract: Manages connections between the central and peripheral devices.
 *      Subscribes to services and enables/disables subscription to 
 *      characteristics.
 */

#import <CoreBluetooth/CoreBluetooth.h>

#import "LeStrokeDataService.h"

/****************************************************************************/
/*							UI protocols									*/
/****************************************************************************/
@protocol LeDiscoveryDelegate <NSObject>
- (void) discoveryDidRefresh;
- (void) discoveryStatePoweredOff;
@end

/****************************************************************************/
/*							Discovery class									*/
/****************************************************************************/
@interface LeDiscovery : NSObject

+ (id) sharedInstance;

/****************************************************************************/
/*								UI controls									*/
/****************************************************************************/
@property (nonatomic, weak) id<LeDiscoveryDelegate> discoveryDelegate;
@property (nonatomic, weak) id<StrokeDataProtocol> peripheralDelegate;

/****************************************************************************/
/*								Actions										*/
/****************************************************************************/
- (void) startScanningForUUIDString:(NSString *)uuidString;
- (void) stopScanning;

- (void) connectPeripheral:(CBPeripheral*)peripheral;
- (void) disconnectPeripheral:(CBPeripheral*)peripheral;

/****************************************************************************/
/*							Access to the devices							*/
/****************************************************************************/
@property (strong, nonatomic) NSMutableArray    *foundPeripherals;
@property (strong, nonatomic) NSMutableArray	*connectedServices;	// Array
@end
