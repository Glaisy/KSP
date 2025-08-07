// --------------------------------------------------------------------------------------
//
// Automated landing script for Venera-10 Lander probe.
// KOS Version: 1.0.5
//
// Author: meszib
//
// --------------------------------------------------------------------------------------

clearscreen.

// 1) Loading dependencies
print "Loading dependencies....".
copypath( "0:/Physics", "" ).
copypath( "0:/Navigation", "" ).
copypath( "0:/StatusDisplay", "" ).

// 2) Run dependencies
run once Navigation.
run once Physics.
run once StatusDisplay.

// 3) Set global variables
global globalScriptVersion to "1.0.0".
global globalThrottle to 0.
global globalSuicideBurnAltitude to 0.

// 4) Entry point of the main program.
print "Starting main program....".
InitializeStatusDisplay( 5, 0.5 ).

// 5) Waiting for approaching the atmosphere
AddStatusMessage( "Waiting for entering atmosphere. " ).
until( GetTrueAltitude() < 140000 )
{
	DisplayStatusInformation().
	wait 0.25.
}
set warp to 0.

// 6) Turn to surface-retrograde 
AddStatusMessage( "Turn and lock lander to surface retrograde direction." ).
lock steering to ship:srfretrograde.
WaitVesselToTurnToDirection( ship:srfretrograde ).

// 7) Arm parachutes
AddStatusMessage( "Parachutes are armed...(Deyployed at 0.9atm and 5km)" ).
stage.

// 8) Dropping first chutes and upper shield
AddStatusMessage( "Jettisoning upper shield and drogue chute at 6km." ).
until( GetTrueAltitude() < 6000 )
{
	DisplayStatusInformation().
	wait 0.25.
}
stage.

// 9) Dropping heatshield
AddStatusMessage( "Jettisoning heat shield 4km." ).
until( GetTrueAltitude() < 4000 )
{
	DisplayStatusInformation().
	wait 0.25.
}
stage.

// 10) waiting for landing
AddStatusMessage( "Deploy antenna at surface." ).
until( ship:status = "LANDED" )
{
	DisplayStatusInformation().
	wait 0.25.
}
ag9 on.
ag9 off.

// 11) Waiting for connection.
AddStatusMessage( "Waiting for RT connection." ).
until( addons:rt:haskscconnection( ship ) = true )
{
	DisplayStatusInformation().
	wait 0.5.
}

// 12) Deploy instruments and collect science.
AddStatusMessage( "Collecting science." ).
ag0 on.
ag0 off.
