// ----------------------------------------------------
//
// Automated landing script for Huygens - Titan lander.
// Version: 1.0.0
//
// Author: meszib
//
// ----------------------------------------------------

clearscreen.

//
// Loading dependencies
//
print "Loading dependencies....".
copy Engines from 0.
copy LanderUtils from 0.
copy Navigation from 0.
copy Physics from 0.
copy StatusDisplay from 0.
copy Warping from 0.

//
// Run dependencies
//
run once Engines.
run once LanderUtils.
run once Navigation.
run once Physics.
run once StatusDisplay.
run once Warping.

//
// Set global variables
//
global globalScriptVersion to "1.0.0".
global globalThrottle to 0.
global globalSuicideBurnAltitude to 0.

//
// Entry point of the main program.
//
print "Starting main program....".
InitializeStatusDisplay( 5, 0.5 ).















// --------------------------------------------------------------------------------------
// Automated landing script for Huygens lander probe
// Version: 0.1
// Author: meszib
// --------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------
// PROGRAM PARAMETERS
// --------------------------------------------------------------------------------------
set delaySeparation to 5.
set targetPeriapsis to 75000.
set targetDescentVelocity to 3.
set highAtmoshpereLevel to 70000.
set lowAtmoshpereLevel to 3000.
set parachuteDeployLevel to 800.
set unfoldLevel to 10.

// Custom functions
// --------------------------------------------------------------------------------------
function PrintHUD
{
	parameter message.
	parameter color.
	hudtext( message, 5, 1, 12, color, false ).
	print message.
}.

function PrintHUDError
{
	parameter message.
	PrintHUD( message, red ).
}.

function PrintHUDWarning
{
	parameter message.
	PrintHUD( message, yellow ).
}.

function PrintHUDInfo
{
	parameter message.
	PrintHUD( message, green ).
}.

function Delay
{
	parameter remainingSeconds.
	parameter row.

	until remainingSeconds < 0
	{
		print "Remaining time seconds: " + remainingSeconds + "." at (0,row).
		set remainingSeconds to remainingSeconds - 1.
		wait 1.
	}
}

// STAGE 0: Booting sequence.
// --------------------------------------------------------------------------------------
clearscreen.
printHUDInfo( "STAGE #0: Huygens boot sequence has started..." ).
switch to 1.
SAS off.
RCS off.
lock processor to CORE:PART:GETMODULE( "kOSProcessor" ).
lock controller to ship:partstagged("Controller")[0].
lock engine to ship:partstagged("Engine")[0].
engine:shutdown().
set THROTTLE to 0.
set ship:name to "Huygens".
set ship:type to "Lander".

// STAGE 2: Waiting for separation (AG5)
printHUDInfo( "STAGE #1: Waiting for Huygens lander separation..." ).
set isSeparated to 0.
until isSeparated > 0
{
	on AG6
	{
		set isSeparated to 1.
		preserve.
	}
	wait 1.
}

// STAGE 2: Waiting for retrograde turn.
printHUDInfo( "STAGE #2: Waiting for RETROGRADE turn (" + delaySeparation + " seconds)..." ).
Delay( delaySeparation, 3 ).


// STAGE 3: Turning to Retrograde direction.
printHUDInfo( "STAGE #3: Turning to RETROGRADE direction..." ).
controller:CONTROLFROM().
SAS on.
lock STEERING to ship:RETROGRADE.
Delay( 3, 5 ).

// STAGE 4: Retrograde turn.
printHUDInfo( "STAGE #4: Change Periapsus to "+ targetPeriapsis + " meters..." ).
engine:activate().
set THROTTLE to 1.
until PERIAPSIS <= targetPeriapsis or engine:FLAMEOUT = 1
{
	wait 0.01.
}

engine:shutdown().
set THROTTLE to 0.

// STAGE 5: Descent into athmosphere.
printHUDInfo( "STAGE #5: Descent into upper athmosphere..." ).
lock STEERING to ship:SRFRETROGRADE.
Delay( 5, 7 ).

// STAGE 6: Science at upper atmosphere.
printHUDInfo( "STAGE #6: Executing basic science at " + highAtmoshpereLevel + " meters..." ).
until ALT:RADAR < highAtmoshpereLevel
{
	wait 1.
}
set AG9 to true.

// STAGE 7: Science in lower atmosphere.
printHUDInfo( "STAGE #7: Executing basic science at " + lowAtmoshpereLevel + " meters..." ).
until ALT:RADAR < lowAtmoshpereLevel
{
	wait 1.
}
set AG9 to false.
set AG9 to true.

// STAGE 8: Deploy parachutes.
printHUDInfo( "STAGE #8: Deploying parachutes at " + parachuteDeployLevel + " meters..." ).
until ALT:RADAR < parachuteDeployLevel
{
	wait 1.
}
set AG7 to true.

// STAGE 9: Unfold devices.
printHUDInfo( "STAGE #9: Unfold devices at " + unfoldLevel + " meters..." ).
until ALT:RADAR < unfoldLevel
{
	wait 1.
}
set AG8 to true.

// STAGE 10: Wait for touch down.
printHUDInfo( "STAGE #10: Waiting for touch down..." ).
until ALT:RADAR < 1
{
	wait 1.
}

// STAGE 11: Unfold devices.
printHUDInfo( "STAGE #11: Probe has successfully landed on the surface..." ).
wait 1.

// STAGE 12: Execute surface sciences
printHUDInfo( "STAGE #12: Executing surface science..." ).
set AG9 to false.
set AG9 to true.
wait 1.

// STAGE 13: Going to standby mode.
AddStatusMessage( "#13: Entering to standby mode..." ).
sas off.
rcs off.
unlock STEERING.
unlock THROTTLE.
