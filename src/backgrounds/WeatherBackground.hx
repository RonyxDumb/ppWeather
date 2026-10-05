package backgrounds;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

enum WeatherTimeState
{
    DAY;
    NIGHT;
    SUNSET; // Crepuscolo Aesthetic
    RAIN;   // Condizione di pioggia
}

class WeatherBackground extends FlxGroup
{
    private var baseBg:FlxSprite;

    // Elementi Notturni
    private var starsGroup:FlxTypedGroup<StarParticle>;
    private var moonGroup:FlxGroup;
    private var moonSprite:FlxSprite;
    private var moonGlow:FlxSprite;

    // Elementi Diurni / Tramonto / Pioggia
    private var cloudsGroup:FlxTypedGroup<CloudSprite>;
    private var rainGroup:FlxTypedGroup<RainDropSprite>;

    public var currentState(default, null):WeatherTimeState;

    public function new()
    {
        super();

        // In WeatherBackground.hx -> new()
        baseBg = new FlxSprite(0, 0);
        baseBg.makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE); // <- Usa WHITE al posto di BLACK!
        add(baseBg);

        // 2. Stelle (Notte / Crepuscolo)
        starsGroup = new FlxTypedGroup<StarParticle>();
        createStars(85);
        add(starsGroup);

        // 3. Luna e Glow (Notte / Crepuscolo)
        moonGroup = new FlxGroup();
        createMoon();
        add(moonGroup);

        // 4. Nuvole Aesthetic
        cloudsGroup = new FlxTypedGroup<CloudSprite>();
        createClouds(6);
        add(cloudsGroup);

        // 5. Particelle di Pioggia
        rainGroup = new FlxTypedGroup<RainDropSprite>();
        createRain(110);
        add(rainGroup);

        updateByCurrentTime();
    }

    private function createStars(count:Int):Void
    {
        for (i in 0...count)
        {
            var x = FlxG.random.float(0, FlxG.width);
            var y = FlxG.random.float(0, FlxG.height * 0.75);
            var star = new StarParticle(x, y);
            starsGroup.add(star);
        }
    }

    private function createMoon():Void
    {
        var moonX = FlxG.width * 0.68;
        var moonY = FlxG.height * 0.08;
        var baseSize:Int = 120;

        // Bagliore esterno (Glow)
        moonGlow = new FlxSprite(moonX - 20, moonY - 20);
        moonGlow.makeGraphic(baseSize + 40, baseSize + 40, FlxColor.TRANSPARENT, true);
        FlxSpriteUtil.drawCircle(moonGlow, (baseSize + 40) / 2, (baseSize + 40) / 2, (baseSize + 40) / 2, FlxColor.fromRGB(255, 255, 255, 18));
        moonGlow.alpha = 0;
        moonGroup.add(moonGlow);

        // Corpo Luna Principale
        moonSprite = new FlxSprite(moonX, moonY);
        moonSprite.makeGraphic(baseSize, baseSize, FlxColor.TRANSPARENT, true);
        
        // Cerchio esterno ed interno soft
        FlxSpriteUtil.drawCircle(moonSprite, baseSize / 2, baseSize / 2, baseSize / 2, FlxColor.fromRGB(245, 247, 250, 40));
        FlxSpriteUtil.drawCircle(moonSprite, baseSize / 2, baseSize / 2, (baseSize / 2) - 10, FlxColor.fromRGB(240, 244, 255, 235));

        moonSprite.alpha = 0;
        moonGroup.add(moonSprite);

        // Animazione respiro/pulsazione in loop sulla luna
        FlxTween.tween(moonGlow, { alpha: 0.35 }, 2.5, { ease: FlxEase.sineInOut, type: PINGPONG });
    }

    private function createClouds(count:Int):Void
    {
        for (i in 0...count)
        {
            var cloud = new CloudSprite();
            cloudsGroup.add(cloud);
        }
    }

    private function createRain(count:Int):Void
    {
        for (i in 0...count)
        {
            var drop = new RainDropSprite();
            rainGroup.add(drop);
        }
    }

    public function updateByCurrentTime():Void
    {
        var hour = Date.now().getHours();

        if (hour >= 6 && hour < 8)
            setState(SUNSET);
        else if (hour >= 8 && hour < 18)
            setState(DAY);
        else if (hour >= 18 && hour < 21)
            setState(SUNSET);
        else
            setState(NIGHT);
    }

    public function setState(state:WeatherTimeState):Void
    {
        currentState = state;

        var targetColor:FlxColor;

        switch (state)
        {
            case DAY:
                // Azzurro pastello Pinterest
                targetColor = FlxColor.fromRGB(112, 171, 255); 
                setStarsVisibility(false);
                fadeMoon(0.0);
                setRainVisibility(false);
                setCloudsTint(FlxColor.fromRGB(255, 255, 255));

            case SUNSET:
                // Viola / Magenta Crepuscolare Aesthetic
                targetColor = FlxColor.fromRGB(58, 32, 79);
                setStarsVisibility(true);
                fadeMoon(0.5);
                setRainVisibility(false);
                setCloudsTint(FlxColor.fromRGB(152, 108, 168));

            case NIGHT:
                // TOTAL BLACK per la notte
                targetColor = FlxColor.BLACK; 
                setStarsVisibility(true);
                fadeMoon(0.95);
                setRainVisibility(false);
                setCloudsTint(FlxColor.fromRGB(45, 52, 75));

            case RAIN:
                // Grigio/Blu desaturato mood
                targetColor = FlxColor.fromRGB(22, 28, 40); 
                setStarsVisibility(false);
                fadeMoon(0.0);
                setRainVisibility(true);
                setCloudsTint(FlxColor.fromRGB(80, 92, 110));
        } // <-- Lo switch DEVE chiudersi qui!

        // Se baseBg è appena stato creato (è ancora bianco puro), gli diamo subito il colore bersaglio
        if (baseBg.color == FlxColor.WHITE)
            baseBg.color = targetColor;

        FlxTween.color(baseBg, 1.2, baseBg.color, targetColor);
    }

    private function setStarsVisibility(visible:Bool):Void
    {
        for (star in starsGroup.members)
        {
            if (star != null)
                star.targetGroupAlpha = visible ? 1.0 : 0.0;
        }
    }

    private function setRainVisibility(visible:Bool):Void
    {
        for (drop in rainGroup.members)
        {
            if (drop != null)
                drop.targetAlpha = visible ? FlxG.random.float(0.4, 0.85) : 0.0;
        }
    }

    private function fadeMoon(targetAlpha:Float):Void
    {
        if (moonSprite != null)
            FlxTween.tween(moonSprite, { alpha: targetAlpha }, 1.2, { ease: FlxEase.sineOut });

        if (moonGlow != null)
            FlxTween.tween(moonGlow, { alpha: targetAlpha > 0 ? targetAlpha * 0.4 : 0.0 }, 1.2, { ease: FlxEase.sineOut });
    }

    private function setCloudsTint(color:FlxColor):Void
    {
        for (cloud in cloudsGroup.members)
        {
            if (cloud != null)
            {
                FlxTween.color(cloud, 1.2, cloud.color, color, { ease: FlxEase.quadOut });
            }
        }
    }
}

// ============================================================================
// CLASSI ELEMENTI GRAFICI MIGLIORATE
// ============================================================================

class StarParticle extends FlxSprite
{
    private var twinkleSpeed:Float;
    private var timer:Float = 0;

    public var targetGroupAlpha:Float = 0.0;
    private var currentGroupAlpha:Float = 0.0;

    public function new(x:Float, y:Float)
    {
        super(x, y);

        // Dimensione variabile (alcune più grandi, toni pastel warm/cool)
        var size = FlxG.random.int(2, 5);
        makeGraphic(size, size, FlxColor.WHITE);

        // Tinta soft per estetica pinterest
        var starTints = [0xFFFFFF, 0xFFF2D6, 0xE2EEFF, 0xFFE0EC];
        color = starTints[FlxG.random.int(0, starTints.length - 1)];

        twinkleSpeed = FlxG.random.float(1.2, 3.5);
        timer = FlxG.random.float(0, 10);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        currentGroupAlpha = flixel.math.FlxMath.lerp(currentGroupAlpha, targetGroupAlpha, elapsed * 3.5);
        timer += elapsed * twinkleSpeed;
        
        var twinkle = 0.25 + (Math.sin(timer) * 0.45);
        alpha = Math.max(0, twinkle * currentGroupAlpha);
    }
}

class CloudSprite extends FlxSprite
{
    private var speed:Float;
    private var floatTimer:Float = 0;
    private var startY:Float = 0;
    private var floatAmplitude:Float;

    public function new()
    {
        super();
        alpha = 0.95;
        resetCloud(true);
    }

    public function resetCloud(randomX:Bool = false):Void
    {
        var path:String = "img/cloud.png";

        try 
        {
            loadGraphic(path);
        }
        catch(e:Dynamic)
        {
            loadGraphic("img/cloud.png");
        }

        // Ingrandimento e scala differenziata per le nuvole
        var targetWidth:Int = FlxG.random.int(240, 360);
        setGraphicSize(targetWidth, 0);
        updateHitbox();

        x = randomX ? FlxG.random.float(-100, FlxG.width - width) : -width - 80;
        startY = FlxG.random.float(FlxG.height * 0.01, FlxG.height * 0.35);
        y = startY;

        speed = FlxG.random.float(12, 28);
        floatAmplitude = FlxG.random.float(6, 14);
        floatTimer = FlxG.random.float(0, 10);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        // Movimento orizzontale
        x += speed * elapsed;

        // Fluttuazione verticale sinusoidale fluida
        floatTimer += elapsed * 0.8;
        y = startY + (Math.sin(floatTimer) * floatAmplitude);

        if (x > FlxG.width + 100)
        {
            resetCloud(false);
        }
    }
}

class RainDropSprite extends FlxSprite
{
    private var fallSpeed:Float;
    public var targetAlpha:Float = 0.0;

    public function new()
    {
        super();

        var w = FlxG.random.int(2, 3);
        var h = FlxG.random.int(18, 32);
        makeGraphic(w, h, FlxColor.fromRGB(200, 225, 255));

        resetDrop(true);
    }

    private function resetDrop(randomY:Bool = false):Void
    {
        x = FlxG.random.float(-50, FlxG.width + 50);
        y = randomY ? FlxG.random.float(0, FlxG.height) : -40;

        fallSpeed = FlxG.random.float(600, 1100);
        alpha = 0.0;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        alpha = flixel.math.FlxMath.lerp(alpha, targetAlpha, elapsed * 4.5);

        if (targetAlpha > 0.05)
        {
            y += fallSpeed * elapsed;
            x -= (fallSpeed * 0.18) * elapsed; // Angolazione di caduta fluida

            if (y > FlxG.height + 30)
            {
                resetDrop(false);
            }
        }
    }
}