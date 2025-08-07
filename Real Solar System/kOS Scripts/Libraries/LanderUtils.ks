// Required scripts:
// - Engines.ks
// - Navigation.ks
// - Physics.ks
// - StatusDisplay.ks
// - Warping.ks
//
// External variable dependencies:
//  - globalThrottle: Global variable for throttle value.
//  - globalSuicideBurnAltitude: Global variable for suicide burn altitude value.

@LAZYGLOBAL off.

//
// Adjusts vessel's orbit's periapsis to the specified value.
//
// Parameters: requiredPeriapsis
function AdjustOrbitPeriapsis
{
	parameter requiredPeriapsis.

	// Turn vessel to the right direction
	if( orbit:apoapsis > 0 )
	{		
		// elliptic orbit, burn at apoapsis.
		AddStatusMessage( "Elliptic orbit - Adjusting periapsis to " + requiredPeriapsis + "m at apoapsis..." ).
		if( eta:apoapsis > 180 )
		{
			WarpSeconds( eta:apoapsis - 180 ). 
		}
		if( orbit:periapsis > requiredPeriapsis )
		{
			// descrease - retro burn	
			lock steering to ship:retrograde.
			WaitVesselToTurnToDirection( ship:retrograde ).
		}
		else
		{
			// increase - prograde burn
			lock steering to ship:prograde.
			WaitVesselToTurnToDirection( ship:prograde ).
		}	
		
		// wait to apoapis
		if( eta:apoapsis > 5 )
		{
			WarpSeconds( eta:apoapsis - 5 ).
		}
		if( eta:apoapsis > 1 )
		{
			wait( eta:apoapsis - 1 ).
		}
	}
	else
	{
		// hyperbolic orbit, burn instantly
		AddStatusMessage( "Hyperbolic orbit - Adjusting periapsis to " + requiredPeriapsis + "m..." ).

		// get radial-in vector.
		local radialInVector to CalculateRadialInVector().

		// increase or decrease?
		if( orbit:periapsis > requiredPeriapsis )
		{
			// descrease - radial-out burn	
			lock steering to -radialInVector.
			WaitVesselToTurnToVector( -radialInVector ).
		}
		else
		{
			// increase - radial-in burn
			lock steering to radialInVector.
			WaitVesselToTurnToVector( radialInVector ).
		}
	}

	// Execute periapsis correction burn 
	AddStatusMessage( "Executing periapsis correction burn..." ).
	local periapsisErrorMargin to 0.2 * requiredPeriapsis.
	local maxThrottle to GetThrottleLimit( 5.0 ).
	if( orbit:periapsis > requiredPeriapsis )
	{
		until( orbit:periapsis <= requiredPeriapsis )
		{
			set globalThrottle to maxThrottle * max( 0.01, min( orbit:periapsis - requiredPeriapsis, periapsisErrorMargin ) / periapsisErrorMargin ).
			DisplayStatusInformation().
			wait 0.1.
		}
	}
	else
	{ 
		until( orbit:periapsis >= requiredPeriapsis )
		{
			set globalThrottle to maxThrottle * max( 0.01, min( requiredPeriapsis - orbit:periapsis, periapsisErrorMargin ) / periapsisErrorMargin ).
			DisplayStatusInformation().
			wait 0.1.
		}
	}

	// engine cut off
	set globalThrottle to 0.

	// update status
	DisplayStatusInformation( true ).
}

//
// Executes final descent burn [Expectation: steering is locked to SRFRETROGRADE]
//
// - finalDescentAltitude: final descent altitude [m].
// - finalDescentVelocity: final descent start velocity [m/s].
// - touchdownVelocity: touchdown velocity [m/s].
// - cutOffAltitude:	engine/skycrane cut-off altitude
// - isSkyCrane: if true staging is activated at touchdown instead of engine cut off.
declare function ExecuteFinalDescentBurn
{
	parameter finalDescentAltitude.
	parameter finalDescentVelocity.
	parameter touchdownVelocity.
	parameter cutOffAltitude.
	parameter isSkyCrane.

	AddStatusMessage( "Executing final descent burn..." ).
	local altitudeFromSurface to GetTrueAltitude().
	local desiredVelocity to 0.
	local dV to finalDescentVelocity - touchdownVelocity.
	local dH to finalDescentAltitude - cutOffAltitude.
	until( altitudeFromSurface < cutOffAltitude )
	{
		// calculate desired velocity
		if( altitudeFromSurface > finalDescentAltitude )
		{
			set desiredVelocity to finalDescentVelocity.
		}
		else
		{
			set desiredVelocity to touchdownVelocity + dV * ( altitudeFromSurface - cutOffAltitude ) / dH. 
		}

		// adjust throttle.
		if( ship:velocity:surface:mag > desiredVelocity )
		{
			set globalThrottle to min( 1, globalThrottle + 0.035 ).
		}
		else if( ship:velocity:surface:mag < desiredVelocity )
		{
			set globalThrottle to max( 0, globalThrottle - 0.1 ).
		}

		// display status
		DisplayStatusInformation().
		wait 0.1.

		// update terrain height
		set altitudeFromSurface to GetTrueAltitude().
	}

	// cut off
	if( isSkyCrane = true )
	{
		AddStatusMessage( "Dropping payload to the surface..." ).
		stage.
	}
	else
	{
		AddStatusMessage( "Engine cut-off..." ).
		set globalThrottle to 0.
		ShutdownCurrentStageEngines().
	}

	// stabilization.
	AddStatusMessage( "Stabilizing vessel..." ).
	unlock throttle.
	unlock steering.
	sas on.
	wait 5.
	sas off.
	rcs off.
}

//
// Reduce horizontal ground speed to the specified value at periapis.
//
// Parameters: requiredHorizontalGroundSpeed
declare function ExecuteHorizontalVelocityReductionBurn
{
	parameter requiredHorizontalGroundSpeed.

	AddStatusMessage( "Reducing horizontal surface velocity at periapsis..." ).

	// turn to surface retrograde at periapsis
	if( eta:periapsis > 180 )
	{
		WarpSeconds( eta:periapsis - 180 ). 
	}
	lock steering to ship:srfretrograde.
	WaitVesselToTurnToDirection( ship:srfretrograde ).
	if( eta:periapsis > 5 )
	{
		WarpSeconds( eta:periapsis - 5 ).
	}
	wait( eta:periapsis ).

	// execute burn
	set globalThrottle to 1.
	until( ship:groundspeed < requiredHorizontalGroundSpeed )
	{
		if( ship:availablethrust = 0 )
		{
			stage.
		}
		DisplayStatusInformation().
		wait 0.1.
	}

	// engine cut off
	set globalThrottle to 0.

	// update status
	DisplayStatusInformation( true ).
}

//
// Executes vacuum suicide burn. [Expectation: steering is locked to SRFRETROGRADE]
//
// Parameters:  
// - finalDescentAltitude: final descent altitude [m].
// - finalDescentVelocity: final descent start velocity [m/s].
// - engineThrustVerticalComponent: engine thrust vertical component [0...1].
declare function ExecuteVacuumSuicideBurn
{
	parameter finalDescentAltitude.
	parameter finalDescentVelocity.
	parameter engineThrustVerticalComponent is 1.0.

	// turn on gears and lights.
	AddStatusMessage( "Extending landing gears and turn on lights..." ).
	gear on.
	gear off. 
	gear on.
	lights on.
	brakes on. 

	// Enter waiting loop
	AddStatusMessage( "Waiting for suicide burn..." ).

	// engine acceleration [approximation: let's suppose mass is not changing significantly].
	local engineAcceleration to engineThrustVerticalComponent * ( ship:availableThrust / ship:mass ).

	// waiting loop
	set globalSuicideBurnAltitude to 0.
	local altitudeFromSurface to GetTrueAltitude().
	until( altitudeFromSurface <= globalSuicideBurnAltitude or 
		   altitudeFromSurface <= finalDescentAltitude )
	{
		// average surface gravity.
		local descentHeight to altitudeFromSurface - finalDescentAltitude.
		local altitudeFinal to ( altitude - descentHeight ).
		local avgSurfaceGravity to body:mu / ( body:radius + altitude ) / ( body:radius + altitudeFinal ).

		// average deccelaration
		local avgDecceleration to engineAcceleration - avgSurfaceGravity.

		// velocity change.
		local dV to ship:velocity:surface:mag - finalDescentVelocity.

		// suicide burn altitude
		set globalSuicideBurnAltitude to finalDescentAltitude + 0.5 * dv *( 2 * ship:velocity:surface:mag - dv ) / avgDecceleration.

		// update status
		DisplayStatusInformation().
		wait 0.1.

		// update height
		set altitudeFromSurface to GetTrueAltitude().
	}

	//
	// Stage: Executing suicide burn
	//
	AddStatusMessage( "Executing suicide burn..." ).
	set globalThrottle to 1.
	until( GetTrueAltitude() < finalDescentAltitude or ship:velocity:surface:mag < finalDescentVelocity )
	{
		DisplayStatusInformation().
		wait 0.1.
	}
}

//
// Initialize vessel systems.
//
// Parameters: tagCommandModule - command module tag
declare function InitializeVesselSystems
{
	parameter tagCommandModule.

	AddStatusMessage( "Initialize vessel systems..." ).
	local commandModules to ship:partstagged( tagCommandModule ).
	if( commandModules:length() > 0 )
	{
		commandModules[0]:controlfrom().
	}
	unlock throttle.
	unlock steering.
	set sas to false.
	rcs on.
	set globalThrottle to 0.
	set globalSuicideBurnAltitude to 0.
	lock throttle to globalThrottle.
	if( ship:availablethrust <= 0 )
	{
		ActivateCurrentStageEngines().
		if( ship:availablethrust <= 0 )
		{
			stage.
			ActivateCurrentStageEngines().
			if( ship:availablethrust <= 0 )
			{
				AddStatusMessage( "Engine activation failed. Stopping." ).
				exit.
			}
		}
	}
	DisplayStatusInformation( true ).
}
