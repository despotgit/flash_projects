package  {
	
import flash.display.MovieClip;
		
public class Combination extends MovieClip {
    
	const SPADES:Number = 1;
	const CLUBS:Number = 2;
	const HEARTS:Number = 3;
	const DIAMONDS:Number = 4;
	const JUMPER:Number = 5;
	const STAR:Number = 6;	
	
	public function Combination() 
	{
	
	}
	
    public function displaySigns(a, b, c, d:Number) 
	{
	    
		sign1.beA(a);
		sign2.beA(b);
		sign3.beA(c);
		sign4.beA(d);
	}	
	
	public function setSignTo(ordinal:Number, what:Number) 
	{
	    switch(ordinal) {
		    case 1: sign1.beA(what); break;
			case 2: sign2.beA(what); break;
			case 3: sign3.beA(what); break;
			case 4: sign4.beA(what); break;
		
		}
	    
	}
	
	public function reset()
	{
	    sign1.reset();
		sign2.reset();
		sign3.reset();
		sign4.reset();
		
	}
	
}
}