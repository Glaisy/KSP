@LAZYGLOBAL off.

//
// Gets the current gravitational acceleration [m/s2].
declare function GetLocalGravitationalAcceleration
{
	local r to body:radius + altitude.
	return body:mu / ( r * r ).
}

//
// Gets current TWR.
declare function GetThrustToWeightRatio
{
	return ship:availablethrust / ( ship:mass * GetLocalGravitationalAcceleration() ).
}
