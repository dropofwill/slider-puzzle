package code
{
	import flash.display.Sprite;
	import flash.display.Bitmap;

	public class AnswerKey extends Sprite
	{

		private var nRows,nCols,tileW,tileH:int;//Number of Rows & Columns and Width & Height of a Tile.
		public var tileArray:Array = new Array();
		private var iArray:Array = new Array();
		private var myManager:Document;

		public function AnswerKey(rows:int,cols:int,aManager:Document,answerArray:Array)
		{
			// constructor code
			myManager = aManager;
			nRows = rows;
			nCols = cols;
			tileW = answerArray[0][0].width;
			tileH = answerArray[0][0].height;
			iArray = answerArray;
			
			buildAnswerKey();
		}

		//Adds tiles in their appropriate position
		//No Input or Output
		private function buildAnswerKey():void
		{
			var cols:int = 0;
			var rows:int = 0;
			
			for (var i:int = 0; i < nRows; i++)
			{
				tileArray[i] = new Array();
				for (var c:int = 0; c < nCols; c++)
				{
					tileArray[i][c] = addTile(cols,rows,i,c);
					cols +=  tileW;
				}
				rows +=  tileH;
				cols = 0;
			}
		}
		
		//Adds a tile to the stage and pushes them to tileArray
		//Inputs: 	cols/rows is the x/y position based on the column and row it is in
		//			colsCount/rowsCount is it's location in the nested array [rowsCount][colsCount]
		protected function addTile(cols:int,rows:int,rowsCount:int,colsCount:int):BitTile
		{
			var tTile:BitTile = new BitTile(iArray,rowsCount,colsCount,this);
			tTile.reposition(cols,rows);
			addChild(tTile);
			
			return tTile;
		}
		
		//Cycles through the nested array of tiles, clearing the bitmaps they contain
		//No inputs/outputs
		public function clearTiles():void
		{
			for (var i:int = 0; i < nRows; i++)
			{
				for (var c:int = 0; c < nCols; c++)
				{
					tileArray[i][c].clearBitmap();
				}
			}
		}
	}
}