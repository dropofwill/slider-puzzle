package code
{

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.display.Sprite;

	public class BitTile extends MovieClip
	{
		
		public var currentRow:int;
		public var currentCol:int;
		public var answerRow:int;
		public var answerCol:int;
		public var blankTile:Boolean = false;
		private var mgr:Object;
		private var parentArray;
		
		public function BitTile(anArray:Array,i:int,c:int,myManager:Object)
		{
			// constructor code
			parentArray = anArray;
			addChild(parentArray[i][c]);
			currentRow = i;
			currentCol = c;
			answerRow = i;
			answerCol = c;
			mgr = myManager;
			
			if (answerRow == 3 && answerCol == 3)
			{
				blankTile = true;
			}
			
			this.addEventListener(MouseEvent.MOUSE_DOWN,selectTile);
		}
		
		//Checks to see if the tile should be selectable, i.e. in the puzzle and the puzzle hasn't already been solved and the tile isn't the blank
		//No inputs or ouputs
		//Called on click
		private function selectTile(e:MouseEvent):void
		{
			if (mgr is Puzzle)
			{
				if (!mgr.getWin())
				{
					mgr.swapTile(this,false);
				}
			}
		}
		
		public function lockTile():void
		{
			this.alpha = 1;
		}
		
		//Changes the x and y
		//inputs x and y as integers / no outputs
		public function reposition(xpos:int,ypos:int):void
		{
			this.x = xpos;
			this.y = ypos;
		}
		
		//Deletes the current image to make way for a new one
		//no inputs or outputs
		public function clearBitmap():void
		{
			removeChild(parentArray[answerRow][answerCol]);
		}
	}
}