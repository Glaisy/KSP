@LAZYGLOBAL off.

declare function WarpSeconds
{
	parameter dt.
	
	set dt to round(dt ).

	if( dt > 0 )
	{
		local tEnd to round( time:seconds + dt ).
		if( dt > 60 )
		{
			set warp to 3.
		}
		if(  dt > 60 )
		{
			when( time:seconds > tEnd - 60 ) then
			{
				set warp to 2.
			}
		}
		if( dt > 30 )
		{
			when( time:seconds > tEnd - 30 ) then
			{
				set warp to 1.
			}
		}
		if( dt > 10 )
		{
			when( time:seconds > tEnd - 10 ) then
			{
				set warp to 0.
			}
		}
		wait until time:seconds > tEnd.
		set warp to 0.
	}
}
