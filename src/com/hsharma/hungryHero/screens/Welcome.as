/**
 *
 * Hungry Hero Game
 * http://www.hungryherogame.com
 * 
 * Copyright (c) 2012 Hemanth Sharma (www.hsharma.com). All rights reserved.
 * 
 * This ActionScript source code is free.
 * You can redistribute and/or modify it in accordance with the
 * terms of the accompanying Simplified BSD License Agreement.
 *  
 */

package com.hsharma.hungryHero.screens
{
	import com.hsharma.hungryHero.customObjects.Font;
	import com.hsharma.hungryHero.events.DataSendEvent;
	import com.hsharma.hungryHero.events.NavigationEvent;
	
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundMixer;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Timer;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	import util.DataSendEvent;
	
	
	/**
	 * This is the welcome or main menu class for the game.
	 *  
	 * @author hsharma
	 * 
	 */
	public class Welcome extends Sprite
	{
		/** Background image. */
		private var bg:Image;
		
		/** Game title. */
		private var title:Image;
		
		/** Play button. */
		private var playBtn:Button;
		
		/** Play button. */
		private var joinBtn:Button;
		
		/** About button. */
		private var aboutBtn:Button;
		
		/** Hero artwork. */
		private var hero:Image;

		/** About text field. */
		private var aboutText:TextField;
		
		/** hsharma.com button. */
		private var hsharmaBtn:Button;
		
		/** Starling Framework button. */
		private var starlingBtn:Button;
		
		/** Back button. */
		private var backBtn:Button;
		
		/** Screen mode - "welcome" or "about". */
		private var screenMode:String;

		/** Current date. */
		private var _currentDate:Date;
		
		/** Font - Regular text. */
		private var fontRegular:Font;
		
		/** Hero art tween object. */
		private var tween_hero:Tween;
		
		private var _p1Joined:Boolean = false;
		private var _p2Joined:Boolean = false;
		
		private var _isP1:Boolean = false;
		private var _isP2:Boolean = false;
		
		private var _connected:Boolean= false;
		
		public static const P1_JOINED:String = "p1Joined";
		public static const P2_JOINED:String = "p2Joined";
		public static const UPDATE:String = "update";
		
		private var p1JoinLabel:TextField;
		private var p2JoinLabel:TextField;
		
		private var _localNet:NetConnection;
		private var _netGroup:NetGroup;
		
		private var _waitTimer:Timer = new Timer(2000,1); 
		
		private var _waiting:Boolean = true; 
		
		public function Welcome()
		{
			super();
			this.visible = false;
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			setUpNetConnection();
		}
		
		private function setUpNetConnection():void
		{
			_localNet = new NetConnection();
			_localNet.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
			_localNet.connect("rtmfp:");
			_waitTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onTimerComplete);
			_waitTimer.start();
		}
		
		protected function onTimerComplete(event:TimerEvent):void
		{
			_waitTimer.stop();
			_waiting = false;
			_localNet.connect("rtmfp:");
		}
		
		
		protected function netStatus(event:NetStatusEvent):void
		{
			
			switch(event.info.code){
				case "NetConnection.Connect.Success":
					setupGroup();
					break;
				
				case "NetGroup.Connect.Success":
					_connected = true;
					if(_isP1 == false && _waiting == false)
					{
						p1JoinLabel.text = 'p1 joined';
						_isP1 = true;
					}
					else if(_isP1 == true)
					{
						p2JoinLabel.text = 'p2 joined';
						_isP2 = true;
					}
					break;
				
				case "NetConnection.Connect.Closed":
					_connected = false;
					break;
				
				case "NetGroup.SendTo.Notify":
					var e:DataSendEvent = event.info.message as com.hsharma.hungryHero.events.DataSendEvent;
					switch(e.event)
					{
						case UPDATE:
						{
							var info:Object = e.data;
						}	
							
					}
					break;
			}
		}
		
		private function setupGroup():void
		{
			var groupspec:GroupSpecifier = new GroupSpecifier("Contra");
			groupspec.ipMulticastMemberUpdatesEnabled = true;
			groupspec.multicastEnabled = true;
			groupspec.routingEnabled = true;
			groupspec.postingEnabled = true;
			groupspec.addIPMulticastAddress("239.254.254.1:30303");
			
			_netGroup = new NetGroup(_localNet, groupspec.groupspecWithAuthorizations());
			_netGroup.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
		}
		
		/**
		 * On added to stage. 
		 * @param event
		 * 
		 */
		private function onAddedToStage(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			drawScreen();
		}
		
		/**
		 * Draw all the screen elements. 
		 * 
		 */
		private function drawScreen():void
		{
			// GENERAL ELEMENTS
			
			bg = new Image(Assets.getTexture("BgWelcome"));
			bg.blendMode = BlendMode.NONE;
			this.addChild(bg);
			
			title = new Image(Assets.getAtlas().getTexture(("welcome_title")));
			title.x = 600;
			title.y = 65;
			this.addChild(title);
			
			// WELCOME ELEMENTS
			
			hero = new Image(Assets.getAtlas().getTexture("welcome_hero"));
			hero.x = -hero.width;
			hero.y = 130;
			this.addChild(hero);
			
			playBtn = new Button(Assets.getAtlas().getTexture("welcome_playButton"));
			playBtn.x = 640;
			playBtn.y = 340;
			playBtn.addEventListener(Event.TRIGGERED, onPlayClick);
			this.addChild(playBtn);
			
			joinBtn = new Button(Assets.getAtlas().getTexture("welcome_playButton"));
			joinBtn.x = 450;
			joinBtn.y = 340;
			joinBtn.addEventListener(Event.TRIGGERED, onJoinClick);
			this.addChild(joinBtn);
			
			aboutBtn = new Button(Assets.getAtlas().getTexture("welcome_aboutButton"));
			aboutBtn.x = 460;
			aboutBtn.y = 460;
			aboutBtn.addEventListener(Event.TRIGGERED, onAboutClick);
			this.addChild(aboutBtn);
			
			
			p1JoinLabel = new TextField(150,80,'p1 not joined');
			p2JoinLabel = new TextField(150,80,'p2 not joined');
			
			this.addChild(p1JoinLabel);
			this.addChild(p2JoinLabel);
			
			p1JoinLabel.x = 460;
			p1JoinLabel.y = 250;
			
			p2JoinLabel.x = 600;
			p2JoinLabel.y = 250;
			
			// ABOUT ELEMENTS
			fontRegular = Fonts.getFont("Regular");
			
			aboutText = new TextField(480, 600, "", fontRegular.fontName, fontRegular.fontSize, 0xffffff);
			aboutText.text = "Hungry Hero is a free and open source game built on Adobe Flash using Starling Framework.\n\nhttp://www.hungryherogame.com\n\n" +
				" The concept is very simple. The hero is pretty much always hungry and you need to feed him with food." +
				" You score when your Hero eats food.\n\nThere are different obstacles that fly in with a \"Look out!\"" +
				" caution before they appear. Avoid them at all costs. You only have 5 lives. Try to score as much as possible and also" +
				" try to travel the longest distance.";
			aboutText.x = 60;
			aboutText.y = 230;
			aboutText.hAlign = HAlign.CENTER;
			aboutText.vAlign = VAlign.TOP;
			aboutText.height = aboutText.textBounds.height + 30;
			this.addChild(aboutText);
			
			hsharmaBtn = new Button(Assets.getAtlas().getTexture("about_hsharmaLogo"));
			hsharmaBtn.x = aboutText.x;
			hsharmaBtn.y = aboutText.bounds.bottom;
			hsharmaBtn.addEventListener(Event.TRIGGERED, onHsharmaBtnClick);
			this.addChild(hsharmaBtn);
			
			starlingBtn = new Button(Assets.getAtlas().getTexture("about_starlingLogo"));
			starlingBtn.x = aboutText.bounds.right - starlingBtn.width;
			starlingBtn.y = aboutText.bounds.bottom;
			starlingBtn.addEventListener(Event.TRIGGERED, onStarlingBtnClick);
			this.addChild(starlingBtn);
			
			backBtn = new Button(Assets.getAtlas().getTexture("about_backButton"));
			backBtn.x = 660;
			backBtn.y = 350;
			backBtn.addEventListener(Event.TRIGGERED, onAboutBackClick);
			this.addChild(backBtn);
		}
		
		/**
		 * On back button click from about screen. 
		 * @param event
		 * 
		 */
		private function onAboutBackClick(event:Event):void
		{
			if (!Sounds.muted) Sounds.sndCoffee.play();
			
			initialize();
		}
		
		/**
		 * On credits click on hsharma.com image. 
		 * @param event
		 * 
		 */
		private function onHsharmaBtnClick(event:Event):void
		{
			navigateToURL(new URLRequest("http://www.hsharma.com/"), "_blank");
		}
		
		/**
		 * On credits click on Starling Framework image. 
		 * @param event
		 * 
		 */
		private function onStarlingBtnClick(event:Event):void
		{
			navigateToURL(new URLRequest("http://www.gamua.com/starling"), "_blank");
		}
		
		/**
		 * On play button click. 
		 * @param event
		 * 
		 */
		private function onPlayClick(event:Event):void
		{
			
			var e:DataSendEvent = new DataSendEvent();
			
			var info:Object = new Object(); 
			info.player = "p2";
			
			e.data = info;
			e.event = UPDATE;
			_netGroup.sendToAllNeighbors(e);
			
			this.dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, {id: "play"}, true));
			
			if (!Sounds.muted) Sounds.sndCoffee.play();
		}
		
		private function onJoinClick(event:Event):void
		{
			//this.dispatchEvent(new NavigationEvent(NavigationEvent.CHANGE_SCREEN, {id: "play_join"}, true));
			
			if (!Sounds.muted) Sounds.sndCoffee.play();
		}
		
		/**
		 * On about button click. 
		 * @param event
		 * 
		 */
		private function onAboutClick(event:Event):void
		{
			if (!Sounds.muted) Sounds.sndMushroom.play();
			showAbout();
		}
		
		/**
		 * Show about screen. 
		 * 
		 */
		public function showAbout():void
		{
			screenMode = "about";
			
			hero.visible = false;
			playBtn.visible = false;
			aboutBtn.visible = false;
			
			aboutText.visible = true;
			hsharmaBtn.visible = true;
			starlingBtn.visible = true;
			backBtn.visible = true;
		}
		
		/**
		 * Initialize welcome screen. 
		 * 
		 */
		public function initialize():void
		{
			disposeTemporarily();
			
			this.visible = true;
			
			// If not coming from about, restart playing background music.
			if (screenMode != "about")
			{
				if (!Sounds.muted) Sounds.sndBgMain.play(0, 999);
			}
			
			screenMode = "welcome";
			
			hero.visible = true;
			playBtn.visible = true;
			aboutBtn.visible = true;
			
			aboutText.visible = false;
			hsharmaBtn.visible = false;
			starlingBtn.visible = false;
			backBtn.visible = false;
			
			hero.x = -hero.width;
			hero.y = 100;
			
			tween_hero = new Tween(hero, 4, Transitions.EASE_OUT);
			tween_hero.animate("x", 80);
			Starling.juggler.add(tween_hero);
			
			this.addEventListener(Event.ENTER_FRAME, floatingAnimation);
		}
		
		/**
		 * Animate floating objects. 
		 * @param event
		 * 
		 */
		private function floatingAnimation(event:Event):void
		{
			_currentDate = new Date();
			hero.y = 130 + (Math.cos(_currentDate.getTime() * 0.002)) * 25;
			playBtn.y = 340 + (Math.cos(_currentDate.getTime() * 0.002)) * 10;
			aboutBtn.y = 460 + (Math.cos(_currentDate.getTime() * 0.002)) * 10;
			
			joinBtn.y = 340 + (Math.cos(_currentDate.getTime() * 0.002)) * 10;
		}
		
		/**
		 * Dispose objects temporarily. 
		 * 
		 */
		public function disposeTemporarily():void
		{
			this.visible = false;
			
			if (this.hasEventListener(Event.ENTER_FRAME)) this.removeEventListener(Event.ENTER_FRAME, floatingAnimation);
			
			if (screenMode != "about") SoundMixer.stopAll();
		}
	}
}