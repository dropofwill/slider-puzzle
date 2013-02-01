package code {
	
	import flash.display.MovieClip;
	import flash.text.*;
	import flash.events.*;
	
	public class BasicButton extends MovieClip {
		
		private var textFormat:TextFormat = new TextFormat();
		private var textTitle:TextField = new TextField();
		
		public function BasicButton(textInput:String,w:int = 100,align = 0) {
			// constructor code
			this.width = w;
			textFormat.font = "Euphemia";
			textFormat.size = 16;
			textFormat.align = "center";
			textTitle.width = this.width;
			textTitle.text = textInput;
			this.addChild(textTitle);
			textTitle.x += align;
			textTitle.setTextFormat(textFormat);
			textTitle.selectable = false;
		}
	}
}
