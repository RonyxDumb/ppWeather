package;

import ui.MainPageBackground;
import ui.MenuState;
import lime.system.System;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.system.scaleModes.RatioScaleMode;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;

/**
 * Main class standard per HaxeFlixel in orientamento verticale (Portrait).
 */
class Main extends Sprite
{
  // Dimensioni virtuali verticali (Portrait)
  #if android
  var gameWidth:Int = 0;
  var gameHeight:Int = 0;
  #else
  var gameWidth:Int = 720;
  var gameHeight:Int = 1280;
  #end
  
  // Sostituisci PlayState con lo stato iniziale della tua app meteo
  var initialState:Class<FlxState> = MainPageBackground; 
  var zoom:Float = -1;
  var framerate:Int = 60;
  var skipSplash:Bool = true;
  var startFullscreen:Bool = false;

  // FPS Counter di default OpenFL
  public static var fpsCounter:FPS;

  public static function main():Void
  {
    #if android
    // Imposta la cartella di lavoro corretta per Android
    Sys.setCwd(haxe.io.Path.addTrailingSlash(extension.androidtools.content.Context.getExternalFilesDir()));
    #elseif ios
    // Imposta la cartella di lavoro per iOS
    Sys.setCwd(haxe.io.Path.addTrailingSlash(lime.system.System.documentsDirectory));
    #end

    Lib.current.addChild(new Main());
  }

  public function new()
  {
    super();

    if (stage != null)
    {
      init();
    }
    else
    {
      addEventListener(Event.ADDED_TO_STAGE, init);
    }
  }

  function init(?event:Event):Void
  {
    if (hasEventListener(Event.ADDED_TO_STAGE))
    {
      removeEventListener(Event.ADDED_TO_STAGE, init);
    }

    #if (sys && !mobile)
    // Chiusura pulita delle risorse su PC
    Lib.current.stage.window.onClose.add(function()
    {
      Sys.exit(0);
    });
    #end

    setupGame();
  }

  function setupGame():Void
  {
      #if mobile
      // Risoluzione di riferimento (Portrait)
      var baseWidth:Int = 720;
      var baseHeight:Int = 1280;

      var stageWidth:Int = Lib.current.stage.stageWidth;
      var stageHeight:Int = Lib.current.stage.stageHeight;

      // Calcola lo zoom mantenendo il rapporto
      var zoomX:Float = stageWidth / baseWidth;
      var zoomY:Float = stageHeight / baseHeight;
      var zoom:Float = Math.min(zoomX, zoomY);

      // Calcola la nuova area logica
      gameWidth = Math.ceil(stageWidth / zoom);
      gameHeight = Math.ceil(stageHeight / zoom);
      #end

      var game = new FlxGame(
          gameWidth,
          gameHeight,
          initialState,
          framerate,
          framerate,
          skipSplash,
          startFullscreen
      );

      addChild(game);

      #if !html5
      FlxG.scaleMode = new RatioScaleMode(true);
      #end

      fpsCounter = new FPS(10, 10, 0xFFFFFF);
      // addChild(fpsCounter);

      #if mobile
      FlxG.signals.preUpdate.add(repositionCounters.bind(true));
      repositionCounters(false);
      #end
  }

  #if mobile
  function repositionCounters(lerp:Bool):Void
  {
    // Scala l'overlay in base alla risoluzione reale dello schermo rispetto a quella interna
    var scale:Float = Math.max(Math.min(FlxG.stage.stageWidth / FlxG.width, FlxG.stage.stageHeight / FlxG.height), 1);

    if (fpsCounter != null)
    {
      fpsCounter.scaleX = fpsCounter.scaleY = scale;

      if (FlxG.game != null)
      {
        // Margin/Padding per evitare tagli o il notch del telefono
        var paddingX:Float = 10;

        var targetX:Float = FlxG.game.x + paddingX;
        var targetY:Float = FlxG.game.y + (3 * scale);

        if (lerp)
        {
          fpsCounter.x = flixel.math.FlxMath.lerp(fpsCounter.x, targetX, FlxG.elapsed * 3);
        }
        else
        {
          fpsCounter.x = targetX;
        }

        fpsCounter.y = targetY;
      }
    }
  }
  #end
}