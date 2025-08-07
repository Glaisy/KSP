// Required scripts:
// - StatusDisplay.ks

@LAZYGLOBAL off.

//
// Calculates the radial in vector for the current vessel.
declare function CalculateRadialInVector
{
	local positionVector to ( ship:position - ship:body:position ).
	local normalVector to vectorcrossproduct( ship:prograde:vector, positionVector ).
	return vectorcrossproduct( normalVector, ship:prograde:vector ):normalized.	
}

//
// Gets the true altitude over the surface [m].
declare function GetTrueAltitude
{
	return min( ship:altitude - ship:geoposition:terrainheight, alt:radar ).
}

//
// Waits until the vessel turns to the specified direction.
declare function WaitVesselToTurnToDirection
{
	parameter dir.
	local vec to dir:vector:normalized.
	WaitVesselToTurnToVector( dir:vector ).
}

//
// Waits until the vessel turns to the specified vector.
declare function WaitVesselToTurnToVector
{
	parameter vec.
	set vec to vec:normalized.
	local isTurnFinished to false.
	local stabilityCheckTime to 0.
	until( isTurnFinished = true )
	{
		// facing is close enough to the specified vector ( difference is smaller than 5 degrees )
		if( vectordotproduct( vec, ship:facing:vector ) > 0.995 )
		{
			// yes
			// did it happened first time?
			if( stabilityCheckTime = 0 )
			{
				// yes, run stability check
				set stabilityCheckTime to time:seconds.
			}
			else
			{
				// is stable for at least 2 seconds?
				if( ( time:seconds - stabilityCheckTime ) >= 2.0 )
				{
					// yes, turn is finished
					set isTurnFinished to true.
				}
			}
		}
		else
		{
			// no, reset
			set stabilityCheckTime to 0.
		}

		// update status
		DisplayStatusInformation().

		// wait a little.
		wait 0.1.
	}
}
