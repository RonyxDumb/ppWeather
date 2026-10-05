package ui;

#if android
import extension.androidtools.Tools;
import extension.haptics.Haptic;
#end
import backgrounds.WeatherBackground;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.events.Event;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import haxe.Json;

class MainPageBackground extends FlxState
{
    var bg:WeatherBackground;

    var cityText:FlxText;
    var currentTempText:FlxText;
    var line1Text:FlxText;
    var stateText:FlxText;
    var line3Text:FlxText;
    var forecastTableText:FlxText;

    override public function create()
    {
        super.create();
        // 1. Inizializza lo sfondo con l'ora attuale per evitare il flash bianco
        bg = new WeatherBackground();
        bg.updateByCurrentTime();
        add(bg);

        var fontPath:String = "fonts/notosansmono_regular.ttf"; 
        var marginLeft:Float = 40;
        var contentWidth:Float = FlxG.width - (marginLeft * 2);

        // 2. Definizione testi
        cityText = new FlxText(marginLeft, 0, contentWidth, "*Apricena*");
        cityText.setFormat(fontPath, 38, 0xDDDDDD, LEFT);

        currentTempText = new FlxText(marginLeft, 0, contentWidth, "--°C");
        currentTempText.setFormat(fontPath, 64, FlxColor.WHITE, LEFT);

        // Blocco centrale
        line1Text = new FlxText(marginLeft, 0, contentWidth, "Il meteo di oggi è");
        line1Text.setFormat(fontPath, 42, FlxColor.WHITE, LEFT);

        stateText = new FlxText(marginLeft, 0, contentWidth, "CARICAMENTO...");
        stateText.setFormat(fontPath, 48, 0x88CCFF, LEFT);

        line3Text = new FlxText(marginLeft, 0, contentWidth, "rispetto a ieri");
        line3Text.setFormat(fontPath, 42, FlxColor.WHITE, LEFT);

        // Tabella fasce orarie in basso: Font ancora più grande (38px)
        forecastTableText = new FlxText(marginLeft, 0, contentWidth, "");
        forecastTableText.setFormat(fontPath, 38, 0xEEEEEE, LEFT);

        add(cityText);
        add(currentTempText);
        add(line1Text);
        add(stateText);
        add(line3Text);
        add(forecastTableText);

        repositionElements();
        loadWeather();
    }

    function repositionElements()
    {
        var h = FlxG.height;

        // Città in alto
        cityText.y = h * 0.05;

        // Temperatura attuale poco sotto
        currentTempText.y = cityText.y + 65;

        // Blocco centrale posizionato più verso il centro (h * 0.35) e con più respiro tra le righe
        line1Text.y = h * 0.35;
        stateText.y = line1Text.y + 80; // Aumentata la distanza
        line3Text.y = stateText.y + 90; // Aumentata la distanza

        // Tabella oraria in basso
        forecastTableText.y = h * 0.72;
    }

    function loadWeather()
    {
        var url = "https://api.open-meteo.com/v1/forecast"
            + "?latitude=41.786"
            + "&longitude=15.443"
            + "&current=temperature_2m,rain,showers"
            + "&hourly=temperature_2m"
            + "&daily=temperature_2m_max"
            + "&forecast_days=2"
            + "&past_days=1"
            + "&timezone=Europe/Rome";

        var loader = new URLLoader();

        loader.addEventListener(Event.COMPLETE, function(e:Event)
        {
            try 
            {
                var json:Dynamic = Json.parse(loader.data);

                if (json.current != null && json.current.temperature_2m != null)
                {
                    var currentTemp:Int = Math.round(json.current.temperature_2m);
                    currentTempText.text = currentTemp + "°C";
                }

                var yesterdayMax:Float = json.daily.temperature_2m_max[0];
                var todayMax:Float = json.daily.temperature_2m_max[1];

                var diff = todayMax - yesterdayMax;
                if (diff > 0.5)
                {
                    stateText.text = "PIÙ CALDO";
                    stateText.color = 0xFF6644;
                }
                else if (diff < -0.5)
                {
                    stateText.text = "PIÙ FREDDO";
                    stateText.color = 0x88CCFF;
                }
                else
                {
                    stateText.text = "PRESSOCHÉ UGUALE";
                    stateText.color = FlxColor.WHITE;
                }

                stateText.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0x111122, 2);

                var morningTemp:Int = Math.round(json.hourly.temperature_2m[32]);
                var noonTemp:Int = Math.round(json.hourly.temperature_2m[36]);
                var eveningTemp:Int = Math.round(json.hourly.temperature_2m[43]);
                var nightTemp:Int = Math.round(json.hourly.temperature_2m[47]);

                forecastTableText.text = 
                    "Mattina     " + morningTemp + "°C\n\n" +
                    "Pomeriggio  " + noonTemp + "°C\n\n" +
                    "Sera        " + eveningTemp + "°C\n\n" +
                    "Notte       " + nightTemp + "°C";

                var currentRain:Float = json.current.rain != null ? json.current.rain : 0.0;
                var currentShowers:Float = json.current.showers != null ? json.current.showers : 0.0;

                if (currentRain > 0.0 || currentShowers > 0.0)
                {
                    bg.setState(RAIN);
                }
                else
                {
                    bg.updateByCurrentTime();
                }
            }
            catch (err:Dynamic)
            {
                stateText.text = "ERRORE";
                stateText.color = 0xFF3333;
            }
        });

        loader.load(new URLRequest(url));
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}