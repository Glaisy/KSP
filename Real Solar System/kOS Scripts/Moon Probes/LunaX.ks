// --------------------------------------------------------------------------------------
// Automated landing script for Luna-X - Moon probes.
// Version: 1.0.0
// Author: meszib
// --------------------------------------------------------------------------------------

clearscreen.

// 1) Loading dependencies
print "Loading dependencies....".
copypath( "0:/Libraries/Engines", "" ).
copypath( "0:/Libraries/LanderUtils", "" ).
copypath( "0:/Libraries/Navigation", "" ).
copypath( "0:/Libraries/Physics", "" ).
copypath( "0:/Libraries/Warping", "" ).
copypath( "0:/Libraries/StatusDisplay", "" ).

// 2) Run dependencies
run once Engines.
run once LanderUtils.
run once Navigation.
run once Physics.
run once Warping.
run once StatusDisplay.

// 3) Set global variables
global globalThrottle to 0.
global globalSuicideBurnAltitude to 0.

// 4) Entry point of the main program.
print "Starting main program....".
InitializeStatusDisplay( 5, 0.5 ).
InitializeVesselSystems( "" ).

// 5) Periapsis adjustment
if( orbit:periapsis > 30000 )
{
	AdjustOrbitPeriapsis( 30000 ).
}

// 6) Reduce horizontal ground speed at periapsis ( horizontalVelocity ).
ExecuteHorizontalVelocityReductionBurn( 350 ).

// 7) Execute suicide burn ( finalAlt, finalVelocity, thrust efficiency rate )
ExecuteVacuumSuicideBurn( 100, 20, 1.00 ).

// 8) Final descent burn ( finalAlt, finalVelocity, tdVelocity , cutOffAlt, isSkyCrane )
ExecuteFinalDescentBurn( 100, 20, 3, 3, false ).

// 9) instruments and collect science.
wait 5.
ag10 on.
