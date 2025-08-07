// Required scripts:
// - Navigation.ks
// - Physics.ks
//
// External variable dependencies:
//  - globalScriptVersion: Global script version number
//  - globalThrottle: Global variable for throttle value.
//  - globalSuicideBurnAltitude: Global variable for suicide burn altitude value.

@LAZYGLOBAL off.

//
// Initialize local variables
local statusList to list().
local lastUpdate to 0.
local earthMass to body( "Earth" ):mass.
local updateInterval to 0.5.
local historyLength to 5.


//
// Adds a status message to the status list.
declare function AddStatusMessage
{
	parameter message.

	// is valid message?
	if( message:length() > 0 )
	{
		// remove old list items
		until statusList:length() <= historyLength
		{
			statusList:remove(0).
		}

		// add message at the end
		statusList:add( message ).

		// display status information
	    DisplayStatusInformation( true ).
	}
}

//
// Initializes status display parameters.
//
// - pHistoryLength: number of entries in message history.
// - pUpdateInterval: Status display update interval [s].
declare function InitializeStatusDisplay
{
	parameter pHistoryLength.
	parameter pUpdateInterval.

	if( pHistoryLength > 0 )
	{
		set historyLength to pHistoryLength.
	}
	if( pUpdateInterval > 0 )
	{
		set updateInterval to pUpdateInterval.
	}

	// display status information
	DisplayStatusInformation( true ).
}

//
// Displays status information
declare function DisplayStatusInformation
{
	parameter isForced is false.
	if( ( isForced = true ) or 
	    ( ( time:seconds - lastUpdate ) > updateInterval ) )
	{
		clearscreen.

		// header
		print "Autonomous probe control script".
		print "===============================================".
		print " ".

		// body
		local r to body:radius + altitude.
		print "Body [" + body:name + "]" at(37, 3).
		print "---------------------------------" at(37, 4).
		print "Mass          : " + round( body:mass / earthMass, 3 ) + " Earth mass" at(37, 5).
		print "Radius        : " +  round( body:radius / 1000, 1 ) + " km" at(37, 6).
		print "Gravity       : " +  round( GetLocalGravitationalAcceleration(), 2 ) + " m/s2" at(37, 7).
	
		// control
		print "Controls" at(37, 9).
		print "-----------------------" at(37, 10).
		print "Throttle: " + round( 100 * globalThrottle, 2 ) + "%" at(37, 11).
		print "Suicide burn alt.: " + round( globalSuicideBurnAltitude, 1 ) + "m" at(37, 12).
	
		// vessel
		print "Vessel [" + ship:name + "]".
		print "-----------------------------------".
		print "Mass             : " + round(ship:mass, 2 ) + "t".
		print "TWR              : " + round( GetThrustToWeightRatio(), 2 ).
		print "Status           : " + ship:status.
		print "Apoapsis         : " + round(ship:orbit:apoapsis, 1 ) + "m".
		print "Periapsis        : " + round(ship:orbit:periapsis, 1 ) + "m".
		print "Altitude         : " + round(ship:altitude, 1 ) + "m".
		print "Surface distance : " + round(GetTrueAltitude(), 1 ) + "m".
		print "Hor. speed       : " + round(ship:groundspeed, 2 ) + " m/s".
		print "Vert. speed      : " + round(ship:verticalspeed, 2 ) + "m/s".

		// status messages
		print " ".
		print "Status log".
		print "-----------------".
		for msg in statusList
		{
			print msg.
		}
		print " ".

		// set update time
		set lastUpdate to time:seconds.
	}
}