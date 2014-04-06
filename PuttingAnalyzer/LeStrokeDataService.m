/*
 *  LeStrokeDataService.m
 *  PuttingAnalyzer
 *
 *  Created by Bradley Weiers on Jan 6, 2014.
 *  Copyright University of Saskatchewan. All rights reserved.
 */

#import "LeStrokeDataService.h"
#import "LeDiscovery.h"
#import "SERVICES.h"
#include <math.h>

NSString *kStrokeDataServiceEnteredBackgroundNotification = @"kStrokeDataServiceEnteredBackgroundNotification";
NSString *kStrokeDataServiceEnteredForegroundNotification = @"kStrokeDataServiceEnteredForegroundNotification";

CGFloat pixelWidth = 160.0; // width in pixels
CGFloat markerSize = 4.0;   // actual marker height in cm

@interface LeStrokeDataService() <CBPeripheralDelegate> {
@private
    CBPeripheral		*servicePeripheral;
    
    CBService			*strokeDataService;
    
    CBCharacteristic    *distanceCharacteristic;
    
    CBUUID              *currentDistanceUUID;

    id<StrokeDataProtocol>	peripheralDelegate;
}
@end


@implementation LeStrokeDataService

@synthesize peripheral = servicePeripheral;

// Convert the pixel height of the marker to a distance value in cm
- (CGFloat) distance
{
    CGFloat result  = NAN; // the distance between the camera and the marker
    int16_t	value	= 0; //height of marker in pixels
    
	if (distanceCharacteristic) {
        [[distanceCharacteristic value] getBytes:&value length:sizeof (value)];
        CGFloat viewingWidth = pixelWidth * markerSize / (CGFloat)value;
        result = (viewingWidth / 2.0) / tan(25.0 * M_PI / 180.0);
    }
    return result;
}

#pragma mark -
#pragma mark Init
/****************************************************************************/
/*								Init										*/
/****************************************************************************/
- (id) initWithPeripheral:(CBPeripheral *)peripheral controller:(id<StrokeDataProtocol>)controller
{
    self = [super init];
    if (self) {
        servicePeripheral = peripheral;
        [servicePeripheral setDelegate:self];
		peripheralDelegate = controller;
        
        currentDistanceUUID	= [CBUUID UUIDWithString:DISTANCE_CHARACTERISTIC_UUID];
	}
    return self;
}

- (void) dealloc
{
	if (servicePeripheral) {
		[servicePeripheral setDelegate:[LeDiscovery sharedInstance]];
        
    }
}

- (void) reset
{
	if (servicePeripheral) {
		servicePeripheral = nil;
	}
}



#pragma mark -
#pragma mark Service interaction
/****************************************************************************/
/*							Service Interactions							*/
/****************************************************************************/
- (void) start
{
	CBUUID	*serviceUUID	= [CBUUID UUIDWithString:STROKE_DATA_SERVICE_UUID];
	NSArray	*serviceArray	= [NSArray arrayWithObjects:serviceUUID, nil];

    [servicePeripheral discoverServices:serviceArray];
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	NSArray		*services	= nil;
    
    // Add all UUIDs to the array
    NSArray		*uuids	= [NSArray arrayWithObjects:currentDistanceUUID, // Current Distance
                           nil];

	if (peripheral != servicePeripheral) {
		NSLog(@"Wrong Peripheral.\n");
		return ;
	}
    
    if (error != nil) {
        NSLog(@"Error %@\n", error);
		return ;
	}

	services = [peripheral services];
	if (!services || ![services count]) {
		return ;
	}

	strokeDataService = nil;
    
	for (CBService *service in services) {
		if ([[service UUID] isEqual:[CBUUID UUIDWithString:STROKE_DATA_SERVICE_UUID]]) {
			strokeDataService = service;
			break;
		}
	}

	if (strokeDataService) {
		[peripheral discoverCharacteristics:uuids forService:strokeDataService];
	}
}


- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
	NSArray		*characteristics	= [service characteristics];
	CBCharacteristic *characteristic;
    
	if (peripheral != servicePeripheral) {
		NSLog(@"Wrong Peripheral.\n");
		return ;
	}
	
	if (service != strokeDataService) {
		NSLog(@"Wrong Service.\n");
		return ;
	}
    
    if (error != nil) {
		NSLog(@"Error %@\n", error);
		return ;
	}
    
	for (characteristic in characteristics) {
        NSLog(@"discovered characteristic %@", [characteristic UUID]);
        
        if ([[characteristic UUID] isEqual:currentDistanceUUID]) { // Current Temp
            NSLog(@"Discovered Temperature Characteristic");
			distanceCharacteristic = characteristic;
			// [peripheral readValueForCharacteristic:distanceCharacteristic];
			[peripheral setNotifyValue:YES forCharacteristic:characteristic];
		} // add and else-if block for each characteristic
	}
}

#pragma mark -
#pragma mark Characteristics interaction
/****************************************************************************/
/*						Characteristics Interactions						*/
/****************************************************************************/

/** If we're connected, we don't want to be getting distance change notifications while we're in the background.
 We will want alarm notifications, so we don't turn those off.
 */
- (void)enteredBackground
{
    // Find the fishtank service
    for (CBService *service in [servicePeripheral services]) {
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:STROKE_DATA_SERVICE_UUID]]) {
            
            // Find the temperature characteristic
            for (CBCharacteristic *characteristic in [service characteristics]) {
                if ( [[characteristic UUID] isEqual:[CBUUID UUIDWithString:DISTANCE_CHARACTERISTIC_UUID]] ) {
                    
                    // And STOP getting notifications from it
                    [servicePeripheral setNotifyValue:NO forCharacteristic:characteristic];
                }
            }
        }
    }
}

/** Coming back from the background, we want to register for notifications again for the distance changes */
- (void)enteredForeground
{
    // Find the service
    for (CBService *service in [servicePeripheral services]) {
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:STROKE_DATA_SERVICE_UUID]]) {
            
            // Find the distance characteristic
            for (CBCharacteristic *characteristic in [service characteristics]) {
                if ( [[characteristic UUID] isEqual:[CBUUID UUIDWithString:DISTANCE_CHARACTERISTIC_UUID]] ) {
                    
                    // And START getting notifications from it
                    [servicePeripheral setNotifyValue:YES forCharacteristic:characteristic];
                }
            }
        }
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //uint8_t alarmValue  = 0;
    
	if (peripheral != servicePeripheral) {
		NSLog(@"Wrong peripheral\n");
		return ;
	}

    if ([error code] != 0) {
		NSLog(@"Error %@\n", error);
		return ;
	}

    /* Distance change */
    if ([[characteristic UUID] isEqual:currentDistanceUUID]) {
        [peripheralDelegate strokeDataServiceDidChangeDistance:self];
        return;
    }

}

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    /* When a write occurs, need to set off a re-read of the local CBCharacteristic to update its value */
    [peripheral readValueForCharacteristic:characteristic];
    
}
@end
