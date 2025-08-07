@LAZYGLOBAL off.

//
// Activates engines for the current stage.
//
declare function ActivateCurrentStageEngines
{
	ActivateStageEngines( stage:number ).
}

//
// Activates engines for the specified stage.
//
// Parameters: stageNumber
//
declare function ActivateStageEngines
{
	declare parameter stageNumber.
	local allEngines to list().
	list engines in allEngines.
	for eng in allEngines
	{
		if( eng:stage = stageNumber )
		{
			eng:activate().
		}
	}
}

//
// Shutdowns engines for the current stage.
//
declare function ShutdownCurrentStageEngines
{
	ShutdownStageEngines( stage:number ).
}

//
// Shutdowns engines for the specified stage.
//
// Parameters: stageNumber
//
declare function ShutdownStageEngines
{
	declare parameter stageNumber.
	local allEngines to list().
	list engines in allEngines.
	for eng in allEngines
	{
		if( eng:stage = stageNumber )
		{
			eng:shutdown().
		}
	}
}

//
// Gets the average ISP of engines for the current stage.
//
declare function GetCurrentStageEnginesISP
{
	return GetStageEnginesISP( stage:number ).
}

//
// Gets the average ISP of engines for the specified stage.
//
// Parameters: stageNumber
//
declare function GetStageEnginesISP
{
	declare parameter stageNumber.
	local sumOfThrust to 0.
	local weightedSum to 0.
	local allEngines to list().
	list engines in allEngines.
	for eng in allEngines
	{
		if( eng:stage = stageNumber and
			eng:ignition )
		{
			set sumOfThrust to sumOfThrust + eng:availablethrust.
			set weightedSum to weightedSum + eng:availablethrust * eng:isp.
		}
	}

	if( sumOfThrust <> 0 )
	{
		return weightedSum / sumOfThrust.
	}
	return 0.
}

//
// Gets the throttle limit for the specified acceleration.
//
// Parameters: acceleration [m/s2]
//
declare function GetThrottleLimit
{
	parameter acceleration.
	return min( 1, acceleration * ship:mass / ship:availablethrust ).
}