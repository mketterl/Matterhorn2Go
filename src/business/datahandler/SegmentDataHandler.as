/*
The Matterhorn2Go Project
Copyright (C) 2011  University of Osnabrück; Part of the Opencast Matterhorn Project

This project is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301 
USA 
*/
package business.datahandler
{	
	import events.SegmentLoadedEvent;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.XMLListCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import spark.events.IndexChangeEvent;
	
	public class SegmentDataHandler extends EventDispatcher
	{		
		private var serviceObj:HTTPService; 
		
		private var segments:XMLListCollection;	
		
		private var mediapackage:XMLListCollection;
		
		private var description:String;
		
		private var thumbnail:String;
		
		private var segAsXML:XML;
		
		static private var instance:SegmentDataHandler;
		
		public function SegmentDataHandler()
		{
			serviceObj = new HTTPService();
		}
		
		public static function getInstance(id:String):SegmentDataHandler{
			if (instance == null) instance = new SegmentDataHandler();
			
			instance.init(id);
			
			return instance;
		}
		
		public function init(id:String):void
		{	
			serviceObj.resultFormat = 'e4x';
			serviceObj.method = 'GET';
			serviceObj.useProxy = false;
			serviceObj.addEventListener(ResultEvent.RESULT, processResult);				
			//serviceObj.addEventListener(FaultEvent.FAULT,processFault);
			//serviceObj.url ='http://gruinard.virtuos.uos.de:8080/annotation/annotations.xml?episode=1b789da3-73aa-4fe2-826e-68a7676fca5c&type=question&day=&limit=10&offset=0';
			serviceObj.url = URLClass.getInstance().getURL()+'/search/episode.xml?id='+id;
			//serviceObj.url ='http://gruinard.virtuos.uos.de:8080/annotation/annotations.xml?episode='+id+'&type=comment&day=&limit=500&offset=0';
			serviceObj.send();
		}
		
		protected function processResult(response:ResultEvent):void
		{			
			var XMLResults:XML = response.result as XML;
			
			segments = new XMLListCollection(XMLResults.result.segments.children());
			
			segAsXML = new XML(XMLResults.result);
			
			mediapackage = new XMLListCollection(XMLResults.result.mediapackage);
			
			description = new String(XMLResults.result.dcDescription);
			
			//thumbnail = new String(XMLResults.result);
			
			var xmlSegmentLoaded:SegmentLoadedEvent = new SegmentLoadedEvent(SegmentLoadedEvent.SEGMENTLOADED);
			dispatchEvent(xmlSegmentLoaded);	
		}
		
		public function getThumbnailURL():String
		{
			return thumbnail;
		}
		
		public function getSegmentListCollection():XMLListCollection
		{						
			return segments;
		}
		
		public function getMediapackageListCollection():XMLListCollection
		{						
			return mediapackage;
		}
		
		public function getSegmentAsXML():XML
		{
			return segAsXML;
		}
		
		public function getDescriptionListCollection():String
		{						
			return description;
		}
	}
}