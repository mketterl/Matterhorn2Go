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
package business
{
	import flash.events.MouseEvent;
	import flash.system.Capabilities;
	
	import mx.core.FlexGlobals;
	import mx.core.FlexSprite;
	import mx.core.UIComponent;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.ParallelElement;
	import org.osmf.events.LoaderEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.net.NetLoader;
	
	//Sets the size of the SWF
	public class OSMFPlayer
	{
		import org.osmf.media.URLResource;
		import mx.collections.ArrayCollection;
		import org.osmf.layout.ScaleMode;
		import org.osmf.layout.LayoutMetadata;
		import events.VideosLoadedEvent;
		
		//URI of the media
		protected var progressive_path:String;
		protected var progressive_path_two:String;
		public var player:MediaPlayer;
		public var container_one:MediaContainer;
		public var container_two:MediaContainer;
		public var mediaFactory:DefaultMediaFactory;
		protected var parallelElement:ParallelElement;
		
		protected var height_size:Number = 0;
		
		protected var width_size:Number = 0;
		
		private var firstElement:MediaElement;
		private var oProxyElementTwo:OProxyElement;
		
		private var track:FlexSprite;
		private var progress:FlexSprite;
		
		private var progressbarContainer:FlexSprite;
		
		public function OSMFPlayer(video:String, video_two:String)
		{
			this.progressive_path = video;
			this.progressive_path_two = video_two;
			this.progressbarContainer = new FlexSprite();
			initPlayer();
		}
		
		protected function initPlayer():void
		{	
			// Create a LayoutMetaData object to even out the 2
			// parallel streams initially
			var layoutData:LayoutMetadata = new LayoutMetadata();
			layoutData.percentWidth = 100;
			layoutData.percentHeight = 100;
			layoutData.scaleMode = ScaleMode.LETTERBOX;
			
			// Create a mediafactory instance
			mediaFactory = new DefaultMediaFactory();
			
			// Create the left upper Media Element to play the presenter
			// and apply the meta-data
			firstElement = mediaFactory.createMediaElement( new URLResource( progressive_path ));

			if(progressive_path_two != "")
			{
				createParallelElement();
			}
			else
			{
				addSingleElementToContainer();
			}
		}
		
		public function createParallelElement():void
		{
			// Create the down side Media Element to play the
			// presentation and apply the meta-data		
			var secoundVideoElement:MediaElement = mediaFactory.createMediaElement( new URLResource( progressive_path_two ));
			oProxyElementTwo = new OProxyElement(secoundVideoElement);
			
			// Create the ParallelElement and add the left and right
			// elements to it
			parallelElement = new ParallelElement();
			parallelElement.addChild(oProxyElementTwo);
			parallelElement.addChild( firstElement );	
		}
		
		public function setSize(h_size:Number, w_size:Number):void
		{
			height_size = h_size;
			width_size = w_size;
			
			if(progressive_path_two != "")
			{
				addParallelElementToContainer();
			}
			else
			{	
				addSingleElementToContainer();
			}
		}
		
		public function addSingleElementToContainer():void
		{
			//the simplified api controller for media
			player = new MediaPlayer( firstElement );

			//the container for managing display and layout
			container_one = new MediaContainer();
			container_one.addMediaElement( firstElement );
						
			container_one.width = width_size;
		 	container_one.height = height_size;	
		}
		
		public function addParallelElementToContainer():void
		{	
			//the simplified api controller for media
			player = new MediaPlayer( parallelElement );

			//the container for managing display and layout
			container_one = new MediaContainer();
			container_one.addMediaElement(firstElement);
			
			container_two = new MediaContainer();
			container_two.addMediaElement(oProxyElementTwo);
			
			container_one.width = width_size;
			container_one.height = height_size;	
				
			container_two.width = width_size;
			container_two.height = height_size;	
		}
		
		public function setContainerOneSize(width_size:Number, height_size:Number):void
		{
			container_one.width = width_size;
			container_one.height = height_size;	
		}
		
		public function setContainerTwoSize(width_size:Number, height_size:Number):void
		{
			container_two.width = width_size;
			container_two.height = height_size;	
		}
		
		public function getContainerOne():UIComponent
		{
			var component:UIComponent = new UIComponent();
			component.addChild(container_one);
			
			return component;
		}
		
		public function getContainerTwo():UIComponent
		{
			var component:UIComponent = new UIComponent();
			component.addChild(container_two);	
			
			return component;
		}
	}
}