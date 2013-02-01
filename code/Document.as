package code
{

	import flash.display.MovieClip;
	import flash.events.*;
	import flash.text.*;
	import flash.net.*;
	import flash.ui.Mouse;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.geom.*;

	public class Document extends MovieClip
	{
		private var anAnswerKey:AnswerKey;
		private var aPuzzle:Puzzle;
		private var puzzleW:int = 650; //Puzzle width, sets how the image will be scaled
		private var nRows:int = 4;
		private var nCols:int = 4;
		private var tileW,tileH:int;//Width & Height of a Tile.
		
		private var refreshButton = new Refresh();
		private var solveButton = new Solve();
		private var browseButton = new Browse();
		private var button3x3 = new BasicButton("3x3",50,10);
		private var button4x4 = new BasicButton("4x4",50,10);
		private var button5x5 = new BasicButton("5x5",50,10);
		private var textFormat = new TextFormat();
		public var win:Boolean = false;
		private var winText:TextField = new TextField();
		
		private var urlLoader:URLLoader;
		private var loadFile:FileReference;
		private var myLoader:Loader;
		
		private var bitmapData:BitmapData;
		private var iWidth:Number;
		private var iHeight:Number;
		private var answerArray:Array = new Array();
		private var puzzleArray:Array = new Array();

		public function Document()
		{
			// constructor code
			loadUI();
			loadImage("images/pic1.jpg"); //default image, I added some other images to data try out
		}
		
		//Just used for the default picture takes a set url
		//Input: url as a string
		//No ouputs
		//Calls initImage upon completion
		private function loadImage(imageSource:String):void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, initImage);
			loader.load(new URLRequest(imageSource));
		}
		
		//Creates bitmapData for the source image
		//No inputs or outputs
		//Calls finishImage
		private function initImage(e:Event):void
		{
			bitmapData = e.target.content.bitmapData;

			finishImage();
		}
		
		//Called when the user clicks on the browse button, opens a dialog for a user selected image
		//No inputs or ouputs
		//Calls selectHandler when the user-selection occurs
		private function loadExternalImage(e:MouseEvent):void
		{
			loadFile = new FileReference();
			loadFile.addEventListener(Event.SELECT, selectHandler);
			var fileFilter:FileFilter = new FileFilter("Images: (*.jpeg, *.jpg, *.gif, *.png)","*.jpeg; *.jpg; *.gif; *.png");
			loadFile.browse([fileFilter]);
		}
		
		//Called by loadExternalImage, loads the file
		//No inputs or outputs
		//Calls loadCompleteHandler when finished
		private function selectHandler(e:Event):void
		{
			loadFile.removeEventListener(Event.SELECT, selectHandler);
			loadFile.addEventListener(Event.COMPLETE, loadCompleteHandler);
			loadFile.load();
		}

		//Called by selectHandler, passes on the data
		//No inputs or outputs
		//Calls loadBytesHandler when finished
		private function loadCompleteHandler(e:Event):void
		{
			loadFile.removeEventListener(Event.COMPLETE, loadCompleteHandler);
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadBytesHandler);
			loader.loadBytes(loadFile.data);
		}
		
		//Called by loadCompleteHandler, gets the LoaderInfo from the data
		//No inputs or outputs
		//Calls initExtImage when finished
		private function loadBytesHandler(e:Event):void
		{
			var loaderInfo:LoaderInfo = (e.target as LoaderInfo);
			loaderInfo.removeEventListener(Event.COMPLETE, loadBytesHandler);

			initExtImage(loaderInfo.content);
		}
		
		//Called by loadBytesHandler
		//Inputs LoaderInfo / no output
		//Clears the previous tiles and calls finishImage
		private function initExtImage(image):void
		{
			bitmapData = image.bitmapData;
			
			aPuzzle.clearTiles();
			anAnswerKey.clearTiles();
			
			finishImage();
		}

		
		//Called by either initExtImage or initImage, scales the bitmapData and prepares it to be sliced
		//No inputs or outputs
		//Calls sliceImage
		private function finishImage():void
		{
			var scale:Number = (puzzleW/bitmapData.width);

			var matrix:Matrix = new Matrix();
			matrix.scale(scale,scale);

			var bitmapDataS:BitmapData = new BitmapData(bitmapData.width * scale,bitmapData.height * scale,true,0x000000);
			bitmapDataS.draw(bitmapData, matrix, null, null, null, true);

			var bitmapExport:Bitmap = new Bitmap(bitmapDataS);
			sliceImage(bitmapExport,bitmapDataS);
		}
		
		//Slices the image into tiles using nested arrays to keep track
		//inputs the bitmap and its data / no outputs
		//Calls initGame
		private function sliceImage(bitmapImage:Bitmap,bitmapData:BitmapData):void
		{
			var rectangle:Rectangle;
			var bitmap:Bitmap;
			var bitmap2:Bitmap;
			var bData:BitmapData;

			iWidth = bitmapData.width;
			iHeight = bitmapData.height;
			tileW = iWidth / nCols;
			tileH = iHeight / nRows;

			for (var rowIdx:int = 0; rowIdx < nRows; rowIdx++)
			{
				answerArray[rowIdx] = new Array();
				puzzleArray[rowIdx] = new Array();
				for (var colIdx:int = 0; colIdx < nCols; colIdx++)
				{
					bData = new BitmapData(tileW,tileH,true,0x00000000);
					rectangle = new Rectangle(colIdx * tileW,rowIdx * tileH,tileW,tileH);
					bData.copyPixels(bitmapData, rectangle, new Point(0,0));

					bitmap = new Bitmap(bData);
					answerArray[rowIdx][colIdx] = bitmap;
					bitmap2 = new Bitmap(bData);
					puzzleArray[rowIdx][colIdx] = bitmap2;
				}
			}
			initGame();
		}

		//Called when the data is done loading builds the Puzzle and the AnswerKey
		//No inputs or ouputs
		private function initGame():void
		{
			//Create the Slider Puzzle
			aPuzzle = new Puzzle(nRows,nCols,this,puzzleArray);
			addChild(aPuzzle);
			aPuzzle.x = 50;
			aPuzzle.y = 50;

			//Create the Answer Key to see what the final picture looks like
			anAnswerKey = new AnswerKey(nRows,nCols,this,answerArray);
			addChild(anAnswerKey);
			anAnswerKey.x = 800;
			anAnswerKey.y = 50;
			
			randomizeAPuzzle(null);
		}

		//Adds the buttons to the stage
		//No Inputs or Outputs
		private function loadUI():void
		{
			textFormat.font = "Euphemia";
			textFormat.size = 16;
			winText.x = 265;
			winText.y = 600;
			winText.width = 300;
			winText.setTextFormat(textFormat);

			refreshButton.x = 50;
			refreshButton.y = 600;
			addChild(refreshButton);
			refreshButton.addEventListener(MouseEvent.CLICK, randomizeAPuzzle);

			solveButton.x = 165;
			solveButton.y = 600;
			addChild(solveButton);
			solveButton.addEventListener(MouseEvent.CLICK, solveAPuzzle);

			browseButton.x = puzzleW + 40;
			browseButton.y = 600;
			addChild(browseButton);
			browseButton.addEventListener(MouseEvent.CLICK, loadExternalImage);
			
			button3x3.x = 50;
			button3x3.y = 650;
			addChild(button3x3);
			button3x3.addEventListener(MouseEvent.CLICK, puzzle3x3);
			
			button4x4.x = 120;
			button4x4.y = 650;
			addChild(button4x4);
			button4x4.addEventListener(MouseEvent.CLICK, puzzle4x4);
			
			button5x5.x = 190;
			button5x5.y = 650;
			addChild(button5x5);
			button5x5.addEventListener(MouseEvent.CLICK, puzzle5x5);

		}
		
		private function puzzle3x3(e:MouseEvent):void
		{
			nRows = 3;nCols = 3;
			aPuzzle.clearTiles();
			finishImage();
		}
		
		private function puzzle4x4(e:MouseEvent):void
		{
			nRows = 4;nCols = 4;
			aPuzzle.clearTiles();
			finishImage();
		}
		
		private function puzzle5x5(e:MouseEvent):void
		{
			nRows = 5;nCols = 5;
			aPuzzle.clearTiles();
			finishImage();
		}

		//Called by the refresh button, it calls randomizePuzzle() from the aPuzzle instance
		//No Inputs or Outputs
		private function randomizeAPuzzle(e:MouseEvent):void
		{
			aPuzzle.randomizePuzzle();
			if (this.contains(winText))
			{
				aPuzzle.puzzleTileArray[nRows-1][nCols-1].alpha = 0;
				removeChild(winText);
				win = false;
			}
		}
		
		//Called by the solve button, calls solvePuzzle() from the aPuzzle instance
		//No inputs or outputs
		private function solveAPuzzle(e:MouseEvent):void
		{
			aPuzzle.solvePuzzle();
		}
		
		//Called either when the solve button is pressed or when the user moves a tile
		//Inputs the array of tiles and a boolean value keeping track of whether they actually solved it or gave up / no outputs
		//Calls searchForWin, which does all the actual checking
		public function checkForWin(tileArray:Array,actuallySolved:Boolean):void
		{
			if (searchForWin(tileArray) && aPuzzle != null)
			{
				aPuzzle.winning();
				if (actuallySolved == true)
				{
					winText.text = "You won! Good Job.";
				}
				else
				{
					winText.text = "You pushed a button! Good Job.";
				}
				winText.setTextFormat(textFormat);
				addChild(winText);
			}
		}
		
		//Goes through the nested array checking if the tile's current position matches their original position
		//Inputs the array of tiles / no ouputs
		//Outputs the boolean value win depending on the result
		private function searchForWin(tileArray:Array):Boolean
		{
			for (var i:int = 0; i < nRows; i++)
			{
				for (var c:int = 0; c < nCols; c++)
				{
					if (tileArray[i][c].answerRow != tileArray[i][c].currentRow && tileArray[i][c].answerCol != tileArray[i][c].currentCol)
					{
						win = false;
						return win;
					}
				}
			}
			win = true;
			return win;
		}
	}
}