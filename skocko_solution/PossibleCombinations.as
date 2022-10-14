package  {
	
	import flash.display.MovieClip;
	
	
	public class PossibleCombinations extends MovieClip {
		
		var combinations:Array;
		
		public function PossibleCombinations() {
			// constructor code
			
			combinations = new Array();
		    
			combinations.push(combination1);combinations.push(combination2);combinations.push(combination3);combinations.push(combination4);
			combinations.push(combination5);combinations.push(combination6);combinations.push(combination7);combinations.push(combination8);
			combinations.push(combination9);combinations.push(combination10);combinations.push(combination11);combinations.push(combination12);
			combinations.push(combination13);combinations.push(combination14);combinations.push(combination15);combinations.push(combination16);
			combinations.push(combination17);combinations.push(combination18);combinations.push(combination19);combinations.push(combination20);
			combinations.push(combination21);combinations.push(combination22);combinations.push(combination23);combinations.push(combination24);
			combinations.push(combination25);combinations.push(combination26);combinations.push(combination27);combinations.push(combination28);
			combinations.push(combination29);combinations.push(combination30);combinations.push(combination31);combinations.push(combination32);
			
			resetAllCombinations();
			
		}
		
		public function resetAllCombinations()
		{


		    combination1.reset(); combination2.reset(); combination3.reset(); combination4.reset();
			combination5.reset(); combination6.reset(); combination7.reset(); combination8.reset();
			combination9.reset(); combination10.reset();combination11.reset();combination12.reset();
			combination13.reset();combination14.reset();combination15.reset();combination16.reset();
			combination17.reset();combination18.reset();combination19.reset();combination20.reset();
			combination21.reset();combination22.reset();combination23.reset();combination24.reset();
			combination25.reset();combination26.reset();combination27.reset();combination28.reset();
			combination29.reset();combination30.reset();combination31.reset();combination32.reset();
			trace ("Combinations reset");

			
			
		}
		
		public function setCombination(whichOne:Number, a, b, c, d:Number)
		{
		    var combo:Combination = combinations[whichOne];
			combo.displaySigns(a, b, c, d);
		    
		    
            			
		}		
		
		
	}
	
}
