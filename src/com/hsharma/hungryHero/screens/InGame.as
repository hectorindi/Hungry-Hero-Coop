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
	import com.hsharma.hungryHero.events.NavigationEvent;
	import com.hsharma.hungryHero.gameElements.GameBackground;
	import com.hsharma.hungryHero.gameElements.Hero;
	import com.hsharma.hungryHero.gameElements.Item;
	import com.hsharma.hungryHero.gameElements.Obstacle;
	import com.hsharma.hungryHero.gameElements.Particle;
	import com.hsharma.hungryHero.objectPools.PoolItem;
	import com.hsharma.hungryHero.objectPools.PoolObstacle;
	import com.hsharma.hungryHero.objectPools.PoolParticle;
	import com.hsharma.hungryHero.ui.GameOverContainer;
	import com.hsharma.hungryHero.ui.HUD;
	import com.hsharma.hungryHero.ui.PauseButton;
	
	import flash.geom.Rectangle;
	import flash.media.SoundMixer;
	import flash.utils.getTimer;
	
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.extensions.PDParticleSystem;
	import starling.textures.Texture;
	import starling.utils.deg2rad;
	import starling.utils.rad2deg;
	
	/**
	 * This class contains the complete code of the game mechanics.
	 *  
	 * @author hsharma
	 * 
	 */
	public class InGame extends Sprite
	{
		/** Game background object. */
		private var bg:GameBackground;
		
		/** Hero character. */		
		private var heroP1:Hero;
		private var heroP2:Hero;
		
		/** Time calculation for animation. */
		private var timePreviousP1:Number;
		private var timeCurrentP1:Number;
		private var elapsedP1:Number;
		
		private var timePreviousP2:Number;
		private var timeCurrentP2:Number;
		private var elapsedP2:Number;
		
		// ------------------------------------------------------------------------------------------------------------
		// GAME INTERACTION 
		// ------------------------------------------------------------------------------------------------------------
		
		/** Hero's current X position. */
		private var heroXP1:int;
		private var heroXP2:int;
		
		/** Hero's current Y position. */
		private var heroYP1:int;
		private var heroYP2:int;
		
		/** Game interaction area. */		
		private var gameArea:Rectangle;
		
		/** Is game rendering through hardware or software? */
		private var isHardwareRendering:Boolean;
		
		/** Is game currently in paused state? */
		private var gamePaused:Boolean = false;
		
		/** Items pool with a maximum cap for reuse of items. */		
		private var itemsPool:PoolItem;
		
		/** Obstacles pool with a maximum cap for reuse of items. */		
		private var obstaclesPool:PoolObstacle;
		
		/** Eat Particles pool with a maximum cap for reuse of items. */		
		private var eatParticlesPool:PoolParticle;
		
		/** Wind Particles pool with a maximum cap for reuse of items. */		
		private var windParticlesPool:PoolParticle;
		
		/** Player state. */		
		private var gameState:int;
		
		/** Player's fly speed. */
		private var playerSpeed:Number;
		
		/** Player's total height travelled. */
		private var scoreDistanceP1:Number = 0;
		private var scoreDistanceP:Number = 0;
		
		/** How much to shake the camera when the player hits the obstacle? */
		private var cameraShake:Number;
		
		/** Total items collected. */
		private var scoreItemsP1:int = 0;
		private var scoreItemsP2:int = 0;
		
		/** Obstacle count - to track the frequency of obstacles. */
		private var obstacleGapCount:Number = 0;
		
		/** The power of obstacle after it is hit. */
		private var hitObstacleP1:Number = 0;
		private var hitObstacleP2:Number = 0;
		
		/** Lives Count. */		
		private var livesP1:int;
		private var livesP2:int;
		
		/** How long have we had a coffee item. */
		private var coffee:Number = 0;
		
		/** How long have we had a mushroom item. */
		private var mushroom:Number = 0;
		
		/** Collision detection for hero vs items. */
		private var heroItem_xDistP1:Number;
		private var heroItem_yDistP1:Number;
		private var heroItem_sqDistP1:Number;
		
		private var heroItem_xDistP2:Number;
		private var heroItem_yDistP2:Number;
		private var heroItem_sqDistP2:Number;
		
		/** Collision detection for hero vs obstacles. */
		private var heroObstacle_xDistP1:Number;
		private var heroObstacle_yDistP1:Number;
		private var heroObstacle_sqDistP1:Number;
		
		private var heroObstacle_xDistP2:Number;
		private var heroObstacle_yDistP2:Number;
		private var heroObstacle_sqDistP2:Number;
		
		// ------------------------------------------------------------------------------------------------------------
		// ITEM GENERATION
		// ------------------------------------------------------------------------------------------------------------
		
		/** Current pattern of food items - 0 = horizontal, 1 = vertical, 2 = zigzag, 3 = random, 4 = special item. */
		private var pattern:int;
		
		/** Current y position of the item in the pattern. */
		private var patternPosY:int;
		
		/** How far away are the patterns created vertically. */
		private var patternStep:int;
		
		/** Direction of the pattern creation - used only for zigzag. */
		private var patternDirection:int;
		
		/** Gap between each item in the pattern horizontally. */
		private var patternGap:Number;
		
		/** Pattern gap counter. */
		private var patternGapCount:Number;
		
		/** How far should the player fly before the pattern changes. */
		private var patternChange:Number;
		
		/** How long are patterns created verticaly? */
		private var patternLength:Number;
		
		/** A trigger used if we want to run a one-time command in a pattern. */
		private var patternOnce:Boolean;
		
		/** Y position for the entire pattern - Used for vertical pattern only. */
		private var patternPosYstart:Number;
		
		// ------------------------------------------------------------------------------------------------------------
		// ANIMATION
		// ------------------------------------------------------------------------------------------------------------
		
		/** Items to animate. */
		private var itemsToAnimate:Vector.<Item>;
		
		/** Total number of items. */
		private var itemsToAnimateLength:uint = 0;
		
		/** Obstacles to animate. */
		private var obstaclesToAnimate:Vector.<Obstacle>;
		
		/** Obstacles to animate - array length. */		
		private var obstaclesToAnimateLength:uint = 0;
		
		/** Wind particles to animate. */
		private var windParticlesToAnimate:Vector.<Particle>;
		
		/** Wind particles to animate - array length. */		
		private var windParticlesToAnimateLength:uint = 0;
		
		/** Eat particles to animate. */
		private var eatParticlesToAnimate:Vector.<Particle>;
		
		/** Eat particles to animate - array length. */		
		private var eatParticlesToAnimateLength:uint = 0;
		
		// ------------------------------------------------------------------------------------------------------------
		// TOUCH INTERACTION
		// ------------------------------------------------------------------------------------------------------------
		
		/** Touch X position of the mouse/finger. */		
		private var touchXP1:Number;
		private var touchXP2:Number;
		
		/** Touch Y position of the mouse/finger. */
		private var touchYP1:Number;
		private var touchYP2:Number;
		
		/** To keep track of Touch interaction. */
		private var touch:Touch;
		
		// ------------------------------------------------------------------------------------------------------------
		// PARTICLES
		// ------------------------------------------------------------------------------------------------------------
		
		/** Particles for Coffee. */
		public static var particleCoffee:PDParticleSystem;
		
		/** Particles for Mushroom. */
		public static var particleMushroom:PDParticleSystem;
		
		// ------------------------------------------------------------------------------------------------------------
		// HUD
		// ------------------------------------------------------------------------------------------------------------
		
		/** HUD Container. */		
		private var hudP1:HUD;
		
		private var hudP2:HUD;
		
		// ------------------------------------------------------------------------------------------------------------
		// INTERFACE OBJECTS
		// ------------------------------------------------------------------------------------------------------------
		
		/** GameOver Container. */
		private var gameOverContainer:GameOverContainer;
		
		/** Pause button. */
		private var pauseButton:PauseButton;
		
		/** Kick Off button in the beginning of the game .*/
		private var startButton:Button;
		
		/** Tween object for game over container. */
		private var tween_gameOverContainer:Tween;
		
		/* for the co-op **/
		private var _isPlayer2:Boolean = true;
		
		// ------------------------------------------------------------------------------------------------------------
		// METHODS
		// ------------------------------------------------------------------------------------------------------------

		public function InGame()
		{
			super();
			
			// Is hardware rendering?
			isHardwareRendering = Starling.context.driverInfo.toLowerCase().indexOf("software") == -1;
			
			this.visible = false;
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		/**
		 * On added to stage.  
		 * @param event
		 * 
		 */
		private function onAddedToStage(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			drawGame();
			drawHUD();
			drawGameOverScreen();
		}
		
		/**
		 * Draw game elements - background, hero, particles, pause button, start button and items (in pool). 
		 * 
		 */
		private function drawGame():void
		{
			// Draw background.
			bg = new GameBackground();
			this.addChild(bg);
			
			// Is hardware rendering, draw particles.
			if (isHardwareRendering)
			{
				particleCoffee = new PDParticleSystem(XML(new ParticleAssets.ParticleCoffeeXML()), Texture.fromBitmap(new ParticleAssets.ParticleTexture()));
				Starling.juggler.add(particleCoffee);
				
				particleMushroom = new PDParticleSystem(XML(new ParticleAssets.ParticleMushroomXML()), Texture.fromBitmap(new ParticleAssets.ParticleTexture()));
				Starling.juggler.add(particleMushroom);
				
				this.addChild(particleCoffee);
				this.addChild(particleMushroom);
			}
			
			// Draw hero.
			heroP1 = new Hero();
			this.addChild(heroP1);
			heroP2 = new Hero();
			this.addChild(heroP2);
			
			// Pause button.
			pauseButton = new PauseButton();
			pauseButton.x = pauseButton.width * 2;
			pauseButton.y = pauseButton.height * 0.5;
			pauseButton.addEventListener(Event.TRIGGERED, onPauseButtonClick);
			this.addChild(pauseButton);
			
			// Start button.
			startButton = new Button(Assets.getAtlas().getTexture("startButton"));
			startButton.fontColor = 0xffffff;
			startButton.x = stage.stageWidth/2 - startButton.width/2;
			startButton.y = stage.stageHeight/2 - startButton.height/2;
			startButton.addEventListener(Event.TRIGGERED, onStartButtonClick);
			this.addChild(startButton);
			
			// Initialize items-to-animate vector.
			itemsToAnimate = new Vector.<Item>();
			itemsToAnimateLength = 0;
			
			// Create items, add them to pool and place them outside the stage area.
			//createFoodItemsPool();
			
			// Initialize obstacles-to-animate vector.
			obstaclesToAnimate = new Vector.<Obstacle>();
			obstaclesToAnimateLength = 0;
			
			// Create obstacles pool.
			createObstaclesPool();
			
			// Initialize particles-to-animate vectors.
			eatParticlesToAnimate = new Vector.<Particle>();
			eatParticlesToAnimateLength = 0;
			windParticlesToAnimate = new Vector.<Particle>();
			windParticlesToAnimateLength = 0;
			
			// Create Eat Particle and Wind Particle pools and place them outside the stage area.
			createEatParticlePool();
			createWindParticlePool();
			
			// Create items, add them to pool and place them outside the stage area.
			createFoodItemsPool();
		}
		
		/**
		 * On click of pause button. 
		 * @param event
		 * 
		 */
		private function onPauseButtonClick(event:Event):void
		{
			event.stopImmediatePropagation();
			
			// Pause or unpause the game.
			if (gamePaused) gamePaused = false;
			else gamePaused = true;
			
			// Pause the background animation too.
			bg.gamePaused = gamePaused;
		}
		
		/**
		 * Draw Heads Up Display. 
		 * 
		 */
		private function drawHUD():void
		{
			hudP1 = new HUD();
			hudP2 = new HUD();
			this.addChild(hudP1);
			this.addChild(hudP2);
			hudP2.y = hudP1.y + 50;
			
		}
		
		/**
		 * Draw game over screen. 
		 * 
		 */
		private function drawGameOverScreen():void
		{
			gameOverContainer = new GameOverContainer();
			gameOverContainer.addEventListener(NavigationEvent.CHANGE_SCREEN, playAgain);
			this.addChild(gameOverContainer);
		}
		
		/**
		 * Play again, when clicked on play again button in Game Over screen. 
		 * 
		 */
		private function playAgain(event:NavigationEvent):void
		{
			if (event.params.id == "playAgain") 
			{
				tween_gameOverContainer = new Tween(gameOverContainer, 1);
				tween_gameOverContainer.fadeTo(0);
				tween_gameOverContainer.onComplete = gameOverFadedOut;
				Starling.juggler.add(tween_gameOverContainer);
			}
		}
		
		/**
		 * Create food items pool by passing the create and clean methods/functions to the Pool.  
		 * 
		 */
		private function createFoodItemsPool():void
		{
			itemsPool = new PoolItem(foodItemCreate, foodItemClean);
		}
		
		/**
		 * Create food item objects and add to display list.
		 * Also called from the Pool class while creating minimum number of objects & run-time objects < maximum number.
		 * @return Food item that was created.
		 * 
		 */
		private function foodItemCreate():Item
		{
			var foodItem:Item = new Item(Math.ceil(Math.random() * 5));
			//foodItem.x = stage.stageWidth + foodItem.width * 6;
			foodItem.x = 2000;
			//foodItem.y = 200;
			this.addChild(foodItem);
			
			return foodItem;
		}
		
		/**
		 * Clean the food items before reusing from the pool. Called from the pool. 
		 * @param item
		 * 
		 */
		private function foodItemClean(item:Item):void
		{
			item.x = stage.stageWidth + 100;
		}
		
		/**
		 * Create obstacles pool by passing the create and clean methods/functions to the Pool.  
		 * 
		 */
		private function createObstaclesPool():void
		{
			obstaclesPool = new PoolObstacle(obstacleCreate, obstacleClean, 4, 10);
		}
		
		/**
		 * Create obstacle objects and add to display list.
		 * Also called from the Pool class while creating minimum number of objects & run-time objects < maximum number.
		 * @return Obstacle that was created.
		 * 
		 */
		private function obstacleCreate():Obstacle
		{
			var obstacle:Obstacle = new Obstacle(Math.ceil(Math.random() * 4), Math.random() * 1000 + 1000);
			obstacle.x = stage.stageWidth + obstacle.width * 2;
			this.addChild(obstacle);
			
			return obstacle;
		}
		
		/**
		 * Clean the obstacles before reusing from the pool. Called from the pool. 
		 * @param obstacle
		 * 
		 */
		private function obstacleClean(obstacle:Obstacle):void
		{
			obstacle.x = stage.stageWidth + obstacle.width * 2;
		}
		
		/**
		 * Create Eat Particle Pool. 
		 * 
		 */
		private function createEatParticlePool():void
		{
			eatParticlesPool = new PoolParticle(eatParticleCreate, eatParticleClean, 20, 30);
		}
		
		/**
		 * Create eat particl objects and add to display list.
		 * Also called from the Pool class while creating minimum number of objects & run-time objects < maximum number.
		 * @return Eat particle that was created.
		 * 
		 */
		private function eatParticleCreate():Particle
		{
			var eatParticle:Particle = new Particle(GameConstants.PARTICLE_TYPE_1);
			eatParticle.x = stage.stageWidth + eatParticle.width * 2;
			this.addChild(eatParticle);
			
			return eatParticle;
		}
		
		/**
		 * Clean the eat particles before reusing from the pool. Called from the pool. 
		 * @param eatParticle
		 * 
		 */
		private function eatParticleClean(eatParticle:Particle):void
		{
			eatParticle.x = stage.stageWidth + eatParticle.width * 2;
		}
		
		/**
		 * Create Wind Particle Pool. 
		 * 
		 */
		private function createWindParticlePool():void
		{
			windParticlesPool = new PoolParticle(windParticleCreate, windParticleClean, 10, 30);
		}
		
		/**
		 * Create eat particl objects and add to display list.
		 * Also called from the Pool class while creating minimum number of objects & run-time objects < maximum number.
		 * @return Eat particle that was created.
		 * 
		 */
		private function windParticleCreate():Particle
		{
			var windParticle:Particle = new Particle(GameConstants.PARTICLE_TYPE_2);
			windParticle.x = stage.stageWidth + windParticle.width * 2;
			this.addChild(windParticle);
			
			return windParticle;
		}
		
		/**
		 * Clean the eat particles before reusing from the pool. Called from the pool. 
		 * @param windParticle
		 * 
		 */
		private function windParticleClean(windParticle:Particle):void
		{
			windParticle.x = stage.stageWidth + windParticle.width * 2;
		}
		
		/**
		 * Initialize the game. 
		 * 
		 */
		public function initialize():void
		{
			// Dispose screen temporarily.
			disposeTemporarily();
			
			this.visible = true;
			
			// Calculate elapsed time.
			this.addEventListener(Event.ENTER_FRAME, calculateElapsed);
			
			// Play screen background music.
			if (!Sounds.muted) Sounds.sndBgGame.play(0, 999);
			
			// Define game area.
			gameArea = new Rectangle(0, 100, stage.stageWidth, stage.stageHeight - 250);
			
			// Define lives.
			livesP1 = GameConstants.HERO_LIVES;
			livesP2 = GameConstants.HERO_LIVES;
			
			// Reset hit, camera shake and player speed.
			hitObstacleP1 = 0;
			cameraShake = 0;
			playerSpeed = 0;
			
			// Reset score and distance travelled.
			scoreItemsP1 = 0;
			scoreDistanceP1 = 0;
			
			// Reset item pattern styling.
			pattern = 1;
			patternPosY = gameArea.top;
			patternStep = 15;
			patternDirection = 1;
			patternGap = 20;
			patternGapCount = 0;
			patternChange = 100;
			patternLength = 50;
			patternOnce = true;
			
			// Reset coffee and mushroom power.
			coffee = 0;
			mushroom = 0;
			
			// Reset game state to idle.
			gameState = GameConstants.GAME_STATE_IDLE;
			
			// Hero's initial position
			heroP1.x = -stage.stageWidth;
			heroP1.y = stage.stageHeight/2;
			
			// Reset hero's state to idle.
			heroP1.state = GameConstants.HERO_STATE_IDLE;
			
			heroP2.x = -stage.stageWidth;
			heroP2.y = stage.stageHeight/2;
			
			// Reset hero's state to idle.
			heroP2.state = GameConstants.HERO_STATE_IDLE;
			
			
			// Reset touch interaction values to hero's position.
			touchXP1 = heroP1.x;
			touchYP1 = heroP1.y;
			
			touchXP2 = heroP2.x;
			touchYP2 = heroP2.y;
			
			// Reset hud values and text fields.
			hudP1.foodScore = 0;
			hudP1.distance = 0;
			hudP1.lives = livesP1;
			
			// Reset background's state to idle.
			bg.state = GameConstants.GAME_STATE_IDLE;
			
			// Reset game paused states.
			gamePaused = false;
			bg.gamePaused = false;
			
			// Reset background's state to idle.
			bg.state = GameConstants.GAME_STATE_IDLE;
			
			// Reset background speed.
			bg.speed = 0;
			
			// Hide the pause button since the game isn't started yet.
			pauseButton.visible = false;
			
			// Show start button.
			startButton.visible = true;
		}
		
		/**
		 * Dispose screen temporarily. 
		 * 
		 */
		private function disposeTemporarily():void
		{
			SoundMixer.stopAll();
			
			gameOverContainer.visible = false;
			
			if (this.hasEventListener(Event.ENTER_FRAME)) this.removeEventListener(Event.ENTER_FRAME, calculateElapsed);
			
			if (this.hasEventListener(TouchEvent.TOUCH)) this.removeEventListener(TouchEvent.TOUCH, onTouch);
			
			if (this.hasEventListener(Event.ENTER_FRAME)) this.removeEventListener(Event.ENTER_FRAME, onGameTick);
		}
		
		/**
		 * On start button click. 
		 * @param event
		 * 
		 */
		private function onStartButtonClick(event:Event):void
		{
			// Play coffee sound for button click.
			if (!Sounds.muted) Sounds.sndCoffee.play();
			
			// Hide start button.
			startButton.visible = false;
			
			// Show pause button since the game is started.
			pauseButton.visible = true;
			
			// Launch hero.
			launchHero();
		}
		
		/**
		 * Launch hero. 
		 * 
		 */
		private function launchHero():void
		{
			playerSpeed = 0;
			
			// Touch interaction
			this.addEventListener(TouchEvent.TOUCH, onTouch);
			
			// Game tick
			this.addEventListener(Event.ENTER_FRAME, onGameTick);
		}
		
		/**
		 * On interaction with game - mouse move (web) or touch drag (devices). 
		 * @param event
		 * 
		 */
		private function onTouch(event:TouchEvent):void
		{
			touch = event.getTouch(stage);
			
			if(touch)
			{
				touchXP1 = touch.globalX;
				touchYP1 = touch.globalY;
				
				touchXP2 = touch.globalX + 5;
				touchYP2 = touch.globalY + 115;
			}
		}
		
		/**
		 * Game Tick - every frame of the game.
		 * @param event
		 * 
		 */
		private function onGameTick(event:Event):void
		{
			// If not paused, tick the game.
			if (!gamePaused)
			{
				// If no touch co-ordinates, reset touchX and touchY (for touch screen devices).
				if (isNaN(touchXP1))
				{
					touchXP1 = stage.stageWidth * 0.5;
					touchYP1 = stage.stageHeight * 0.5;
				}
				
				// If hardware rendering, set the particle emitter's x and y.
				if (isHardwareRendering)
				{
					particleCoffee.emitterX = heroP1.x + heroP1.width * 0.5 * 0.5;
					particleCoffee.emitterY = heroP1.y;
					
					particleMushroom.emitterX = heroP1.x + heroP1.width * 0.5 * 0.5;
					particleMushroom.emitterY = heroP1.y;
				}
				
				switch(gameState)
				{
					// Before game starts.
					case  GameConstants.GAME_STATE_IDLE:
						// Take off.
						if (heroP1.x < stage.stageWidth * 0.5 * 0.5)
						{
							heroP1.x += ((stage.stageWidth * 0.5 * 0.5 + 10) - heroP1.x) * 0.05;
							heroP1.y -= (heroP1.y - touchYP1) * 0.1;
							
							playerSpeed += (GameConstants.HERO_MIN_SPEED - playerSpeed) * 0.05;
							bg.speed = playerSpeed * elapsedP1;
						}
						else
						{
							gameState = GameConstants.GAME_STATE_FLYING;
							heroP1.state = GameConstants.HERO_STATE_FLYING;
						}
						
						// add hero 2
						if(_isPlayer2)
						{
							if (heroP2.x < stage.stageWidth * 0.5 * 0.5)
							{
								heroP2.x += ((stage.stageWidth * 0.5 * 0.5 + 25) - heroP2.x) * 0.05;
								heroP2.y -= (heroP2.y - touchYP2) * 0.1;
								
								//playerSpeed += (GameConstants.HERO_MIN_SPEED - playerSpeed) * 0.05;
								//bg.speed = playerSpeedP2 * elapsedP2;
							}
							else
							{
								gameState = GameConstants.GAME_STATE_FLYING;
								heroP2.state = GameConstants.HERO_STATE_FLYING;
							}
						}
						
						// Rotate hero based on mouse position.
						if ((-(heroP1.y - touchYP1) * 0.2) < 30 && (-(heroP1.y - touchYP1) * 0.2) > -30) heroP1.rotation = deg2rad(-(heroP1.y - touchYP1) * 0.2);
						
						if(_isPlayer2)
						{
							if ((-(heroP2.y - touchYP2) * 0.2) < 30 && (-(heroP2.y - touchYP2) * 0.2) > -30) heroP2.rotation = deg2rad(-(heroP2.y - touchYP2) * 0.2);
						}
						
						// Limit the hero's rotation to < 30.
						if (rad2deg(heroP1.rotation) > 30 ) heroP1.rotation = rad2deg(30);
						if (rad2deg(heroP1.rotation) < -30 ) heroP1.rotation = -rad2deg(30);
						
						if(_isPlayer2)
						{
							if (rad2deg(heroP2.rotation) > 30 ) heroP2.rotation = rad2deg(30);
							if (rad2deg(heroP2.rotation) < -30 ) heroP2.rotation = -rad2deg(30);
						}
						
						// Confine the hero to stage area limit
						if (heroP1.y > gameArea.bottom - heroP1.height * 0.5)    
						{
							heroP1.y = gameArea.bottom - heroP1.height * 0.5;
							heroP1.rotation = deg2rad(0);
						}
						if (heroP1.y < gameArea.top + heroP1.height * 0.5)    
						{
							heroP1.y = gameArea.top + heroP1.height * 0.5;
							heroP1.rotation = deg2rad(0);
						}
						
						if(_isPlayer2)
						{
							if (heroP2.y > gameArea.bottom - heroP2.height * 0.5)    
							{
								heroP2.y = gameArea.bottom - heroP2.height * 0.5;
								heroP2.rotation = deg2rad(0);
							}
							if (heroP2.y < gameArea.top + heroP2.height * 0.5)    
							{
								heroP2.y = gameArea.top + heroP2.height * 0.5;
								heroP2.rotation = deg2rad(0);
							}
						}
						break;
					
					// When game is in progress.
					case GameConstants.GAME_STATE_FLYING:
						
						// If drank coffee, fly faster for a while.
						if (coffee > 0)
						{
							playerSpeed += (GameConstants.HERO_MAX_SPEED - playerSpeed) * 0.2;
						}
						
						// If not hit by obstacle, fly normally.
						if (hitObstacleP1 <= 0)
						{
							heroP1.y -= (heroP1.y - touchYP1) * 0.1;
							heroP1.x -= (heroP1.x - touchXP1) * 0.1;
							
							// If hero is flying extremely fast, create a wind effect and show force field around hero.
							if (playerSpeed > GameConstants.HERO_MIN_SPEED + 100)
							{
								createWindForce();
								// Animate hero faster.
								heroP1.setHeroAnimationSpeed(1);
							}
							else
							{
								// Animate hero normally.
								heroP1.setHeroAnimationSpeed(0);
							}
							
							// Rotate hero based on mouse position.
							if ((-(heroP1.y - touchYP1) * 0.2) < 30 && (-(heroP1.y - touchYP1) * 0.2) > -30) heroP1.rotation = deg2rad(-(heroP1.y - touchYP1) * 0.2);
							
							// Limit the hero's rotation to < 30.
							if (rad2deg(heroP1.rotation) > 30 ) heroP1.rotation = rad2deg(30);
							if (rad2deg(heroP1.rotation) < -30 ) heroP1.rotation = -rad2deg(30);
							
							// Confine the hero to stage area limit
							if (heroP1.y > gameArea.bottom - heroP1.height * 0.5)    
							{
								heroP1.y = gameArea.bottom - heroP1.height * 0.5;
								heroP1.rotation = deg2rad(0);
							}
							if (heroP1.y < gameArea.top + heroP1.height * 0.5)    
							{
								heroP1.y = gameArea.top + heroP1.height * 0.5;
								heroP1.rotation = deg2rad(0);
							}
						}
						else
						{
							// Hit by obstacle
							if (coffee <= 0)
							{
								// Play hero animation for obstacle hit.
								if (heroP1.state != GameConstants.HERO_STATE_HIT)
								{
									heroP1.state = GameConstants.HERO_STATE_HIT;
								}
								
								// Move hero to center of the screen.
								heroP1.y -= (heroP1.y - (gameArea.top + gameArea.height)/2) * 0.1;
								
								// Spin the hero.
								if (heroP1.y > stage.stageHeight * 0.5) heroP1.rotation -= deg2rad(hitObstacleP1 * 2);
								else heroP1.rotation += deg2rad(hitObstacleP1 * 2);
							}
							
							// If hit by an obstacle.
							hitObstacleP1--;
							
							// Camera shake.
							cameraShake = hitObstacleP1;
							shakeAnimation(null);
						}
						
						if (hitObstacleP2 <= 0)
						{
							heroP2.y -= (heroP2.y - touchYP2) * 0.1;
							heroP2.x -= (heroP2.x - touchXP2) * 0.1;
							// If hero is flying extremely fast, create a wind effect and show force field around hero.
							if (playerSpeed > GameConstants.HERO_MIN_SPEED + 100)
							{
								createWindForce();
								// Animate hero faster.
								heroP2.setHeroAnimationSpeed(1);
							}
							else
							{
								// Animate hero normally.
								heroP2.setHeroAnimationSpeed(0);
							}
							
							// Rotate hero based on mouse position.
							if ((-(heroP2.y - touchYP2) * 0.2) < 30 && (-(heroP2.y - touchYP2) * 0.2) > -30) heroP2.rotation = deg2rad(-(heroP2.y - touchYP2) * 0.2);
							
							// Limit the hero's rotation to < 30.
							if (rad2deg(heroP2.rotation) > 30 ) heroP2.rotation = rad2deg(30);
							if (rad2deg(heroP2.rotation) < -30 ) heroP2.rotation = -rad2deg(30);
							
							// Confine the hero to stage area limit
							if (heroP2.y > gameArea.bottom - heroP2.height * 0.5)    
							{
								heroP2.y = gameArea.bottom - heroP2.height * 0.5;
								heroP2.rotation = deg2rad(0);
							}
							if (heroP2.y < gameArea.top + heroP2.height * 0.5)    
							{
								heroP2.y = gameArea.top + heroP2.height * 0.5;
								heroP2.rotation = deg2rad(0);
							}
						}
						else
						{
							// Hit by obstacle
							
							if (coffee <= 0)
							{
								// Play hero animation for obstacle hit.
								if (heroP2.state != GameConstants.HERO_STATE_HIT)
								{
									heroP2.state = GameConstants.HERO_STATE_HIT;
								}
								
								// Move hero to center of the screen.
								heroP2.y -= (heroP2.y - (gameArea.top + gameArea.height)/2) * 0.1;
								
								// Spin the hero.
								if (heroP2.y > stage.stageHeight * 0.5) heroP2.rotation -= deg2rad(hitObstacleP1 * 2);
								else heroP2.rotation += deg2rad(hitObstacleP2 * 2);
							}
							
							// If hit by an obstacle.
							hitObstacleP2--;
							
							// Camera shake.
							cameraShake = hitObstacleP2;
							shakeAnimation(null);
						}
						
						// If we have a mushroom, reduce the value of the power.
						if (mushroom > 0) mushroom -= elapsedP1;
						
						// If we have a coffee, reduce the value of the power.
						if (coffee > 0) coffee -= elapsedP1;
						
						// If we have a mushroom, reduce the value of the power.
						if (mushroom > 0) mushroom -= elapsedP2;
						
						// If we have a coffee, reduce the value of the power.
						if (coffee > 0) coffee -= elapsedP2;
						
						playerSpeed -= (playerSpeed - GameConstants.HERO_MIN_SPEED) * 0.01;
						
						playerSpeed -= (playerSpeed - GameConstants.HERO_MIN_SPEED) * 0.01;
						
						// Create food items.
						setFoodItemsPattern();
						createFoodItemsPattern();
						
						// Create obstacles.
						initObstacle();
						
						// Store the hero's current x and y positions (needed for animations below).
						heroXP1 = heroP1.x;
						heroYP1 = heroP1.y;
						
						heroXP2 = heroP2.x;
						heroYP2 = heroP2.y;
						
						// Animate elements.
						animateFoodItems();
						animateObstacles();
						animateEatParticles();
						animateWindParticles();
						
						// Set the background's speed based on hero's speed.
						bg.speed = playerSpeed * elapsedP1;
						
						// Calculate maximum distance travelled.
						scoreDistanceP1 += (playerSpeed * elapsedP1) * 0.1;
						hudP1.distance = Math.round(scoreDistanceP1);
						
						break;
					
					// Game over.
					case GameConstants.GAME_STATE_OVER:
						
						for(var i:uint = 0; i < itemsToAnimateLength; i++)
						{
							if (itemsToAnimate[i] != null)
							{
								// Dispose the item temporarily.
								disposeItemTemporarily(i, itemsToAnimate[i]);
							}
						}
						
						for(var j:uint = 0; j < obstaclesToAnimateLength; j++)
						{
							if (obstaclesToAnimate[j] != null)
							{
								// Dispose the obstacle temporarily.
								disposeObstacleTemporarily(j, obstaclesToAnimate[j]);
							}
						}
						
						for(var m:uint = 0; m < eatParticlesToAnimateLength; m++)
						{
							if (eatParticlesToAnimate[m] != null)
							{
								// Dispose the eat particle temporarily.
								disposeEatParticleTemporarily(m, eatParticlesToAnimate[m]);
							}
						}
						
						for(var n:uint = 0; n < windParticlesToAnimateLength; n++)
						{
							if (windParticlesToAnimate[n] != null)
							{
								// Dispose the wind particle temporarily.
								disposeWindParticleTemporarily(n, windParticlesToAnimate[n]);
							}
						}
						
						// Spin the hero.
						heroP1.rotation -= deg2rad(30);
						
						// Make the hero fall.
						
						// If hero is still on screen, push him down and outside the screen. Also decrease his speed.
						// Checked for +width below because width is > height. Just a safe value.
						if (heroP1.y < stage.stageHeight + heroP1.width)
						{
							playerSpeed -= playerSpeed * elapsedP1;
							heroP1.y += stage.stageHeight * elapsedP1; 
						}
						else
						{
							// Once he moves out, reset speed to 0.
							playerSpeed = 0;
							
							// Stop game tick.
							this.removeEventListener(Event.ENTER_FRAME, onGameTick);
							
							// Game over.
							gameOver();
						}
						
						// Set the background's speed based on hero's speed.
						bg.speed = Math.floor(playerSpeed * elapsedP1);
						
						break;
				}
			}
		}
		
		/**
		 * Create wind force particle. 
		 * 
		 */
		private function createWindForce():void
		{
			// Create a wind particle.
			var windToTrack:Particle = windParticlesPool.checkOut();
			
			// Place the object randomly along hte screen.
			windToTrack.x = stage.stageWidth;
			windToTrack.y = Math.random() * stage.stageHeight;
			
			// Set the scale of the wind object randomly.
			windToTrack.scaleX = windToTrack.scaleY = Math.random() * 0.5 + 0.5;
			
			// Animate the wind particle.
			windParticlesToAnimate[windParticlesToAnimateLength++] = windToTrack;
		}
		
		/**
		 * Set food items pattern.  
		 * 
		 */
		private function setFoodItemsPattern():void
		{
			// If hero has not travelled the required distance, don't change the pattern.
			if (patternChange > 0)
			{
				patternChange -= playerSpeed * elapsedP1;
			}
			else
			{
				// If hero has travelled the required distance, change the pattern.
				if ( Math.random() < 0.7 )
				{
					// If random number is < normal item chance (0.7), decide on a random pattern for items.
					pattern = Math.ceil(Math.random() * 4); 
				}
				else
				{
					// If random number is > normal item chance (0.3), decide on a random special item.
					//pattern = Math.ceil(Math.random() * 2) + 9;
				}
				
				if (pattern == 1)  
				{
					// Vertical Pattern
					patternStep = 15;
					patternChange = Math.random() * 500 + 500;
				}
				else if (pattern == 2)
				{
					// Horizontal Pattern
					patternOnce = true;
					patternStep = 40;
					patternChange = patternGap * Math.random() * 3 + 5;
				}
				else if (pattern == 3)
				{
					// ZigZag Pattern
					patternStep = Math.round(Math.random() * 2 + 2) * 10;
					if ( Math.random() > 0.5 )
					{
						patternDirection *= -1;
					}
					patternChange = Math.random() * 800 + 800;
				}
				else if (pattern == 4)
				{
					// Random Pattern
					patternStep = Math.round(Math.random() * 3 + 2) * 50;
					patternChange = Math.random() * 400 + 400;
				}
				else  
				{
					patternChange = 0;
				}
			}
		}
		
		/**
		 * Create food pattern after hero travels for some distance.
		 * 
		 */
		private function createFoodItemsPattern():void
		{
			// Create a food item after we pass some distance (patternGap).
			if (patternGapCount < patternGap )
			{
				patternGapCount += playerSpeed * elapsedP1;
			}
			else if (pattern != 0)
			{
				// If there is a pattern already set.
				patternGapCount = 0;
				
				// Reuse and configure food item.
				reuseAndConfigureFoodItem();
			}
		}
		
		/**
		 * Create a food item - called by createPattern() 
		 * 
		 */
		private function reuseAndConfigureFoodItem():void
		{
			var itemToTrack:Item;
			
			switch (pattern)
			{
				case 1:
					// Horizonatl, creates a single food item, and changes the position of the pattern randomly.
					if (Math.random() > 0.9)
					{
						// Set a new random position for the item, making sure it's not too close to the edges of the screen.
						patternPosY = Math.floor(Math.random() * (gameArea.bottom - gameArea.top + 1)) + gameArea.top;
					}
					
					// Checkout item from pool and set the type of item.
					itemToTrack = itemsPool.checkOut();
					itemToTrack.foodItemType = Math.ceil(Math.random() * 5);
					
					// Reset position of item.
					itemToTrack.x = stage.stageWidth + itemToTrack.width;
					itemToTrack.y = patternPosY;
					
					// Mark the item for animation.
					itemsToAnimate[itemsToAnimateLength++] = itemToTrack;
					break;
				
				case 2:
					// Vertical, creates a line of food items that could be the height of the entire screen or just a small part of it.
					if (patternOnce == true)
					{
						patternOnce = false;
						
						// Set a random position not further than half the screen.
						patternPosY = Math.floor(Math.random() * (gameArea.bottom - gameArea.top + 1)) + gameArea.top;
						
						// Set a random length not shorter than 0.4 of the screen, and not longer than 0.8 of the screen.
						patternLength = (Math.random() * 0.4 + 0.4) * stage.stageHeight;
					}
					
					// Set the start position of the food items pattern.
					patternPosYstart = patternPosY; 
					
					// Create a line based on the height of patternLength, but not exceeding the height of the screen.
					while (patternPosYstart + patternStep < patternPosY + patternLength && patternPosYstart + patternStep < stage.stageHeight * 0.8)
					{
						// Checkout item from pool and set the type of item.
						itemToTrack = itemsPool.checkOut();
						itemToTrack.foodItemType = Math.ceil(Math.random() * 5);
						
						// Reset position of item.
						itemToTrack.x = stage.stageWidth + itemToTrack.width;
						itemToTrack.y = patternPosYstart;
						
						// Mark the item for animation.
						itemsToAnimate[itemsToAnimateLength++] = itemToTrack;
						
						// Increase the position of the next item based on patternStep.
						patternPosYstart += patternStep;
					}
					break;
				
				case 3:
					// ZigZag, creates a single item at a position, and then moves bottom
					// until it hits the edge of the screen, then changes its direction and creates items
					// until it hits the upper edge.
					
					// Switch the direction of the food items pattern if we hit the edge.
					if (patternDirection == 1 && patternPosY > gameArea.bottom - 50)
					{
						patternDirection = -1;
					}
					else if ( patternDirection == -1 && patternPosY < gameArea.top )
					{
						patternDirection = 1;
					}
					
					if (patternPosY >= gameArea.top && patternPosY <= gameArea.bottom)
					{
						// Checkout item from pool and set the type of item.
						itemToTrack = itemsPool.checkOut();
						itemToTrack.foodItemType = Math.ceil(Math.random() * 5);
						
						// Reset position of item.
						itemToTrack.x = stage.stageWidth + itemToTrack.width;
						itemToTrack.y = patternPosY;
						
						// Mark the item for animation.
						itemsToAnimate[itemsToAnimateLength++] = itemToTrack;
						
						// Increase the position of the next item based on patternStep and patternDirection.
						patternPosY += patternStep * patternDirection;
					}
					else
					{
						patternPosY = gameArea.top;
					}
					
					break;
				
				case 4:
					// Random, creates a random number of items along the screen.
					if (Math.random() > 0.3)
					{
						// Choose a random starting position along the screen.
						patternPosY = Math.floor(Math.random() * (gameArea.bottom - gameArea.top + 1)) + gameArea.top;
						
						// Place some items on the screen, but don't go past the screen edge
						while (patternPosY + patternStep < gameArea.bottom)
						{
							// Checkout item from pool and set the type of item.
							itemToTrack = itemsPool.checkOut();
							itemToTrack.foodItemType = Math.ceil(Math.random() * 5);
							
							// Reset position of item.
							itemToTrack.x = stage.stageWidth + itemToTrack.width;
							itemToTrack.y = patternPosY;
							
							// Mark the item for animation.
							itemsToAnimate[itemsToAnimateLength++] = itemToTrack;
							
							// Increase the position of the next item by a random value.
							patternPosY += Math.round(Math.random() * 100 + 100);
						}
					}
					break;
				
				case 10:
					// Coffee, this item gives you extra speed for a while, and lets you break through obstacles.
					
					// Set a new random position for the item, making sure it's not too close to the edges of the screen.
					patternPosY = Math.floor(Math.random() * (gameArea.bottom - gameArea.top + 1)) + gameArea.top;
					
					// Checkout item from pool and set the type of item.
					itemToTrack = itemsPool.checkOut();
					itemToTrack.foodItemType = Math.ceil(Math.random() * 2) + 5;
					
					// Reset position of item.
					itemToTrack.x = stage.stageWidth + itemToTrack.width;
					itemToTrack.y = patternPosY;
					
					// Mark the item for animation.
					itemsToAnimate[itemsToAnimateLength++] = itemToTrack;
					break;
				
				case 11:
					// Mushroom, this item makes all the food items fly towards the hero for a while.
					
					// Set a new random position for the food item, making sure it's not too close to the edges of the screen.
					patternPosY = Math.floor(Math.random() * (gameArea.bottom - gameArea.top + 1)) + gameArea.top;
					
					// Checkout item from pool and set the type of item.
					itemToTrack = itemsPool.checkOut();
					itemToTrack.foodItemType = Math.ceil(Math.random() * 2) + 5;
					
					// Reset position of item.
					itemToTrack.x = stage.stageWidth + itemToTrack.width;
					itemToTrack.y = patternPosY;
					
					// Mark the item for animation.
					itemsToAnimate[itemsToAnimateLength++] = itemToTrack;
					
					break;
			}
		}
		
		/**
		 * Move all the food items that are in itemsToAnimate vector. 
		 * 
		 */
		private function animateFoodItems():void
		{
			var itemToTrack:Item;
			
			for(var i:uint = 0;i<itemsToAnimateLength;i++)
			{
				itemToTrack = itemsToAnimate[i];
				
				if (itemToTrack != null)
				{
					// If hero has eaten a mushroom, make all the items move towards him.
					if (mushroom > 0 && itemToTrack.foodItemType <= GameConstants.ITEM_TYPE_5)
					{
						// Move the item towards the player.
						itemToTrack.x -= (itemToTrack.x - heroXP1) * 0.2;
						itemToTrack.y -= (itemToTrack.y - heroYP1) * 0.2;
						
					}
					else
					{
						// If hero hasn't eaten a mushroom,
						// Move the items normally towards the left.
						itemToTrack.x -= playerSpeed * elapsedP1; 
					}
					
					// If the item passes outside the screen on the left, remove it (check-in).
					
					if (itemToTrack.x < -80 || gameState == GameConstants.GAME_STATE_OVER)
					{
						disposeItemTemporarily(i, itemToTrack);
					}
					else
					{
						// Collision detection - Check if the hero eats a food item.
						heroItem_xDistP1 = itemToTrack.x - heroXP1;
						heroItem_yDistP1 = itemToTrack.y - heroYP1;
						heroItem_sqDistP1 = heroItem_xDistP1 * heroItem_xDistP1 + heroItem_yDistP1 * heroItem_yDistP1;
						
						heroItem_xDistP2 = itemToTrack.x - heroXP2;
						heroItem_yDistP2 = itemToTrack.y - heroYP2;
						heroItem_sqDistP2 = heroItem_xDistP2 * heroItem_xDistP2 + heroItem_yDistP2 * heroItem_yDistP2;
						
						
						if (heroItem_sqDistP1 < 5000)
						{
							// If hero eats an item, add up the score.
							if (itemToTrack.foodItemType <= GameConstants.ITEM_TYPE_5)
							{
								scoreItemsP1 += itemToTrack.foodItemType;
								hudP1.foodScore = scoreItemsP1;
								if (!Sounds.muted) Sounds.sndEat.play();
							}
							else if (itemToTrack.foodItemType == GameConstants.ITEM_TYPE_COFFEE) 
							{
								// If hero drinks coffee, add up the score.
								scoreItemsP1 += 1;
								
								// How long does coffee power last? (in seconds)
								coffee = 5;
								if (isHardwareRendering) particleCoffee.start(coffee);
								
								if (!Sounds.muted) Sounds.sndCoffee.play();
							}
							else if (itemToTrack.foodItemType == GameConstants.ITEM_TYPE_MUSHROOM) 
							{
								// If hero eats a mushroom, add up the score.
								scoreItemsP1 += 1;
								
								// How long does mushroom power last? (in seconds)
								mushroom = 4;
								if (isHardwareRendering) particleMushroom.start(mushroom);
								
								if (!Sounds.muted) Sounds.sndMushroom.play();
							}
							
							// Create an eat particle at the position of the food item that was eaten.
							createEatParticle(itemToTrack);
							
							// Dispose the food item.
							disposeItemTemporarily(i, itemToTrack);
						}
						
						if (heroItem_sqDistP2 < 5000)
						{
							// If hero eats an item, add up the score.
							if (itemToTrack.foodItemType <= GameConstants.ITEM_TYPE_5)
							{
								scoreItemsP2 += itemToTrack.foodItemType;
								hudP2.foodScore = scoreItemsP2;
								if (!Sounds.muted) Sounds.sndEat.play();
							}
							else if (itemToTrack.foodItemType == GameConstants.ITEM_TYPE_COFFEE) 
							{
								// If hero drinks coffee, add up the score.
								scoreItemsP2 += 1;
								
								// How long does coffee power last? (in seconds)
								coffee = 5;
								if (isHardwareRendering) particleCoffee.start(coffee);
								
								if (!Sounds.muted) Sounds.sndCoffee.play();
							}
							else if (itemToTrack.foodItemType == GameConstants.ITEM_TYPE_MUSHROOM) 
							{
								// If hero eats a mushroom, add up the score.
								scoreItemsP2 += 1;
								
								// How long does mushroom power last? (in seconds)
								mushroom = 4;
								if (isHardwareRendering) particleMushroom.start(mushroom);
								
								if (!Sounds.muted) Sounds.sndMushroom.play();
							}
							
							// Create an eat particle at the position of the food item that was eaten.
							createEatParticle(itemToTrack);
							
							// Dispose the food item.
							disposeItemTemporarily(i, itemToTrack);
						}
					}
				}
			}
		}
		
		/**
		 * Dispose the item temporarily. Check-in the item into pool (will get cleaned) and reduce the "number of items" by 1. 
		 * @param animateId
		 * @param item
		 * 
		 */
		private function disposeItemTemporarily(animateId:uint, item:Item):void
		{
			itemsToAnimate.splice(animateId, 1);
			itemsToAnimateLength--;
			
			item.x = stage.stageWidth + item.width * 2;
			
			itemsPool.checkIn(item);
		}
		
		/**
		 * Dispose the obstacle temporarily. Check-in into pool (will get cleaned) and reduce the vector length by 1. 
		 * @param animateId
		 * @param obstacle
		 * 
		 */
		private function disposeObstacleTemporarily(animateId:uint, obstacle:Obstacle):void
		{
			obstaclesToAnimate.splice(animateId, 1);
			obstaclesToAnimateLength--;
			obstaclesPool.checkIn(obstacle);
		}
		
		/**
		 * Dispose the eat particle temporarily. Check-in into pool (will get cleaned) and reduce the vector length by 1. 
		 * @param animateId
		 * @param particle
		 * 
		 */
		private function disposeEatParticleTemporarily(animateId:uint, particle:Particle):void
		{
			eatParticlesToAnimate.splice(animateId, 1);
			eatParticlesToAnimateLength--;
			eatParticlesPool.checkIn(particle);
		}
		
		/**
		 * Dispose the wind particle temporarily. Check-in into pool (will get cleaned) and reduce the vector length by 1. 
		 * @param animateId
		 * @param particle
		 * 
		 */
		private function disposeWindParticleTemporarily(animateId:uint, particle:Particle):void
		{
			windParticlesToAnimate.splice(animateId, 1);
			windParticlesToAnimateLength--;
			windParticlesPool.checkIn(particle);
		}
		
		/**
		 * Create an obstacle after hero has travelled a certain distance.
		 * 
		 */
		private function initObstacle():void
		{
			// Create an obstacle after hero travels some distance (obstacleGap).
			if (obstacleGapCount < GameConstants.OBSTACLE_GAP)
			{
				obstacleGapCount += playerSpeed * elapsedP1;
			}
			else if (obstacleGapCount != 0)
			{
				obstacleGapCount = 0;
				
				// Create any one of the obstacles.
				createObstacle(Math.ceil(Math.random() * 4), Math.random() * 1000 + 1000);
			}
		}
		
		/**
		 * Create the obstacle object based on the type indicated and make it appear based on the distance passed. 
		 * @param _type
		 * @param _distance
		 * 
		 */
		private function createObstacle(_type:int = 1, _distance:Number = 0):void
		{
			// Create a new obstacle.
			var obstacle:Obstacle = obstaclesPool.checkOut();
			obstacle.type = _type;
			obstacle.distance = _distance;
			obstacle.x = stage.stageWidth;
			
			// For only one of the obstacles, make it appear in either the top or bottom of the screen.
			if (_type <= GameConstants.OBSTACLE_TYPE_3)
			{
				// Place it on the top of the screen.
				if (Math.random() > 0.5)
				{
					obstacle.y = gameArea.top;
					obstacle.position = "top";
				}
				else
				{
					// Or place it in the bottom of the screen.
					obstacle.y = gameArea.bottom - obstacle.height;
					obstacle.position = "bottom";
				}
			}
			else
			{
				// Otherwise, if it's any other obstacle type, put it somewhere in the middle of the screen.
				obstacle.y = Math.floor(Math.random() * (gameArea.bottom-obstacle.height - gameArea.top + 1)) + gameArea.top;
				obstacle.position = "middle";
			}
			
			// Set the obstacle's speed.
			obstacle.speed = GameConstants.OBSTACLE_SPEED;
			
			// Set look out mode to true, during which, a look out text appears.
			obstacle.lookOut = true;
			
			// Animate the obstacle.
			obstaclesToAnimate[obstaclesToAnimateLength++] = obstacle;
		}
		
		/**
		 * Animate obstacles marked for animation. 
		 * 
		 */
		private function animateObstacles():void
		{
			if (!gamePaused)
			{
				var obstacleToTrack:Obstacle;
				var heroRect:Rectangle;
				var heroRect2:Rectangle;
				var obstacleRect:Rectangle;
				
				for (var i:uint = 0; i < obstaclesToAnimateLength ; i ++)
				{
					obstacleToTrack = obstaclesToAnimate[i];
					
					// If the distance is still more than 0, keep reducing its value, without moving the obstacle.
					if (obstacleToTrack.distance > 0 ) 
					{
						obstacleToTrack.distance -= playerSpeed * elapsedP1;  
					}
					else  
					{
						// Otherwise, move the obstacle based on hero's speed, and check if he hits it. 
						
						// Remove the look out sign.
						if (obstacleToTrack.lookOut == true )
						{
							obstacleToTrack.lookOut = false;
						}
						
						// Move the obstacle based on hero's speed.
						obstacleToTrack.x -= (playerSpeed + obstacleToTrack.speed) * elapsedP1; 
					}
					
					// If the obstacle passes beyond the screen, remove it.
					if (obstacleToTrack.x < -obstacleToTrack.width || gameState == GameConstants.GAME_STATE_OVER)
					{
						disposeObstacleTemporarily(i, obstacleToTrack);
					}
					
					// Collision detection - Check if hero collides with any obstacle.
					heroObstacle_xDistP1 = obstacleToTrack.x - heroXP1;
					heroObstacle_yDistP1 = obstacleToTrack.y - heroYP1;
					heroObstacle_sqDistP1 = heroObstacle_xDistP1 * heroObstacle_xDistP1 + heroObstacle_yDistP1 * heroObstacle_yDistP1;
					
					heroObstacle_xDistP2 = obstacleToTrack.x - heroXP2;
					heroObstacle_yDistP2 = obstacleToTrack.y - heroYP2;
					heroObstacle_sqDistP2 = heroObstacle_xDistP2 * heroObstacle_xDistP2 + heroObstacle_yDistP2 * heroObstacle_yDistP2;

					if (heroObstacle_sqDistP1 < 5000 && !obstacleToTrack.alreadyHit)
					{
						obstacleToTrack.alreadyHit = true;
						
						if (!Sounds.muted) Sounds.sndHit.play();
						
						if (coffee > 0) 
						{
							// If hero has a coffee item, break through the obstacle.
							if (obstacleToTrack.position == "bottom") obstacleToTrack.rotation = deg2rad(100);
							else obstacleToTrack.rotation = deg2rad(-100);
							
							// Set hit obstacle value.
							hitObstacleP1 = 30;
							
							// Reduce hero's speed
							playerSpeed *= 0.8; 
						}
						else 
						{
							if (obstacleToTrack.position == "bottom") obstacleToTrack.rotation = deg2rad(70);
							else obstacleToTrack.rotation = deg2rad(-70);
							
							// Otherwise, if hero doesn't have a coffee item, set hit obstacle value.
							hitObstacleP1 = 30; 
							
							// Reduce hero's speed.
							playerSpeed *= 0.5; 
							
							// Play hurt sound.
							if (!Sounds.muted) Sounds.sndHurt.play();
							
							// Update lives.
							livesP1--;
							
							if (livesP1 <= 0)
							{
								livesP1 = 0;
								endGame();
							}
							
							hudP1.lives = livesP1;
						}
					}
					
					if (heroObstacle_sqDistP2 < 5000 && !obstacleToTrack.alreadyHit)
					{
						obstacleToTrack.alreadyHit = true;
						
						if (!Sounds.muted) Sounds.sndHit.play();
						
						if (coffee > 0) 
						{
							// If hero has a coffee item, break through the obstacle.
							if (obstacleToTrack.position == "bottom") obstacleToTrack.rotation = deg2rad(100);
							else obstacleToTrack.rotation = deg2rad(-100);
							
							// Set hit obstacle value.
							hitObstacleP2 = 30;
							
							// Reduce hero's speed
							playerSpeed *= 0.8; 
						}
						else 
						{
							if (obstacleToTrack.position == "bottom") obstacleToTrack.rotation = deg2rad(70);
							else obstacleToTrack.rotation = deg2rad(-70);
							
							// Otherwise, if hero doesn't have a coffee item, set hit obstacle value.
							hitObstacleP2 = 30; 
							
							// Reduce hero's speed.
							playerSpeed *= 0.5; 
							
							// Play hurt sound.
							if (!Sounds.muted) Sounds.sndHurt.play();
							
							// Update lives.
							livesP2--;
							
							if (livesP2 <= 0)
							{
								livesP2 = 0;
								endGame();
							}
							
							hudP2.lives = livesP2;
						}
					}
					
					// If the game has ended, remove the obstacle.
					if (gameState == GameConstants.GAME_STATE_OVER)
					{
						disposeObstacleTemporarily(i, obstacleToTrack);
					}
				}
			}
		}
		
		/**
		 * End game. 
		 * 
		 */
		private function endGame():void
		{
			this.x = 0;
			this.y = 0;
			
			// Set Game Over state so all obstacles and items can remove themselves.
			gameState = GameConstants.GAME_STATE_OVER;
		}
		
		/**
		 * Game Over - called when hero falls out of screen and when Game Over data should be displayed. 
		 * 
		 */
		private function gameOver():void
		{
			this.setChildIndex(gameOverContainer, this.numChildren-1);
			gameOverContainer.initialize(scoreItemsP1, Math.round(scoreDistanceP1));
			
			tween_gameOverContainer = new Tween(gameOverContainer, 1);
			tween_gameOverContainer.fadeTo(1);
			Starling.juggler.add(tween_gameOverContainer);
		}
		
		private function shakeAnimation(event:Event):void
		{
			// Animate quake effect, shaking the camera a little to the sides and up and down.
			if (cameraShake > 0)
			{
				cameraShake -= 0.1;
				// Shake left right randomly.
				this.x = int(Math.random() * cameraShake - cameraShake * 0.5); 
				// Shake up down randomly.
				this.y = int(Math.random() * cameraShake - cameraShake * 0.5); 
			}
			else if (x != 0) 
			{
				// If the shake value is 0, reset the stage back to normal.
				// Reset to initial position.
				this.x = 0;
				this.y = 0;
			}
		}
		
		/**
		 * Create an eat particle when an item is collected. 
		 * @param itemToTrack
		 * @param count
		 * 
		 */
		private function createEatParticle(itemToTrack:Item, count:int = 2):void
		{
			var eatParticleToTrack:Particle;
			
			while (count > 0)
			{
				count--;
				
				// Create eat particle object.
				eatParticleToTrack = eatParticlesPool.checkOut();
				
				if (eatParticleToTrack)
				{
					// Set the position of the particle object with a random offset.
					eatParticleToTrack.x = itemToTrack.x + Math.random() * 40 - 20;
					eatParticleToTrack.y = itemToTrack.y - Math.random() * 40;
					
					// Set the speed of a particle object. 
					eatParticleToTrack.speedY = Math.random() * 10 - 5;
					eatParticleToTrack.speedX = Math.random() * 2 + 1;
					
					// Set the spinning speed of the particle object.
					eatParticleToTrack.spin = Math.random() * 20 - 5;
					
					// Set the scale of the eat particle.
					eatParticleToTrack.scaleX = eatParticleToTrack.scaleY = Math.random() * 0.3 + 0.3;
					
					// Animate the eat particle.
					eatParticlesToAnimate[eatParticlesToAnimateLength++] = eatParticleToTrack;
				}
			}
		}
		
		/**
		 * Animate the wind particles that are marked animatable. 
		 * 
		 */
		private function animateWindParticles():void
		{
			var windToTrack:Particle;
			
			for(var i:uint = 0;i < windParticlesToAnimateLength;i++)
			{
				// Create wind particle.
				windToTrack = windParticlesToAnimate[i];
				
				if (windToTrack)
				{
					// Move the wind based on its scale.
					windToTrack.x -= 100 * windToTrack.scaleX; 
					
					// If the wind particle goes off screen, remove it.
					if (windToTrack.x < -windToTrack.width || gameState == GameConstants.GAME_STATE_OVER)
					{
						disposeWindParticleTemporarily(i, windToTrack);
					}
				}
			}
		}
		
		/**
		 * Animate the eat particles that are marked animatable. 
		 * 
		 */
		private function animateEatParticles():void
		{
			var eatParticleToTrack:Particle;
			
			for(var i:uint = 0;i < eatParticlesToAnimateLength;i++)
			{
				eatParticleToTrack = eatParticlesToAnimate[i];
				
				if (eatParticleToTrack)
				{
					eatParticleToTrack.scaleX -= 0.03;
					
					// Make the eat particle get smaller.
					eatParticleToTrack.scaleY = eatParticleToTrack.scaleX;
					// Move it horizontally based on speedX.
					eatParticleToTrack.y -= eatParticleToTrack.speedY; 
					// Reduce the horizontal speed.
					eatParticleToTrack.speedY -= eatParticleToTrack.speedY * 0.2;
					// Move it vertically based on speedY.
					eatParticleToTrack.x += eatParticleToTrack.speedX;
					// Reduce the vertical speed.
					eatParticleToTrack.speedX--; 
					
					// Rotate the eat particle based on spin.
					eatParticleToTrack.rotation += deg2rad(eatParticleToTrack.spin); 
					// Increase the spinning speed.
					eatParticleToTrack.spin *= 1.1; 
					
					// If the eat particle is small enough, remove it.
					if (eatParticleToTrack.scaleY <= 0.02)
					{
						disposeEatParticleTemporarily(i, eatParticleToTrack);
					}
				}
			}
		}
		
		/**
		 * On game over screen faded out. 
		 * 
		 */
		private function gameOverFadedOut():void
		{
			gameOverContainer.visible = false;
			initialize();
		}
		
		/**
		 * Calculate elapsed time. 
		 * @param event
		 * 
		 */
		private function calculateElapsed(event:Event):void
		{
			// Set the current time as the previous time.
			timePreviousP1 = timeCurrentP1;
			
			// Get teh new current time.
			timeCurrentP1 = getTimer(); 
			
			// Calcualte the time it takes for a frame to pass, in milliseconds.
			elapsedP1 = (timeCurrentP1 - timePreviousP1) * 0.001; 
		}
	}
}