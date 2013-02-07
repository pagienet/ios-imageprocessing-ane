package net.psykosoft.imageprocessing
{

	import flash.display.BitmapData;
	import flash.external.ExtensionContext;

	public class ImageProcessingExtension
	{
		private var _context:ExtensionContext;

		public function ImageProcessingExtension() {
			super();

			_context = ExtensionContext.createExtensionContext( "net.psykosoft.imageprocessing", null );
			checkContext();
		}

		// -----------------------
		// Internal.
		// -----------------------

		private function checkContext():void {
			if( !_context ) {
				throw new Error( "ImageProcessingExtension ANE could not be loaded." );
			}
		}

		// -----------------------
		// Interface.
		// -----------------------

		public function init():void {
			_context.call( "init" );
		}

		public function filterBlackAndWhite( bmd:BitmapData ):void {
			_context.call( "filterBlackAndWhite", bmd );
		}
	}
}
