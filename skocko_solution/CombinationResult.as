package  {
	
	import flash.display.MovieClip;
	
	
	public class CombinationResult extends MovieClip {
		/*
		
		1 - 0,0
        2 - 0,1
        3 - 0,2
        4 - 0,3
        5 - 0,4
        6 - 1,0
        7 - 1,1
        8 - 1,2
        9 - 1,3
        10 - 2,0
        11 - 2,1
        12 - 2,2
        13 - 3,0
        14 - 3,1
		15 - 4,0
		
		*/
		
		public function CombinationResult() {
			// constructor code

			this.scaleY = 0.082;
			this.scaleX = 0.082;
		}
		
		
		public function displayOutcome(correct:Number, misplaced:Number)
		{
		    trace ("we're at the beginning of displayoutcome, correct is: " + correct);
			switch (correct)
			{
			    case 0: trace ("cmon");
				    switch (misplaced) {
				    case 0:gotoAndStop(1);break;
					case 1:gotoAndStop(2);break;
					case 2:gotoAndStop(3);break;
					case 3:gotoAndStop(4);break;
					case 4:gotoAndStop(5);break;
				};
                 	trace ("here"); break;			
				
				case 1: 				    
				    switch (misplaced) {
				    case 0:gotoAndStop(6);break;
					case 1:gotoAndStop(7);break;
					case 2:gotoAndStop(8);break;
					case 3:gotoAndStop(9);break;
				}; break;
				
				
				case 2:
				switch (misplaced) {
				    case 0:gotoAndStop(10);break;
					case 1:gotoAndStop(11);break;
					case 2:gotoAndStop(12);break;				
				}; break;
				
				case 3:
				switch (misplaced) {
				    case 0:gotoAndStop(13);break;
				    case 1:gotoAndStop(14);break;
				}; break;
				
				case 4: gotoAndStop(15);break;
			    			    
			}
		}
	}
	
}
