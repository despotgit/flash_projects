<?php

class ScoreCalculator
{
    //Function returns score as a number of seconds
	public function calculate_score($hours_par, $minutes_par, $seconds_par, $tenths_par )
    {
	  return $hours_par*3600 + $minutes_par*60 + $seconds_par + $tenths_par*0.1;	
	
    }
	
	
	public function some()
	{
		
		
	}
	
	
	
	
	
	
	
}

?>