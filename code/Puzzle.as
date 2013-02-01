package code
{
	import flash.display.Sprite;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	import flash.display.Bitmap;

	public class Puzzle extends Sprite
	{
		private var nRows,nCols,tileW,tileH,aR,aC:int;//Number of Rows & Columns and Width & Height of a Tile.
		public var puzzleTileArray:Array = new Array();
		private var iArray:Array = new Array();
		private var myManager:Document;
		private var selectedCoordsArray:Array;
		
		public function Puzzle(rows:int,cols:int,aManager:Document,answerArray:Array)
		{
			// constructor code
			myManager = aManager;
			nRows = rows;
			nCols = cols;
			aR = nRows-1;
			aC = nCols-1;
			tileW = answerArray[0][0].width;
			tileH = answerArray[0][0].height;
			iArray = answerArray;
			
			buildPuzzle();
		}
		
		//Adds tiles in their appropriate position
		//No Input or Output
		private function buildPuzzle():void
		{
			var cols:int = 0;
			var rows:int = 0;
			
			for (var i:int = 0; i < nRows; i++)
			{
				puzzleTileArray[i] = new Array();
				for (var c:int = 0; c < nCols; c++)
				{
					puzzleTileArray[i][c] = addTile(cols,rows,i,c);					
					cols +=  tileW;
				}
				rows +=  tileH;
				cols = 0;
			}
			
			swapExistence(puzzleTileArray[aR][aC]);
			randomizePuzzle();
		}
		
		//Swaps tiles randomly 20 times which will result in a solvable puzzle since it was done an even number of times
		//No inputs/outputs
		public function randomizePuzzle():void
		{			
			for (var i:int = 0; i < 20; i++)
			{
				randomSwapTile();
			}
		}
		
		//Takes the integers randomSwapInt gives it and uses them to tell swapTile which tile to swap with the blank
		//No inputs/outputs
		private function randomSwapTile():void
		{
			var tempArray = randomSwapInt();
			
			swapTile(puzzleTileArray[tempArray[0]][tempArray[1]],true,tempArray);
		}
		
		//Determines two tiles to swap, as long as this is called an even number of times it will be solvable
		//Outputs and array of two ints / no inputs
		private function randomSwapInt():Array
		{
			var temp:int = aR;
			var temp2:int = aC;
			
			while (temp ==  aR && temp2 == aC)
			{
				temp = Math.floor(Math.random() * nRows);
				temp2 = Math.floor(Math.random() * nCols);
			}
			return [temp,temp2]
		}
		
		//Cycles through the tile array and moves everything back into place
		//No inputs/outputs
		//Checks for win afterwards
		public function solvePuzzle():void
		{
			var cols:int = 0;
			var rows:int = 0;
			
			for (var i:int = 0; i < nRows; i++)
			{
				for (var c:int = 0; c < nCols; c++)
				{
					puzzleTileArray[i][c].reposition(tileW*c,tileH*i);
					puzzleTileArray[i][c].currentCol = puzzleTileArray[i][c].answerCol;
					puzzleTileArray[i][c].currentRow = puzzleTileArray[i][c].answerRow;
					cols += tileW;
				}
				rows += tileH;
				cols = 0;
			}
			
			myManager.checkForWin(puzzleTileArray,false);
		}
		
		//Checks to see if a move is legal, if its the randomizer it is always legal, otherwise it has to be just one away in either the x or y
		//Input: a tile that is selected, if the randomizer is calling this, and the rows and cols number as an array
		public function swapTile(aTile:BitTile,randomizer:Boolean,arrayValues:Array = null):void
		{			
			var tarCol = puzzleTileArray[aR][aC].currentCol;
			var tarRow = puzzleTileArray[aR][aC].currentRow;
			
			var curCol = aTile.currentCol;
			var curRow = aTile.currentRow;
			
			if (randomizer == true)
			{
				swapSwapTile(curCol,curRow,tarCol,tarRow,aTile,tileW,tileH,0,0);
			}
			//curTile is moving rightward
			else if (tarCol-curCol == 1 && tarRow-curRow == 0)
			{
				swapSwapTile(curCol,curRow,tarCol,tarRow,aTile,tileW,tileH,1,0);
				myManager.checkForWin(puzzleTileArray,true);
			}
			//curTile is moving down
			else if (tarCol-curCol == 0 && tarRow-curRow == 1)
			{
				swapSwapTile(curCol,curRow,tarCol,tarRow,aTile,tileW,tileH,0,1);
				myManager.checkForWin(puzzleTileArray,true);
			}
			//curTile is moving leftward
			else if (tarCol-curCol == -1 && tarRow-curRow == 0)
			{
				swapSwapTile(curCol,curRow,tarCol,tarRow,aTile,tileW,tileH,-1,0);
				myManager.checkForWin(puzzleTileArray,true);
			}
			//curTile is moving up
			else if (tarCol-curCol == 0 && tarRow-curRow == -1)
			{
				swapSwapTile(curCol,curRow,tarCol,tarRow,aTile,tileW,tileH,0,-1);
				myManager.checkForWin(puzzleTileArray,true);
			}
		}
		
		//The function that actually moves the tile, if the randomizer does it without tweening, otherwise tweens.
		//Inputs a lot of stuff / Outputs none
		private function swapSwapTile(curCol,curRow,tarCol,tarRow,aTile,tileW,tileH,difX,difY):void
		{
			if (difX == 0 && difY == 0)
			{
				aTile.reposition(tileW*tarCol,tileH*tarRow);
				puzzleTileArray[aR][aC].reposition(tileW*curCol,tileH*curRow);
			}
			else 
			{
				var tempTweenx:Tween = new Tween(aTile,'x',Regular.easeInOut,tileW*curCol,(tileW*curCol)+(difX*tileW),.5,true);
				var tempTween2x:Tween = new Tween(puzzleTileArray[aR][aC],'x',Regular.easeInOut,tileW*tarCol,(tileW*tarCol)-(difX*tileW),.5,true);
				var tempTweeny:Tween = new Tween(aTile,'y',Regular.easeInOut,tileH*curRow,(tileH*curRow)+(difY*tileH),.5,true);
				var tempTween2y:Tween = new Tween(puzzleTileArray[aR][aC],'y',Regular.easeInOut,tileH*tarRow,(tileH*tarRow)-(difY*tileH),.5,true);
			}
			
			puzzleTileArray[aR][aC].currentCol = curCol;
			puzzleTileArray[aR][aC].currentRow = curRow;
				
			aTile.currentCol = tarCol;
			aTile.currentRow = tarRow;
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
		
		//Checks to see if user has won yet based on the public variable win
		//Outputs win / no inputs
		public function getWin():Boolean
		{
			return myManager.win;
		}
		
		//Called after the puzzle is solved, making all the tiles fully visible
		//No inputs/outputs
		public function winning():void
		{
			for (var i:int = 0; i < nRows; i++)
			{
				for (var c:int = 0; c < nCols; c++)
				{
					puzzleTileArray[i][c].lockTile();
				}
			}
		}
		
		//Cycles through the nested array of tiles, clearing the bitmaps they contain
		//No inputs/outputs
		public function clearTiles():void
		{
			for (var i:int = 0; i < nRows; i++)
			{
				for (var c:int = 0; c < nCols; c++)
				{
					puzzleTileArray[i][c].clearBitmap();
				}
			}
		}
		
		//Swaps whether the blank tile is visible
		//Inputs a tile to be made visible/invisible | no outputs
		private function swapExistence(aTile):void
		{
			if (aTile.alpha > 0)
			{
				aTile.alpha = 0;
			}
			else
			{
				aTile.alpha = 1;
			}
		}
	}

}