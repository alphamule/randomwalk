//
//  RandomWalkAppDelegate.m
//  RandomWalk
//
//  Created by Eric Wagner on 9/14/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "RandomWalkAppDelegate.h"
#import <math.h>
#import <stdlib.h>


@implementation RandomWalkAppDelegate

@synthesize window;

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};

CLLocationDistance distanceFrom(CLLocationCoordinate2D fromCoord, CLLocationCoordinate2D toCoord)
{
	CLLocation *from = [[[CLLocation alloc] initWithLatitude:fromCoord.latitude longitude:fromCoord.longitude] autorelease];
	CLLocation *to = [[[CLLocation alloc] initWithLatitude:toCoord.latitude longitude:toCoord.longitude] autorelease];
	return [to distanceFromLocation:from];
};

NSString *descriptionForDegrees(CLLocationDirection heading)
{
	if (heading <= 11.25 || heading > 348.75) {
		return @"N";
	} else if (heading <= 11.5) {
		return @"NNE";
	} else if (heading <= 33.75) {
		return @"NE";
	} else if (heading <= 56.25) {
		return @"ENE";
	} else if (heading <= 78.75) {
		return @"E";
	} else if (heading <= 101.25) {
		return @"ESE";
	} else if (heading <= 123.75) {
		return @"SE";
	} else if (heading <= 146.25) {
		return @"SSE";
	} else if (heading <= 168.75) {
		return @"S";
	} else if (heading <= 191.25) {
		return @"SSW";
	} else if (heading <= 213.75) {
		return @"SW";
	} else if (heading <= 236.25) {
		return @"WSW";
	} else if (heading <= 258.75) {
		return @"W";
	} else if (heading <= 281.25) {
		return @"WNW";
	} else if (heading <= 303.75) {
		return @"NW";
	} else { // if (heading <= 326.75) {
		return @"NNW";
	}
}


- (NSString *)pickDirection
{
	CLLocationDirection relativeDirection = goalDirection - currentDirection;
	int oddsOfStraight = (int)((cos(DegreesToRadians(relativeDirection)) + 1) / 2 * 100);
	int oddsOfRight = (int)((cos(DegreesToRadians(relativeDirection - 90)) + 1) / 2 * 100);
	int oddsOfLeft = (int)((cos(DegreesToRadians(relativeDirection + 90)) + 1) / 2 * 100);
	
	int totalOdds = oddsOfStraight + oddsOfRight + oddsOfLeft;
	NSString *oddsString = [NSString stringWithFormat:@"L:%d S:%d R:%d", oddsOfLeft, oddsOfStraight, oddsOfRight];
	int randomValue = random() % totalOdds;
	
	NSString *direction;
	if (randomValue < oddsOfLeft) {
		direction = @"left";
	} else {
		randomValue -= oddsOfLeft;
		if (randomValue < oddsOfStraight) {
			direction = @"straight";
		} else {
			direction = @"right";
		}
	}
	
	return [NSString stringWithFormat:@"%@ (%@)", direction, oddsString];
}

- (CLLocationDistance)waypointDistance
{
	CLLocationDistance totalDistance = 0;
	int count = [locations count];
	for (int i = 0; i < count-1; i++) {
		CLLocationCoordinate2D first;
		CLLocationCoordinate2D second;
		[[locations objectAtIndex:i] getBytes:&first length:sizeof(first)];
		[[locations objectAtIndex:i+1] getBytes:&second length:sizeof(second)];

 		totalDistance += distanceFrom(first, second);
	}
	return totalDistance;
}

- (IBAction)generateTurn {
	lastTurnInitialized = TRUE;
	if ([locations count] == 0) {
		[self setHome];
	} else {
		[locations addObject:[NSData dataWithBytes:&currentLocation length:sizeof(currentLocation)]];
	}
	[lastTurn autorelease];
	lastTurn = [[self pickDirection] retain];
	[self redraw];
}

- (IBAction)setHome {
	homeLocationInitialized = TRUE;
	homeLocation = currentLocation;
	
	[locations release];
	locations = [[NSMutableArray alloc] init];
	[locations addObject:[NSData dataWithBytes:&currentLocation length:sizeof(currentLocation)]];
	
	[self redraw];
}

- (IBAction)preferThisDirection {
	goalDirectionInitialized = TRUE;
	goalDirection = currentDirection;
	[self redraw];
}


- (void)redraw
{
	[self redrawTurnLabel];
	[self redrawWaypointDistanceLabel];
	[currentDirectionLabel setText:[NSString stringWithFormat:@"Current Direction: %@", descriptionForDegrees(currentDirection)]];
	[self redrawGoalDirectionLabel];
	[self redrawDistanceFromHomeLabel];
	[waypointsLabel setText:[NSString stringWithFormat:@"Waypoints: %d", [locations count]]];
	[self redrawDirectionToHomeLabel];
}

- (void)redrawWaypointDistanceLabel
{
	if ([locations count] > 1) {
		[waypointsDistanceLabel setText:[NSString stringWithFormat:@"Waypoint Distance: %dm", (int)[self waypointDistance]]];
	} else {
		[waypointsDistanceLabel setText:@"Waypoint Distance: [generate turn]"];
	}

}
- (void)redrawDistanceFromHomeLabel
{
	if (homeLocationInitialized) {
		[crowFliesDistanceLabel setText:[NSString stringWithFormat:@"Distance From Home: %dm", (int)distanceFrom(homeLocation, currentLocation)]];
	} else {
		[crowFliesDistanceLabel setText:@"Distance From Home: [set home]"];
	}

}

- (void)redrawTurnLabel
{
	if (lastTurnInitialized) {
		[turnLabel setText:[NSString stringWithFormat:@"Turn: %@", lastTurn]];		
	} else {
		[turnLabel setText:@"Turn: [generate turn]"];
	}
}

- (void)redrawGoalDirectionLabel
{
	if (goalDirectionInitialized) {
		[goalDirectionLabel setText:[NSString stringWithFormat:@"Goal Direction: %@", descriptionForDegrees(goalDirection)]];
	} else {
		[goalDirectionLabel setText:@"Goal Direction: [prefer this direction]"];
	}
}

- (void)redrawDirectionToHomeLabel {
	if (homeLocationInitialized) {
		[directionToHomeLabel setText:[NSString stringWithFormat:@"Direction To Home: %@", descriptionForDegrees([self directionToHome])]];
	} else {
		[directionToHomeLabel setText:@"Direction To Home: [set home]"];
	}
}

- (CLLocationDirection)directionToHome
{
	CLLocationDegrees x = homeLocation.longitude - currentLocation.longitude;
	CLLocationDegrees y = homeLocation.latitude - currentLocation.latitude;
	if (x == 0) {
		x = .00001;
	}
	
	return RadiansToDegrees(atan(y/x));
}

#pragma mark -
#pragma mark Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	currentLocation = newLocation.coordinate;
	[self redraw];

}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
	currentDirection = newHeading.trueHeading;
	[self redraw];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"Could not find location: %@", error);
}


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

	locationManagerLabel = [[CLLocationManager alloc] init];
	[locationManagerLabel setDelegate:self];
	[locationManagerLabel setDistanceFilter:kCLDistanceFilterNone];
	[locationManagerLabel setDesiredAccuracy:kCLLocationAccuracyBest];
	[locationManagerLabel startUpdatingLocation];
	[locationManagerLabel startUpdatingHeading];
	
	locations = [[NSMutableArray alloc] init];
	goalDirectionInitialized = FALSE;
	homeLocationInitialized = FALSE;
	lastTurnInitialized = FALSE;
	
    [window makeKeyAndVisible];

	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of
	 temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application 
	 and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. 
	 Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application
	 state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously 
	 in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
