/*
 
 File: ViewController.m
 
 Abstract: User interface to display a list of discovered peripherals
 and allow the user to connect to them.
 
 */

#import <Foundation/Foundation.h>

#import "ViewController.h"

@implementation ViewController

#pragma mark -
#pragma mark View lifecycle
/****************************************************************************/
/*								View Lifecycle                              */
/****************************************************************************/
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    _connectedServices = [NSMutableArray new];
    _heightValues = [NSMutableArray new];
    
	[[LeDiscovery sharedInstance] setDiscoveryDelegate:self];
    [[LeDiscovery sharedInstance] setPeripheralDelegate:self];
    [[LeDiscovery sharedInstance] startScanningForUUIDString:kStrokeDataServiceUUIDString];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification:) name:kStrokeDataServiceEnteredBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterForegroundNotification:) name:kStrokeDataServiceEnteredForegroundNotification object:nil];
    
//    _maxAlarmLabel.hidden = YES;
//    _minAlarmLabel.hidden = YES;
    //_maxAlarmStepper.hidden = YES;
    //_minAlarmStepper.hidden = YES;
    
    
    
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DistanceGraphViewController *transferViewController = segue.destinationViewController;
    transferViewController.heightValues = self.heightValues;

}


- (void) viewDidUnload
{
    [self setCurrentlyConnectedSensor:nil];
    [self setCurrentDistanceLabel:nil];
//    [self setMaxAlarmLabel:nil];
//    [self setMinAlarmLabel:nil];
    [self setSensorsTable:nil];
//    [self setMaxAlarmStepper:nil];
//    [self setMinAlarmStepper:nil];
    [self setConnectedServices:nil];
    [self setCurrentlyDisplayingService:nil];
    
    [[LeDiscovery sharedInstance] stopScanning];
    
    [super viewDidUnload];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void) dealloc 
{
    [[LeDiscovery sharedInstance] stopScanning];
}



#pragma mark -
#pragma mark LeTemperatureAlarm Interactions
/****************************************************************************/
/*                  LeTemperatureAlarm Interactions                         */
/****************************************************************************/
- (LeStrokeDataService*) serviceForPeripheral:(CBPeripheral *)peripheral
{
    for (LeStrokeDataService *service in _connectedServices) {
        if ( [[service peripheral] isEqual:peripheral] ) {
            return service;
        }
    }
    
    return nil;
}

- (void)didEnterBackgroundNotification:(NSNotification*)notification
{   
    NSLog(@"Entered background notification called.");
    for (LeStrokeDataService *service in self.connectedServices) {
        [service enteredBackground];
    }
}

- (void)didEnterForegroundNotification:(NSNotification*)notification
{
    NSLog(@"Entered foreground notification called.");
    for (LeStrokeDataService *service in self.connectedServices) {
        [service enteredForeground];
    }    
}


#pragma mark -
#pragma mark LeTemperatureAlarmProtocol Delegate Methods
/****************************************************************************/
/*				LeTemperatureAlarmProtocol Delegate Methods					*/
/****************************************************************************/
/** Broke the high or low temperature bound */
//- (void) alarmService:(LeStrokeDataService*)service didSoundAlarmOfType:(AlarmType)alarm
//{
//    if (![service isEqual:_currentlyDisplayingService])
//        return;
//    
//    NSString *title;
//    NSString *message;
//    
//	switch (alarm) {
//		case kAlarmLow: 
//			NSLog(@"Alarm low");
//            title     = @"Alarm Notification";
//            message   = @"Low Alarm Fired";
//			break;
//            
//		case kAlarmHigh: 
//			NSLog(@"Alarm high");
//            title     = @"Alarm Notification";
//            message   = @"High Alarm Fired";
//			break;
//	}
//    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alertView show];
//}


/** Back into normal values */
- (void) alarmServiceDidStopAlarm:(LeStrokeDataService*)service
{
    NSLog(@"Alarm stopped");
}


/** Current temp changed */
- (void) strokeDataServiceDidChangeDistance:(LeStrokeDataService*)service
{  
    if (service != _currentlyDisplayingService)
        return;
    
    NSInteger currentTemperature = (int)[service distance];
    //NSString *currentTemperature = (NSString *)[service temperature];
    [_heightValues addObject:[NSNumber numberWithInt:currentTemperature]];
    [_currentDistanceLabel setText:[NSString stringWithFormat:@"%d", currentTemperature]];
    //[currentTemperatureLabel setText:[NSString stringWithFormat:@"%s", currentTemperature]];
    //NSLog(@"%@", heightValues);
}


/** Max or Min change request complete */
//- (void) alarmServiceDidChangeTemperatureBounds:(LeStrokeDataService*)service
//{
//    if (service != _currentlyDisplayingService) 
//        return;
//    
//    [_maxAlarmLabel setText:[NSString stringWithFormat:@"MAX %dº", (int)[_currentlyDisplayingService maximumTemperature]]];
//    [_minAlarmLabel setText:[NSString stringWithFormat:@"MIN %dº", (int)[_currentlyDisplayingService minimumTemperature]]];
//
//    [_maxAlarmStepper setEnabled:YES];
//    [_minAlarmStepper setEnabled:YES];
//    
//    
//}


/** Peripheral connected or disconnected */
- (void) strokeDataServiceDidChangeStatus:(LeStrokeDataService*)service
{
    if ( [[service peripheral] isConnected] ) {
        NSLog(@"Service (%@) connected", service.peripheral.name);
        if (![_connectedServices containsObject:service]) {
            [_connectedServices addObject:service];
        }
    }
    
    else {
        NSLog(@"Service (%@) disconnected", service.peripheral.name);
        if ([_connectedServices containsObject:service]) {
            [_connectedServices removeObject:service];
        }
    }
}


/** Central Manager reset */
- (void) strokeDataServiceDidReset
{
    [_connectedServices removeAllObjects];
}



#pragma mark -
#pragma mark TableView Delegates
/****************************************************************************/
/*							TableView Delegates								*/
/****************************************************************************/
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell	*cell;
	CBPeripheral	*peripheral;
	NSArray			*devices;
	NSInteger		row	= [indexPath row];
    static NSString *cellID = @"DeviceList";
    
	cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if (!cell)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    
	if ([indexPath section] == 0) {
		devices = [[LeDiscovery sharedInstance] connectedServices];
        peripheral = [(LeStrokeDataService*)[devices objectAtIndex:row] peripheral];
        
	} else {
		devices = [[LeDiscovery sharedInstance] foundPeripherals];
        peripheral = (CBPeripheral*)[devices objectAtIndex:row];
	}
    
    if ([[peripheral name] length])
        [[cell textLabel] setText:[peripheral name]];
    else
        [[cell textLabel] setText:@"Peripheral"];
		
    [[cell detailTextLabel] setText: [peripheral isConnected] ? @"Connected" : @"Not connected"];
    
	return cell;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger	res = 0;
    
	if (section == 0)
		res = [[[LeDiscovery sharedInstance] connectedServices] count];
	else
		res = [[[LeDiscovery sharedInstance] foundPeripherals] count];
    
	return res;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{  
	CBPeripheral	*peripheral;
	NSArray			*devices;
	NSInteger		row	= [indexPath row];
	
	if ([indexPath section] == 0) {
		devices = [[LeDiscovery sharedInstance] connectedServices];
        peripheral = [(LeStrokeDataService*)[devices objectAtIndex:row] peripheral];
	} else {
		devices = [[LeDiscovery sharedInstance] foundPeripherals];
    	peripheral = (CBPeripheral*)[devices objectAtIndex:row];
	}
    
	if (![peripheral isConnected]) {
		[[LeDiscovery sharedInstance] connectPeripheral:peripheral];
        [_currentlyConnectedSensor setText:[peripheral name]];
        
        [_currentlyConnectedSensor setEnabled:NO];
        [_currentDistanceLabel setEnabled:NO];
//        [_maxAlarmLabel setEnabled:NO];
//        [_minAlarmLabel setEnabled:NO];
    }
    
	else {
        
        if ( _currentlyDisplayingService != nil ) {
            _currentlyDisplayingService = nil;
        }
        
        _currentlyDisplayingService = [self serviceForPeripheral:peripheral];
        
        [_currentlyConnectedSensor setText:[peripheral name]];
        
        [_currentDistanceLabel setText:[NSString stringWithFormat:@"%d", (int)[_currentlyDisplayingService distance]]];
//        [_maxAlarmLabel setText:[NSString stringWithFormat:@"MAX %dº", (int)[_currentlyDisplayingService maximumTemperature]]];
//        [_minAlarmLabel setText:[NSString stringWithFormat:@"MIN %dº", (int)[_currentlyDisplayingService minimumTemperature]]];
        
        [_currentlyConnectedSensor setEnabled:YES];
        [_currentDistanceLabel setEnabled:YES];
//        [_maxAlarmLabel setEnabled:YES];
//        [_minAlarmLabel setEnabled:YES];
    }
}


#pragma mark -
#pragma mark LeDiscoveryDelegate 
/****************************************************************************/
/*                       LeDiscoveryDelegate Methods                        */
/****************************************************************************/
- (void) discoveryDidRefresh 
{
    [_sensorsTable reloadData];
}

- (void) discoveryStatePoweredOff 
{
    NSString *title     = @"Bluetooth Power";
    NSString *message   = @"You must turn on Bluetooth in Settings in order to use LE";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}



#pragma mark -
#pragma mark App IO
/****************************************************************************/
/*                              App IO Methods                              */
/****************************************************************************/
/** Increase or decrease the maximum alarm setting */
//- (IBAction) maxStepperChanged
//{
//    int newTemp = [_currentlyDisplayingService maximumTemperature] * 10;
//    
//    if (_maxAlarmStepper.value > 0) {
//        newTemp+=10;
//        NSLog(@"increasing MAX temp to %d", newTemp);
//    }
//    
//    if (_maxAlarmStepper.value < 0) {
//        newTemp-=10;
//        NSLog(@"decreasing MAX temp to %d", newTemp);
//    }
//    
//    // We're not interested in the actual VALUE of the stepper, just if it's increased or decreased, so reset it to 0 after a press
//    [_maxAlarmStepper setValue:0];
//    
//    // Disable the stepper so we don't send multiple requests to the peripheral
//    [_maxAlarmStepper setEnabled:NO];
//    
//    [_currentlyDisplayingService writeHighAlarmTemperature:newTemp];
//}


/** Increase or decrease the minimum alarm setting */
//- (IBAction) minStepperChanged
//{
//    int newTemp = [_currentlyDisplayingService minimumTemperature] * 10;
//    
//    if (_minAlarmStepper.value > 0) {
//        newTemp+=10;
//        NSLog(@"increasing MIN temp to %d", newTemp);
//    }
//    
//    if (_minAlarmStepper.value < 0) {
//        newTemp-=10;
//        NSLog(@"decreasing MIN temp to %d", newTemp);
//    }
//    
//    // We're not interested in the actual VALUE of the stepper, just if it's increased or decreased, so reset it to 0 after a press
//    [_minAlarmStepper setValue:0];
//    
//    // Disable the stepper so we don't send multiple requests to the peripheral
//    [_minAlarmStepper setEnabled:NO];
//    
//    [_currentlyDisplayingService writeLowAlarmTemperature:newTemp];
//}

//- (IBAction)startButtonPressed
//{
//    
//    
//}
//
//- (IBAction)stopButtonPressed
//{
//    
//    
//}

@end
