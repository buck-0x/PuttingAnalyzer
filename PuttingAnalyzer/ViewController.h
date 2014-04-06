/*
 
 File: ViewController.h
 
 Abstract: User interface to display a list of discovered peripherals
 and allow the user to connect to them.
 
 */

#import <UIKit/UIKit.h>
#import "DistanceGraphViewController.h"
#import "LeDiscovery.h"
#import "LeStrokeDataService.h"
#import "SERVICES.h"

@interface ViewController : UIViewController <LeDiscoveryDelegate, StrokeDataProtocol, UITableViewDataSource, UITableViewDelegate>
    @property (strong, nonatomic) LeStrokeDataService       *currentlyDisplayingService;
    @property (strong, nonatomic) NSMutableArray            *connectedServices;
    @property (strong, nonatomic) IBOutlet UILabel          *currentlyConnectedSensor;
    @property (strong, nonatomic) IBOutlet UILabel          *currentDistanceLabel;
    @property (strong, nonatomic) IBOutlet UITableView      *sensorsTable;

    @property (strong, nonatomic) NSMutableArray            *heightValues;
@end

