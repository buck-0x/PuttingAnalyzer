#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


/****************************************************************************/
/*						Service Characteristics								*/
/****************************************************************************/
// Declare as GLOBAL
extern NSString *kStrokeDataServiceUUIDString;                 // DEADF154-0000-0000-0000-0000DEADF154     Service UUID
extern NSString *kDistanceCharacteristicUUIDString;   // CCCCFFFF-DEAD-F154-1319-740381000000     Current Temperature Characteristic
//extern NSString *kMinimumTemperatureCharacteristicUUIDString;   // C0C0C0C0-DEAD-F154-1319-740381000000     Minimum Temperature Characteristic
//extern NSString *kMaximumTemperatureCharacteristicUUIDString;   // EDEDEDED-DEAD-F154-1319-740381000000     Maximum Temperature Characteristic
//extern NSString *kAlarmCharacteristicUUIDString;                // AAAAAAAA-DEAD-F154-1319-740381000000     Alarm Characteristic

extern NSString *kStrokeDataServiceEnteredBackgroundNotification;
extern NSString *kStrokeDataServiceEnteredForegroundNotification;

/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class LeStrokeDataService;

//typedef enum {
//    kAlarmHigh  = 0,
//    kAlarmLow   = 1,
//} AlarmType;

@protocol StrokeDataProtocol<NSObject>
//- (void) alarmService:(LeStrokeDataService*)service didSoundAlarmOfType:(AlarmType)alarm;
//- (void) alarmServiceDidStopAlarm:(LeStrokeDataService*)service;
- (void) alarmServiceDidChangeTemperature:(LeStrokeDataService*)service;
//- (void) alarmServiceDidChangeTemperatureBounds:(LeStrokeDataService*)service;
- (void) alarmServiceDidChangeStatus:(LeStrokeDataService*)service;
- (void) alarmServiceDidReset;
@end


/****************************************************************************/
/*						Temperature Alarm service.                          */
/****************************************************************************/
@interface LeStrokeDataService : NSObject

- (id) initWithPeripheral:(CBPeripheral *)peripheral controller:(id<StrokeDataProtocol>)controller;
- (void) reset;
- (void) start;

/* Querying Sensor */
@property (readonly) CGFloat distance;
//@property (readonly) CGFloat minimumTemperature;
//@property (readonly) CGFloat maximumTemperature;

/* Set the alarm cutoffs */
//- (void) writeLowAlarmTemperature:(int)low;
//- (void) writeHighAlarmTemperature:(int)high;

/* Behave properly when heading into and out of the background */
- (void)enteredBackground;
- (void)enteredForeground;

@property (readonly) CBPeripheral *peripheral;
@end
