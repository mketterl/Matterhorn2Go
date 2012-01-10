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
package business.core
{
	public class ButtonSize
	{
		static private var instance:ButtonSize;
		
		private var wButton:Number = 0;
		private var hButton:Number = 0;

		public var btnGoHead:Class;
		public var btnGoOverHead:Class;
		public var btnGoDisabledHead:Class; 
		
		public var btnGoSlides:Class;
		public var btnGoOverSlides:Class;
		public var btnGoDisabledSlides:Class; 
		
		public var btnGoParallel:Class;
		public var btnGoOverParallel:Class;
		public var btnGoDisabledParallel:Class; 
		
		public var btnGoBack:Class;
		public var btnGoOverBack:Class;
		public var btnGoDisabledBack:Class; 
		
		public var btnGoPlay:Class;
		public var btnGoOverPlay:Class;
		public var btnGoDisabledPlay:Class; 
		
		public var btnGoPause:Class;
		public var btnGoOverPause:Class;
		public var btnGoDisabledPause:Class; 
		
		public var btnGoComment:Class;
		public var btnGoOverComment:Class;
		public var btnGoDisabledComment:Class; 
		
		public function ButtonSize()
		{
		}		
		
		static public function getInstance():ButtonSize
		{
			if (instance == null) instance = new ButtonSize();
			
			return instance;
		}
		
		public function setDPI(screenDPI:Number):void
		{
			var h:Number = screenDPI;
			
			if(h > 140 && h < 220)
			{
				wButton = 48;	
				hButton = 48;		
			}else if(h > 220 && h < 350)
			{
				wButton = 72;
				hButton = 72;		
			}
			else if(h >= 350)
			{
				wButton = 96;
				hButton = 96;		
			}
		}
		
		public function getH():String
		{
			return String(hButton);
		}
		
		public function getW():String
		{
			return String(wButton);
		}
	}	
}