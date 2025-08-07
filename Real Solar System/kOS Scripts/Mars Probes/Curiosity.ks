clearscreen.

//
// Loading dependencies
//
print "Loading dependencies....".
copypath( "0:/Libraries/Engines", "" ).
copypath( "0:/Libraries/LanderUtils", "" ).
copypath( "0:/Libraries/Navigation", "" ).
copypath( "0:/Libraries/Physics", "" ).
copypath( "0:/Libraries/Warping", "" ).
copypath( "0:/Libraries/StatusDisplay", "" ).

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
// PARAMETERS
//
local initialPeriapis to 18000.
local altitudeDropTransferStage to 125000.
local altArmChute to 11000.
local altJettisonShield to 5000.
local altFinalDescent to 200.
local velocityFinalDescent to 20.
local velocityTouchdown to 3.
local altCutOff to 3.

//
// Entry point of the main program.
//
print "Starting main program....".
InitializeStatusDisplay( 5, 0.5 ).

// Stage: Initialization
InitializeVesselSystems( "#DescentCommandModule" ).

// Stage: Adjusting orbit periapsis
AdjustOrbitPeriapsis( initialPeriapis ).

// Stage: Lock steering to surface retrograde.
AddStatusMessage( "Holding surface retrograde direction..." ).
lock steering to ship:srfretrograde.
WaitVesselToTurnToDirection( ship:srfretrograde ).

// Stage: Transfer stage separation
AddStatusMessage( "Transfer stage separation at " + ( altitudeDropTransferStage / 1000 ) + "km altitude..." ).
until( ship:altitude < altitudeDropTransferStage )
{
	DisplayStatusInformation().
	wait 0.5.
}
stage.
rcs off.

// Stage: Deploy chute
AddStatusMessage( "Arm drogue chute at " + altArmChute + "m..." ).
until( ship:altitude < altArmChute )
{
	DisplayStatusInformation().
	wait 0.5.
}
stage.

// Stage: Jettison heat fairings.
AddStatusMessage( "Jettison heatshield and fairings at " + altJettisonShield + "m..." ).
until( GetTrueAltitude() < altJettisonShield )
{
	DisplayStatusInformation().
	wait 0.5.
}
stage.
wait 1.
stage.	
rcs on.
wait 1.

// Stage: Execute suicide burn
AddStatusMessage( "Suicide burn..." ).
stage.
ExecuteVacuumSuicideBurn( altFinalDescent, velocityFinalDescent, 0.7 ).

// Stage: Final descent burn
ExecuteFinalDescentBurn( altFinalDescent, velocityFinalDescent, velocityTouchdown, altCutOff, true ).

// Stage: Deploy instruments and collect science.
AddStatusMessage( "Deploying panels, antenna and devices." ).
ag9 on.
ag9 off.
wait 0.1.
local commandModules to ship:partstagged( "#RoverCommandModule" ).
if( commandModules:length() > 0 )
{
	commandModules[0]:controlfrom().
}
brake on.
wait 0.1.

// Stage: Waiting for connection.
AddStatusMessage( "Waiting for RT connection." ).
until( addons:rt:haskscconnection( ship ) = true )
{
	DisplayStatusInformation().
	wait 0.5.
}

// Stage: Collect science
AddStatusMessage( "Collect and transmit science." ).
ag10 on.
ag10 off.

// Stage: Standby mode
unlock throttle.
unlock steering.
sas off.
rcs off.
