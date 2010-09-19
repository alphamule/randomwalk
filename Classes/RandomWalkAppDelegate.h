//
//  RandomWalkAppDelegate.h
//  RandomWalk
//
//  Created by Eric Wagner on 9/14/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface RandomWalkAppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate> {
    UIWindow *window;
	CLLocationManager *locationManagerLabel;
	CLLocationDirection goalDirection;
	CLLocationDirection currentDirection;
	CLLocationCoordinate2D currentLocation;
	CLLocationCoordinate2D homeLocation;
	IBOutlet UILabel *currentDirectionLabel;
	IBOutlet UILabel *goalDirectionLabel;
	IBOutlet UILabel *turnLabel;
	IBOutlet UILabel *waypointsLabel;
	IBOutlet UILabel *crowFliesDistanceLabel;
	IBOutlet UILabel *waypointsDistanceLabel;
	IBOutlet UILabel *directionToHomeLabel;
	NSMutableArray *locations;
	NSString *lastTurn;
	bool homeLocationInitialized;
	bool goalDirectionInitialized;
	bool lastTurnInitialized;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

- (CLLocationDistance)waypointDistance;
- (IBAction)generateTurn;
- (IBAction)setHome;
- (IBAction)preferThisDirection;
- (NSString *)pickDirection;
- (void)redraw;
- (CLLocationDirection)directionToHome;
- (void)redrawTurnLabel;
- (void)redrawGoalDirectionLabel;
- (void)redrawDirectionToHomeLabel;
- (void)redrawWaypointDistanceLabel;
- (void)redrawDistanceFromHomeLabel;

@end

