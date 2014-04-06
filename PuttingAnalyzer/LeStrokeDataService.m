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


//NSString *kTemperatureServiceUUIDString = @"DEADF154-0000-0000-0000-0000DEADF154";
//NSString *STROKE_DATA_SERVICE_UUID = @"00001523-1212-EFDE-1523-785FEABCD123";

//NSString *kCurrentTemperatureCharacteristicUUIDString = @"CCCCFFFF-DEAD-F154-1319-740381000000";
//NSString *DISTANCE_CHARACTERISTIC_UUID = @"00001524-1212-EFDE-1523-785FEABCD123";

//NSString *kMinimumTemperatureCharacteristicUUIDString = @"C0C0C0C0-DEAD-F154-1319-740381000000";
//NSString *kMaximumTemperatureCharacteristicUUIDString = @"EDEDEDED-DEAD-F154-1319-740381000000";
//NSString *kAlarmCharacteristicUUIDString = @"AAAAAAAA-DEAD-F154-1319-740381000000";

NSString *kStrokeDataServiceEnteredBackgroundNotification = @"kStrokeDataServiceEnteredBackgroundNotification";
NSString *kStrokeDataServiceEnteredForegroundNotification = @"kStrokeDataServiceEnteredForegroundNotification";

CGFloat pixelWidth = 160.0; // width in pixels
CGFloat markerSize = 4.0; // actual marker height in cm


@interface LeStrokeDataService() <CBPeripheralDelegate> {
@private
    CBPeripheral		*servicePeripheral;
    
    CBService			*strokeDataService;
    
    CBCharacteristic    *distanceCharacteristic;
    //CBCharacteristic	*minTemperatureCharacteristic;
    //CBCharacteristic    *maxTemperatureCharacteristic;
    //CBCharacteristic    *alarmCharacteristic;
    
//    CBUUID              *temperatureAlarmUUID;
//    CBUUID              *minimumTemperatureUUID;
//    CBUUID              *maximumTemperatureUUID;
    CBUUID              *currentTemperatureUUID;

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
        
//        minimumTemperatureUUID	= [CBUUID UUIDWithString:kMinimumTemperatureCharacteristicUUIDString];
//        maximumTemperatureUUID	= [CBUUID UUIDWithString:kMaximumTemperatureCharacteristicUUIDString];
        currentTemperatureUUID	= [CBUUID UUIDWithString:DISTANCE_CHARACTERISTIC_UUID];
//        temperatureAlarmUUID	= [CBUUID UUIDWithString:kAlarmCharacteristicUUIDString];
	}
    return self;
}


- (void) dealloc {
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
//	NSArray		*uuids	= [NSArray arrayWithObjects:currentTemperatureUUID, // Current Temp
//								   minimumTemperatureUUID, // Min Temp
//								   maximumTemperatureUUID, // Max Temp
//								   temperatureAlarmUUID, // Alarm Characteristic
//								   nil];
    NSArray		*uuids	= [NSArray arrayWithObjects:currentTemperatureUUID, // Current Temp
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
        
//		if ([[characteristic UUID] isEqual:minimumTemperatureUUID]) { // Min Temperature.
//            NSLog(@"Discovered Minimum Alarm Characteristic");
//			minTemperatureCharacteristic = characteristic;
//			[peripheral readValueForCharacteristic:characteristic];
//		}
//        else if ([[characteristic UUID] isEqual:maximumTemperatureUUID]) { // Max Temperature.
//            NSLog(@"Discovered Maximum Alarm Characteristic");
//			maxTemperatureCharacteristic = characteristic;
//			[peripheral readValueForCharacteristic:characteristic];
//		}
//        else if ([[characteristic UUID] isEqual:temperatureAlarmUUID]) { // Alarm
//            NSLog(@"Discovered Alarm Characteristic");
//			alarmCharacteristic = characteristic;
//            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
//		}
//        else if ([[characteristic UUID] isEqual:currentTemperatureUUID]) { // Current Temp
        if ([[characteristic UUID] isEqual:currentTemperatureUUID]) { // Current Temp
            NSLog(@"Discovered Temperature Characteristic");
			distanceCharacteristic = characteristic;
			// [peripheral readValueForCharacteristic:distanceCharacteristic];
			[peripheral setNotifyValue:YES forCharacteristic:characteristic];
		} 
	}
}



#pragma mark -
#pragma mark Characteristics interaction
/****************************************************************************/
/*						Characteristics Interactions						*/
/****************************************************************************/
//- (void) writeLowAlarmTemperature:(int)low 
//{
//    NSData  *data	= nil;
//    int16_t value	= (int16_t)low;
//    
//    if (!servicePeripheral) {
//        NSLog(@"Not connected to a peripheral");
//		return ;
//    }
//
//    if (!minTemperatureCharacteristic) {
//        NSLog(@"No valid minTemp characteristic");
//        return;
//    }
//    
//    data = [NSData dataWithBytes:&value length:sizeof (value)];
//    [servicePeripheral writeValue:data forCharacteristic:minTemperatureCharacteristic type:CBCharacteristicWriteWithResponse];
//}


//- (void) writeHighAlarmTemperature:(int)high
//{
//    NSData  *data	= nil;
//    int16_t value	= (int16_t)high;
//
//    if (!servicePeripheral) {
//        NSLog(@"Not connected to a peripheral");
//    }
//
//    if (!maxTemperatureCharacteristic) {
//        NSLog(@"No valid minTemp characteristic");
//        return;
//    }
//
//    data = [NSData dataWithBytes:&value length:sizeof (value)];
//    [servicePeripheral writeValue:data forCharacteristic:maxTemperatureCharacteristic type:CBCharacteristicWriteWithResponse];
//}


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
    // Find the fishtank service
    for (CBService *service in [servicePeripheral services]) {
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:STROKE_DATA_SERVICE_UUID]]) {
            
            // Find the temperature characteristic
            for (CBCharacteristic *characteristic in [service characteristics]) {
                if ( [[characteristic UUID] isEqual:[CBUUID UUIDWithString:DISTANCE_CHARACTERISTIC_UUID]] ) {
                    
                    // And START getting notifications from it
                    [servicePeripheral setNotifyValue:YES forCharacteristic:characteristic];
                }
            }
        }
    }
}

//- (CGFloat) minimumTemperature
//{
//    CGFloat result  = NAN;
//    int16_t value	= 0;
//	
//    if (minTemperatureCharacteristic) {
//        [[minTemperatureCharacteristic value] getBytes:&value length:sizeof (value)];
//        result = (CGFloat)value / 10.0f;
//    }
//    return result;
//}
//
//
//- (CGFloat) maximumTemperature
//{
//    CGFloat result  = NAN;
//    int16_t	value	= 0;
//    
//    if (maxTemperatureCharacteristic) {
//        [[maxTemperatureCharacteristic value] getBytes:&value length:sizeof (value)];
//        result = (CGFloat)value / 10.0f;
//    }
//    return result;
//}





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
    if ([[characteristic UUID] isEqual:currentTemperatureUUID]) {
        [peripheralDelegate strokeDataServiceDidChangeDistance:self];
        return;
    }
    
    /* Alarm change */
//    if ([[characteristic UUID] isEqual:temperatureAlarmUUID]) {
//
//        /* get the value for the alarm */
//        [[alarmCharacteristic value] getBytes:&alarmValue length:sizeof (alarmValue)];
//
//        NSLog(@"alarm!  0x%x", alarmValue);
//        if (alarmValue & 0x01) {
//            /* Alarm is firing */
//            if (alarmValue & 0x02) {
//                [peripheralDelegate alarmService:self didSoundAlarmOfType:kAlarmLow];
//			} else {
//                [peripheralDelegate alarmService:self didSoundAlarmOfType:kAlarmHigh];
//			}
//        } else {
//            [peripheralDelegate alarmServiceDidStopAlarm:self];
//        }
//
//        return;
//    }

    /* Upper or lower bounds changed */
//    if ([characteristic.UUID isEqual:minimumTemperatureUUID] || [characteristic.UUID isEqual:maximumTemperatureUUID]) {
//        [peripheralDelegate alarmServiceDidChangeTemperatureBounds:self];
//    }
}

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    /* When a write occurs, need to set off a re-read of the local CBCharacteristic to update its value */
    [peripheral readValueForCharacteristic:characteristic];
    
    /* Upper or lower bounds changed */
//    if ([characteristic.UUID isEqual:minimumTemperatureUUID] || [characteristic.UUID isEqual:maximumTemperatureUUID]) {
//        [peripheralDelegate alarmServiceDidChangeTemperatureBounds:self];
//    }
}
@end
