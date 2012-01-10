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
	import business.Paging;
	
	import events.VideoAvailableEvent;
	import events.VideosLoadedEvent;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.XMLListCollection;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.utils.Base64Encoder;
	
	import spark.events.IndexChangeEvent;
	
	public class DataHandler extends EventDispatcher 
	{
		private var serviceObj:HTTPService;
		private var matterhornURL:String;
		
		private var xmlVideos:XMLListCollection;
		private var publicVideos:XMLListCollection;
		private var cDate:Object;
		
		private var total:int;
		private var limit:int;
		private var offset:int;
		private var sText:String = "";
		private var oValue:String = "0";
		
		private var checkInstance:CheckForPublicVideo;
		
		private var index:Number;
		
		private var newSearch:Boolean = false;
		
		private var lernfunk:Boolean = false;
		
		private var url:String;
		
		static private var instance:DataHandler;
		
		protected var xpathValue:Object = new XMLHandler();
		
		private var paging:Paging;
		
		public function DataHandler()
		{			
			this.serviceObj = new HTTPService();
			this.publicVideos = new XMLListCollection();
		}
				
		static public function getInstance():DataHandler 
		{
			if (instance == null) instance = new DataHandler();

			return instance;
		}
		
		// The initialisation function
		public function init():void
		{
			url = URLClass.getInstance().getURL();
			publicVideos = new XMLListCollection();
			this.matterhornURL = URLClass.getInstance().getURL()+'/search/episode.xml';
			serviceObj.resultFormat = 'e4x';
			serviceObj.method = 'GET';
			serviceObj.useProxy = false;
			serviceObj.addEventListener(ResultEvent.RESULT, processResult);
			serviceObj.url = matterhornURL+'?q='+sText+'&limit='+20+'&offset='+oValue;	
			serviceObj.send();	
		}
		
		// The result processing function
		public function processResult(response:ResultEvent):void
		{
			var XMLResults:XML = response.result as XML;
			total = XMLResults.@total;
			limit = XMLResults.@limit;
			offset = XMLResults.@offset;
			
			this.paging = Paging.getInstance();
			
			if(AdoptersDataHandler.getInstance().getFilter() == "1")
			{
				lernfunk = true;
			}
			else
			{
				lernfunk = false;
			}
			
			if(lernfunk)
			{
				xmlVideos = new XMLListCollection(XMLResults.result.mediapackage);

				index = 0;
				
				if(index < xmlVideos.length && xmlVideos.length > 0)
					setIT();
			}
			else
			{
				xmlVideos = new XMLListCollection(XMLResults.result.mediapackage);

				index = 0;

				while(index < xmlVideos.length)
				{
					createNewElement();
					
					index = index + 1;
				}

				if(paging.getPage() < paging.getMaxPages())
				{
					var mediapackage:Object = 
						"<mediapackage id='update_button'><code>update_view</code></mediapackage>";
					
					var xml:XML = new XML(mediapackage);
					
					publicVideos.addItem(xml);
				}
				
				var videoLoaded:VideosLoadedEvent = new VideosLoadedEvent(VideosLoadedEvent.VIDEOSLOADED);
				dispatchEvent(videoLoaded);
			}
		}
		
		public function setIT():void
		{
			checkInstance = CheckForPublicVideo.getInstance();
			checkInstance.checkForPublicVideo(xmlVideos.getItemAt(index).@id);
			checkInstance.addEventListener(VideoAvailableEvent.VIDEOAVAILABLE, getAvailable);
		}
		
		public function getAvailable(e:VideoAvailableEvent):void
		{			
			if(checkInstance.getVideoStatus())
			{
				if(index < xmlVideos.length && xmlVideos.length > 0)
					createNewElement();
			}
			
			index = index + 1;

			if(index < xmlVideos.length && xmlVideos.length > 0)
			{
			   	setIT();
			}
			else
			{	
				if(paging.getPage() < paging.getMaxPages())
				{
					var mediapackage:Object = 
						"<mediapackage id='update_button'><code>update_view</code></mediapackage>";
					
					var xml:XML = new XML(mediapackage);
					
					publicVideos.addItem(xml);
				}
				
				var videoLoaded:VideosLoadedEvent = new VideosLoadedEvent(VideosLoadedEvent.VIDEOSLOADED);
				dispatchEvent(videoLoaded);	
			}
		}
		
		public function createNewElement():void
		{	
			var imagePath:String = "mediapackage/attachments/attachment[@ref='attachment:attachment-2']/url";
			//trace(index)
			var mediapackage:Object = 
				"<mediapackage id='"+xmlVideos.getItemAt(index).@id+"'>" +
				"<title>"+xmlVideos.getItemAt(index).title+"</title>" +
				"<author>"+xmlVideos.getItemAt(index).creators.creator+"</author>" +
				"<thumbnail>"+xpathValue.getResult(imagePath, xmlVideos.getItemAt(index))+"</thumbnail>" +
				"</mediapackage>";
			
			var xml:XML = new XML(mediapackage);
			
			if(newSearch)
			{
				publicVideos = new XMLListCollection();
				newSearch = false;
			}
			
			publicVideos.addItem(xml);
			
			//trace(publicVideos.length)
		}
	
		// search videos
		public function search(searchText:String, offset_value:String):void
		{	
			if(sText != searchText)
			{
				newSearch = true;
			}
			
			this.sText = searchText;
			this.oValue = offset_value;
			
			var url:String = matterhornURL;
			var searchurl:String = url+'?q='+sText+'&limit='+20+'&offset='+oValue;
			
			serviceObj.url = searchurl;
			serviceObj.send();	
		}
		
		public function getXMLListCollection():XMLListCollection
		{
			return publicVideos;
		}
		
		public function setXMLListCollection(v:XMLListCollection):void
		{
			this.publicVideos = v;
		}
		
		public function getTotal():int
		{
			return total;
		}
		
		public function getLimit():int
		{
			return limit;
		}
		
		public function setLimit(l:int):void
		{
			limit = l;
		}
		
		public function getOffset():int
		{
			return offset;
		}
		
		public function setOffset(o:int):void
		{
			offset = o;
		}
		
		public function getText():String
		{
			return sText;
		}
		
		public function setText():void
		{
			sText = "";
		}
		
		public function setNewSearch():void
		{
			newSearch = true;
		}
		
		public function setOValue():void
		{
			oValue = "0";
		}
		
		public function getURL():String
		{
			return url;
		}
	}
}