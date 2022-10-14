package 
{
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.geom.*;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.display.MovieClip;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	
	import flash.net.URLLoader;
	import flash.net.URLVariables;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.navigateToURL;
	
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.greensock.TimelineLite;
	import flash.sampler.pauseSampling;

	public class game extends MovieClip
	{		
		var puzzlePiecesArr:Array;
		var puzzlePiecesFound:Array;
		var topDepth:Number;
		var totalPuzzlePieces:Number;
		var correctPuzzlePieces:Number;
		var puzzleBmp:BitmapData;
		var intervalID:Number;
		var threshold:Number;
		var imageToAssemble:String;

		var imageLoader:Loader;
		var requestURL:URLRequest;

		var puzzleBoardClip:MovieClip;
		var holder:MovieClip;

		var row_length:Number = 4;  //number of puzzle pieces in one row and/or column

		var timer:Timer = new Timer(83);  //83 for tenths (should be 100 ms for tenths, but flash is buggy about this timing)
		var trashTimer:Timer;
		var currentTime:Number = 0;
		var wait_period:Number=2;
		
		//Timer parameters for miliseconds, seconds, etc
		var t_hrs:int = 0;
 		var t_mins:int = 0;
		var t_secs:int = 0;
		var t_tens:int = 0;
		
		//Scaling parameters
		var scale_to:Number=400;
		var scale_factor:Number = 470/scale_to;//470 was original, now it is of the width specified at scale_to		

		public function game()
		{            
			init();
			resizeMe(this,scale_to);
			
		}

		//Ideja za mesanje puzzle delova:
		//Postaviti ih sve na svoje mesto na pocetku, zadrzati ih tu 10 sekundi, i onda ih rasporediti na svoja proizvoljna mesta(pola puzzle-a je levo,
		//pola desno)na levoj i desnoj strani.
		
		function init()
		{
			timer.addEventListener(TimerEvent.TIMER, timerUpdate);			
			

			puzzleBoardClip = new MovieClip();
			addChild(puzzleBoardClip);

			totalPuzzlePieces = row_length * row_length;

			imageToAssemble = "final_celo.jpg";

			puzzlePiecesArr = new Array();
			puzzlePiecesFound = new Array();
			correctPuzzlePieces = 0;
			threshold = 0xFFFF;

			/* Create the image Loader */
			imageLoader = new Loader();
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadImg);

			/* Create the URL Request */
			requestURL = new URLRequest(imageToAssemble);

			// Load the image
			imageLoader.load(requestURL);

			// Setup a holdery mc to hold the puzzle pieces;
			holder = new MovieClip();
			addChild(holder);
		}
		
		
		function timerUpdate(e:TimerEvent):void
		{

			t_tens++;
			if (t_tens == 10)
			{
			  t_tens = 0;
			  t_secs++;
			}
			
			if (t_secs == 60)
			{
			  t_secs = 0;
			  t_mins++;
			}
			
			if (t_mins == 60)
			{
			  t_mins = 0;
			  t_hrs++;
			}
			
			updateTime();

			
		}
		
		function updateTime():void
		{
			txt_time.text = "";
			txt_time.appendText((t_hrs>9)?(t_hrs.toString()):("0"+t_hrs.toString()));
			txt_time.appendText(":");
			txt_time.appendText((t_mins>9)?(t_mins.toString()):("0"+t_mins.toString()));
			txt_time.appendText(":");
			txt_time.appendText((t_secs>9)?(t_secs.toString()):("0"+t_secs.toString()));
			txt_time.appendText(":");
			txt_time.appendText((t_tens>9)?(t_tens.toString()):(t_tens.toString()+"0"));
		}
		

		function onLoadImg(evt:Event):void
		{
			// Determine the width and height of each puzzle piece.
			var widthPuzzlePiece:Number = imageLoader.width / row_length;
			var heightPuzzlePiece:Number = imageLoader.height / row_length;

			// Draw the image from the movie clip into a BitmapData Obj.
			puzzleBmp = new BitmapData(imageLoader.width,imageLoader.height);
			puzzleBmp.draw(imageLoader, new Matrix());

			var puzzlePieceBmp:BitmapData;
			var x:Number = 0;
			var y:Number = 0;

			// Loop n*n times to make each piece
			for (var i:Number = 0; i < ( row_length * row_length ); i++)
			{
				puzzlePieceBmp = new BitmapData(widthPuzzlePiece, heightPuzzlePiece);
				puzzlePieceBmp.copyPixels(puzzleBmp, new Rectangle(x,y,widthPuzzlePiece,heightPuzzlePiece), new Point(0,0));

				makePuzzlePiece(puzzlePieceBmp, i);

				x +=  widthPuzzlePiece;
				if (x >= puzzleBmp.width)
				{
					x = 0;
					y +=  heightPuzzlePiece;
				}
			}

			makePuzzleBoard(puzzleBmp.width, puzzleBmp.height); //Draw the puzzle board (the grate lines)
            			
			resetPieces(); //Reset pieces so they form original picture
			
			holdPieces(); //Hold pieces in the position, so player can see his/her goal
			
			arrangePuzzlePieces(); //Shuffle pieces
			
			
		}



		function makePuzzlePiece(puzzlePiece:BitmapData, index:int)
		{
			var puzzlePieceClip:Bitmap = new Bitmap(puzzlePiece);
			var tmp2:MovieClip = new MovieClip();
			tmp2.addChild(puzzlePieceClip);
			tmp2.name = String(index);// Added for Strict Mode
			holder.addChild(tmp2);

			

			puzzlePiecesArr.push(tmp2);

			// This is used to check if the same piece has been placed;
			puzzlePiecesFound.push(tmp2.name);

		}

		function pieceMove(evt:Event):void
		{
			if (evt.type == "mouseDown")
			{
				if(evt.target.draggable!=-1)
				{
				  evt.target.startDrag();
				  trace(evt.target.name);
				}
			}
			else if (evt.type == "mouseUp")
			{
				evt.target.stopDrag();
				trace(evt.target.name);
				var puzzlePieceIndex:Number = evt.target.name;

				// ADDED VV 4.3. Check if droppped inside of the grid
				if (evt.target.dropTarget)
				{
					var puzzleBoardSpaceIndex:Number = evt.target.dropTarget.board_space_index;
					trace("evt.target.dropTarget: " + evt.target.dropTarget);
					trace("evt.target.dropTarget.name: " + evt.target.dropTarget.name);
					
					trace("evt.target.dropTarget.parent: " + evt.target.dropTarget.parent);
					trace("evt.target.dropTarget.parent.name: " + evt.target.dropTarget.parent.name);
				}

				if (puzzlePieceIndex == puzzleBoardSpaceIndex)
				{   
				    //Add this line for testing
				    //puzzleSolved(); 
					
					var coordinate:Point = new Point(evt.target.dropTarget.x,evt.target.dropTarget.y);
					var coordinateGlobal:Point = new Point();

					coordinateGlobal = puzzleBoardClip.localToGlobal(coordinate);

					evt.target.x = coordinateGlobal.x * scale_factor;  //multiplied by ratio due to the whole game being resized 
					evt.target.y = coordinateGlobal.y * scale_factor;  //multiplied by ratio due to the whole game being resized

					if (puzzlePiecesFound.length != 0)
					{
						for (var i:int = 0; i < puzzlePiecesFound.length; i++)
						{
							if (puzzlePiecesFound[i] == puzzlePieceIndex)
							{
								puzzlePiecesFound[i] = "Correct";
								correctPuzzlePieces++;
							}
						}
					}

					if (correctPuzzlePieces == totalPuzzlePieces)
					{
						puzzleSolved();
					}
					
					//Set that the piece is no longer draggable if it is let off at the right position
					evt.target.draggable=-1;
					
					
				}
			}
		}


        //Function returns the pieces in the original position forming the original image
        function resetPieces():void
		{
			var index:Number = 0;
			
		    if(row_length==10)
			{
              for(var i:Number = 1; i < row_length+1; i++)
			  for(var j:Number = 1; j < row_length+1; j++)
			  {
			    puzzlePiecesArr[index].x = scale_factor * (339+ j*69.75);			
			    puzzlePiecesArr[index].y = scale_factor * (-45 + i*69.75);
			    trace ("index: " + index + " (x,y): " + puzzlePiecesArr[index].x + " " + puzzlePiecesArr[index].y);
			
			    index++;
			  } 
		    }
			
		    if(row_length==4)
			{
			  for(var i:Number = 1; i < row_length+1; i++)
			  for(var j:Number = 1; j < row_length+1; j++)
			  {
			    puzzlePiecesArr[index].x = scale_factor * (339+ j*69.75) * 10 / row_length - 721;			
			    puzzlePiecesArr[index].y = scale_factor * (-45 + i*69.75) * 10 / row_length - 43;
				
				//puzzlePiecesArr[index].x = scale_factor*(339+(j*69.75*10/row_length));			
			    //puzzlePiecesArr[index].y = scale_factor*(-45+(i*69.75*10/row_length));
				
	            trace ("index: " + index + " (x,y): " + puzzlePiecesArr[index].x + " " + puzzlePiecesArr[index].y);
			
			    index++;
			  }
			}
			


			
		}
		
		//Function holds the pieces for "wait_period" seconds in the position where they form the original image
		function holdPieces():void
		{
			var index:Number = 0;
			var rl:Number = row_length;
			

			while (index < rl*rl)
			{
								
				puzzlePiecesArr[index].timeline = new TimelineLite();
				
				puzzlePiecesArr[index].timeline.append(new TweenLite(puzzlePiecesArr[index], 
												    wait_period,																			
												    {x:puzzlePiecesArr[index].x, 
		   						                     y:puzzlePiecesArr[index].y, 													 
		                                     		 ease:Quad.easeOut
													 
													}													 
													));				
				index++;
			}		
		}

        //Function shuffles the pieces
		function arrangePuzzlePieces():void
		{	
			
			var timeline:TimelineLite;  
			timeline = new TimelineLite();
			
			
			var widthPuzzlePiece:Number = puzzlePiecesArr[0].width;
			var heightPuzzlePiece:Number = puzzlePiecesArr[0].height;

			var locationArr:Array = new Array();
			
			//Generate left-side spaces
			for(var i:Number=0; i<(row_length/2); i++)
			for(var j:Number=0; j<row_length; j++)
			{
				locationArr.push({x: 30 + i*85/row_length*10 , y:31 + j*85/row_length*10});				  
			}		
			
			//Generate right-side spaces
			//Added /row_length*10 for puzzles of dimensions other than 10x10
			for(i=0; i<(row_length/2); i++)
			for(j=0; j<row_length; j++)
			{
				locationArr.push({x:1340 + i*85/row_length*10 , y:31 + j*85/row_length*10});
			}			
			

			var index:Number = 0;
			var coordinates:Object;

			while (locationArr.length > 0)
			{
				coordinates = locationArr.splice(Math.floor(Math.random() * locationArr.length),1)[0];
				
				puzzlePiecesArr[index].timeline.append(new TweenLite(puzzlePiecesArr[index], 
												    7,																			
												    {x:coordinates.x, 
		   						                     y:coordinates.y, 													 
		                                     		 ease:Quad.easeOut,
													 onComplete: starttimer
													}													 
													));				
				
				index++;
			}
			
		}
		
		//Function starts the AS3.0 timer
		function starttimer():void
		{
			if(timer.running) //Prevent timer from starting multiple times
			{
				
		    }
			else 
			{
				timer.start();
				holder.addEventListener("mouseDown", pieceMove);
			    holder.addEventListener("mouseUp", pieceMove);
			}
			
		}

        //Function draws the puzzle board (grate lines)
		function makePuzzleBoard(width:Number, height:Number):void
		{
			var widthPuzzlePiece:Number = width / row_length;
			var heightPuzzlePiece:Number = height / row_length;

			var puzzleBoardSpaceClip:MovieClip;
			var x:Number = 0;
			var y:Number = 0;

			for (var i:Number = 0; i < (row_length*row_length); i++)
			{
				puzzleBoardSpaceClip = new MovieClip();
				puzzleBoardSpaceClip.graphics.lineStyle(0);
				puzzleBoardSpaceClip.graphics.beginFill(0x0000FF);
				puzzleBoardSpaceClip.graphics.lineTo(widthPuzzlePiece,0);
				puzzleBoardSpaceClip.graphics.lineTo(widthPuzzlePiece,heightPuzzlePiece);
				puzzleBoardSpaceClip.graphics.lineTo(0,heightPuzzlePiece);
				puzzleBoardSpaceClip.graphics.lineTo(0,0);
				puzzleBoardSpaceClip.graphics.endFill();
				puzzleBoardSpaceClip.x = x;
				puzzleBoardSpaceClip.y = y;
				x +=  widthPuzzlePiece;
				if (x >= width)
				{
					x = 0;
					y +=  heightPuzzlePiece;
				}
				puzzleBoardSpaceClip.name = "board_space_index_" + String(i);// Added for Strict Mode
				puzzleBoardSpaceClip.board_space_index = String(i);// Added for Strict Mode
				puzzleBoardClip.addChild(puzzleBoardSpaceClip);
			}

			puzzleBoardClip.x = 480;
			puzzleBoardClip.y = 440 - puzzleBoardClip.height / 2;
		}

		function puzzleSolved():void
		{
			timer.stop();
			holder.visible = false;
			var tmp:Bitmap = new Bitmap(puzzleBmp);
			puzzleBoardClip.addChild(tmp);

			trashTimer = new Timer(50);
			trashTimer.start();
			trashTimer.addEventListener("timer", puzTrash);
		}

		function puzTrash(evt:Event):void
		{
			if (threshold > 0xFFFFFF)
			{
				threshold = 0xFFFFFF;
				evt.target.stop();
				trace ("done");
				sendScore({tens:t_tens ,  secs:t_secs  ,  mins:t_mins  ,  hors:t_hrs});
				//init(); rewind
			}
			puzzleBmp.threshold(puzzleBmp, new Rectangle(0,0, puzzleBmp.width, puzzleBmp.height), new Point(0,0), "<=", 0xFF000000 | threshold);
			threshold *=  1.2;
			
		}
		
		function sendScore(score:Object)
		{
			//var scriptRequest:URLRequest = new URLRequest("http://localhost/000webhost/puzzle/puzzleOver.php");
			var scriptRequest:URLRequest = new URLRequest("puzzleOver.php");
 			var scriptLoader:URLLoader = new URLLoader();
			var scriptVars:URLVariables = new URLVariables(); 
			
			scriptVars.hors = score.hors; 
			scriptVars.mins = score.mins; 
			scriptVars.secs = score.secs; 
			scriptVars.tens = score.tens; 
			
			scriptRequest.method = URLRequestMethod.POST;
			scriptRequest.data = scriptVars; 
			navigateToURL(scriptRequest, '_self');		
			
		}
		
		function resizeMe(mc:MovieClip, maxW:Number, maxH:Number=0, constrainProportions:Boolean=true):void
		{
		  trace ("w i h su: " + mc.width + " i " + mc.height);	
          maxH = maxH == 0 ? maxW : maxH;
    	  mc.width = maxW;
          mc.height = maxH;
          if (constrainProportions) 
		  {
            mc.scaleX < mc.scaleY ? mc.scaleY = mc.scaleX : mc.scaleX = mc.scaleY;
          }
		}





	}

}