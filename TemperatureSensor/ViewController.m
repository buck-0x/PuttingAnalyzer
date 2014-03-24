/*
 
 File: ViewController.m
 
 Abstract: User interface to display a list of discovered peripherals
 and allow the user to connect to them.
 
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by 
 Apple Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. 
 may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied, are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */

#import <Foundation/Foundation.h>

#import "ViewController.h"

@implementation ViewController


//@synthesize currentlyDisplayingService;
//@synthesize connectedServices;
//@synthesize currentlyConnectedSensor;
//@synthesize sensorsTable;
//@synthesize currentTemperatureLabel;
//@synthesize maxAlarmLabel,minAlarmLabel;
//@synthesize maxAlarmStepper,minAlarmStepper;
//
//@synthesize heightValues;



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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification:) name:kAlarmServiceEnteredBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterForegroundNotification:) name:kAlarmServiceEnteredForegroundNotification object:nil];
    
    _maxAlarmLabel.hidden = YES;
    _minAlarmLabel.hidden = YES;
    _maxAlarmStepper.hidden = YES;
    _minAlarmStepper.hidden = YES;
    
    
    
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    HeightGraphViewController *transferViewController = segue.destinationViewController;
    transferViewController.heightValues = self.heightValues;

}


- (void) viewDidUnload
{
    [self setCurrentlyConnectedSensor:nil];
    [self setCurrentTemperatureLabel:nil];
    [self setMaxAlarmLabel:nil];
    [self setMinAlarmLabel:nil];
    [self setSensorsTable:nil];
    [self setMaxAlarmStepper:nil];
    [self setMinAlarmStepper:nil];
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
     ;
}



#pragma mark -
#pragma mark LeTemperatureAlarm Interactions
/****************************************************************************/
/*                  LeTemperatureAlarm Interactions                         */
/****************************************************************************/
- (LeTemperatureAlarmService*) serviceForPeripheral:(CBPeripheral *)peripheral
{
    for (LeTemperatureAlarmService *service in _connectedServices) {
        if ( [[service peripheral] isEqual:peripheral] ) {
            return service;
        }
    }
    
    return nil;
}

- (void)didEnterBackgroundNotification:(NSNotification*)notification
{   
    NSLog(@"Entered background notification called.");
    for (LeTemperatureAlarmService *service in self.connectedServices) {
        [service enteredBackground];
    }
}

- (void)didEnterForegroundNotification:(NSNotification*)notification
{
    NSLog(@"Entered foreground notification called.");
    for (LeTemperatureAlarmService *service in self.connectedServices) {
        [service enteredForeground];
    }    
}


#pragma mark -
#pragma mark LeTemperatureAlarmProtocol Delegate Methods
/****************************************************************************/
/*				LeTemperatureAlarmProtocol Delegate Methods					*/
/****************************************************************************/
/** Broke the high or low temperature bound */
- (void) alarmService:(LeTemperatureAlarmService*)service didSoundAlarmOfType:(AlarmType)alarm
{
    if (![service isEqual:_currentlyDisplayingService])
        return;
    
    NSString *title;
    NSString *message;
    
	switch (alarm) {
		case kAlarmLow: 
			NSLog(@"Alarm low");
            title     = @"Alarm Notification";
            message   = @"Low Alarm Fired";
			break;
            
		case kAlarmHigh: 
			NSLog(@"Alarm high");
            title     = @"Alarm Notification";
            message   = @"High Alarm Fired";
			break;
	}
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}


/** Back into normal values */
- (void) alarmServiceDidStopAlarm:(LeTemperatureAlarmService*)service
{
    NSLog(@"Alarm stopped");
}


/** Current temp changed */
- (void) alarmServiceDidChangeTemperature:(LeTemperatureAlarmService*)service
{  
    if (service != _currentlyDisplayingService)
        return;
    
    NSInteger currentTemperature = (int)[service temperature];
    //NSString *currentTemperature = (NSString *)[service temperature];
    [_heightValues addObject:[NSNumber numberWithInt:currentTemperature]];
    [_currentTemperatureLabel setText:[NSString stringWithFormat:@"%d", currentTemperature]];
    //[currentTemperatureLabel setText:[NSString stringWithFormat:@"%s", currentTemperature]];
    //NSLog(@"%@", heightValues);
}


/** Max or Min change request complete */
- (void) alarmServiceDidChangeTemperatureBounds:(LeTemperatureAlarmService*)service
{
    if (service != _currentlyDisplayingService) 
        return;
    
    [_maxAlarmLabel setText:[NSString stringWithFormat:@"MAX %dº", (int)[_currentlyDisplayingService maximumTemperature]]];
    [_minAlarmLabel setText:[NSString stringWithFormat:@"MIN %dº", (int)[_currentlyDisplayingService minimumTemperature]]];
    
    [_maxAlarmStepper setEnabled:YES];
    [_minAlarmStepper setEnabled:YES];
    
    
}


/** Peripheral connected or disconnected */
- (void) alarmServiceDidChangeStatus:(LeTemperatureAlarmService*)service
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
- (void) alarmServiceDidReset
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
        peripheral = [(LeTemperatureAlarmService*)[devices objectAtIndex:row] peripheral];
        
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
        peripheral = [(LeTemperatureAlarmService*)[devices objectAtIndex:row] peripheral];
	} else {
		devices = [[LeDiscovery sharedInstance] foundPeripherals];
    	peripheral = (CBPeripheral*)[devices objectAtIndex:row];
	}
    
	if (![peripheral isConnected]) {
		[[LeDiscovery sharedInstance] connectPeripheral:peripheral];
        [_currentlyConnectedSensor setText:[peripheral name]];
        
        [_currentlyConnectedSensor setEnabled:NO];
        [_currentTemperatureLabel setEnabled:NO];
        [_maxAlarmLabel setEnabled:NO];
        [_minAlarmLabel setEnabled:NO];
    }
    
	else {
        
        if ( _currentlyDisplayingService != nil ) {
            _currentlyDisplayingService = nil;
        }
        
        _currentlyDisplayingService = [self serviceForPeripheral:peripheral];
        
        [_currentlyConnectedSensor setText:[peripheral name]];
        
        [_currentTemperatureLabel setText:[NSString stringWithFormat:@"%d", (int)[_currentlyDisplayingService temperature]]];
        [_maxAlarmLabel setText:[NSString stringWithFormat:@"MAX %dº", (int)[_currentlyDisplayingService maximumTemperature]]];
        [_minAlarmLabel setText:[NSString stringWithFormat:@"MIN %dº", (int)[_currentlyDisplayingService minimumTemperature]]];
        
        [_currentlyConnectedSensor setEnabled:YES];
        [_currentTemperatureLabel setEnabled:YES];
        [_maxAlarmLabel setEnabled:YES];
        [_minAlarmLabel setEnabled:YES];
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
- (IBAction) maxStepperChanged
{
    int newTemp = [_currentlyDisplayingService maximumTemperature] * 10;
    
    if (_maxAlarmStepper.value > 0) {
        newTemp+=10;
        NSLog(@"increasing MAX temp to %d", newTemp);
    }
    
    if (_maxAlarmStepper.value < 0) {
        newTemp-=10;
        NSLog(@"decreasing MAX temp to %d", newTemp);
    }
    
    // We're not interested in the actual VALUE of the stepper, just if it's increased or decreased, so reset it to 0 after a press
    [_maxAlarmStepper setValue:0];
    
    // Disable the stepper so we don't send multiple requests to the peripheral
    [_maxAlarmStepper setEnabled:NO];
    
    [_currentlyDisplayingService writeHighAlarmTemperature:newTemp];
}


/** Increase or decrease the minimum alarm setting */
- (IBAction) minStepperChanged
{
    int newTemp = [_currentlyDisplayingService minimumTemperature] * 10;
    
    if (_minAlarmStepper.value > 0) {
        newTemp+=10;
        NSLog(@"increasing MIN temp to %d", newTemp);
    }
    
    if (_minAlarmStepper.value < 0) {
        newTemp-=10;
        NSLog(@"decreasing MIN temp to %d", newTemp);
    }
    
    // We're not interested in the actual VALUE of the stepper, just if it's increased or decreased, so reset it to 0 after a press
    [_minAlarmStepper setValue:0];
    
    // Disable the stepper so we don't send multiple requests to the peripheral
    [_minAlarmStepper setEnabled:NO];
    
    [_currentlyDisplayingService writeLowAlarmTemperature:newTemp];
}

- (IBAction)startButtonPressed
{
    
    
}

- (IBAction)stopButtonPressed
{
    
    
}

@end
