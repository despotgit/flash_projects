package  {
	
public class Try {

	const SPADES:String = "p";
	const CLUBS:String = "t";
	const HEARTS:String = "h";
	const DIAMONDS:String = "k";
	const JUMPER:String = "s";
	const STAR:String = "z";

	var signs:Array;
	var rezult:Array;
	
	public static function cloneTry(tr:Try):Try
	{
	    var t = new Try();
		
		var s:Array = tr.getSigns();
		var r:Array = tr.getRezult();
		
		t.setSigns(s[0], s[1], s[2], s[3]);
		t.setRezult(r[0],r[1]);
		
		return t;
	}
	
	public function Try() {
		// constructor code
	}
	
	public function getSigns()
	{
		return signs;	
		
	}
	
	public function setSigns(sign1, sign2, sign3, sign4:String)
	{
		this.signs = new Array(sign1, sign2, sign3, sign4);
		
	}
	
	public function getRezult()
	{
		return rezult;    	
			
	}
	
	public function setRezult(correct, misplaced:Number)
	{
		this.rezult = new Array(correct, misplaced);	
			
			
	}
	
	public function convertSignsToNumbers()
	{
	    var newSigns:Array = new Array();
		
	    for each(var s:String in signs) {
		    switch (s) {
			    case "p": newSigns.push(1);   break;
				case "t": newSigns.push(2);   break;
				case "h": newSigns.push(3);   break;
				case "k": newSigns.push(4);   break;
				case "s": newSigns.push(5);   break;
				case "z": newSigns.push(6);   break;
			}
		    
		}
		
		signs = newSigns;
	    
	}
	
	public function returnAsString()
	{
	    var ret:String = "";
	    for (var i:Number = 0; i < 4; i++)
		{
		    ret += signs[i];
		}
		
		ret += "," + rezult[0] + rezult[1];
		
		return ret;
	    
	}

}
	
}
