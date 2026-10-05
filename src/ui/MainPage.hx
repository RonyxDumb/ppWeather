package ui;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.events.Event;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import haxe.Json;

class MainPage extends FlxState
{
    var cityText:FlxText;
    
    // Temperatura attuale
    var currentTempText:FlxText;

    // Frase centrale di confronto
    var line1Text:FlxText;
    var stateText:FlxText; // "PIÙ FREDDO" / "PIÙ CALDO" / "PRESSOCHÉ UGUALE"
    var line3Text:FlxText;

    // Tabella oraria in basso
    var forecastTableText:FlxText;

    override public function create()
    {
        super.create();

        FlxG.camera.bgColor = FlxColor.BLACK;

        var fontPath:String = "fonts/notosansmono_regular.ttf"; 

        var marginLeft:Float = 40;
        var contentWidth:Float = FlxG.width - (marginLeft * 2);

        // 1. Nome Città (*Apricena*)
        cityText = new FlxText(marginLeft, 0, contentWidth, "*Apricena*");
        cityText.setFormat(fontPath, 38, 0xDDDDDD, LEFT);

        // 2. Temperatura Attuale
        currentTempText = new FlxText(marginLeft, 0, contentWidth, "--°C");
        currentTempText.setFormat(fontPath, 64, FlxColor.WHITE, LEFT);

        // 3. Frase Principale (Stile Lazy Weather)
        line1Text = new FlxText(marginLeft, 0, contentWidth, "Il meteo di oggi è");
        line1Text.setFormat(fontPath, 42, FlxColor.WHITE, LEFT);

        stateText = new FlxText(marginLeft, 0, contentWidth, "CARICAMENTO...");
        stateText.setFormat(fontPath, 48, 0x88CCFF, LEFT);

        line3Text = new FlxText(marginLeft, 0, contentWidth, "rispetto a ieri");
        line3Text.setFormat(fontPath, 42, FlxColor.WHITE, LEFT);

        // 4. Tabella dettagliata per fasce orarie (Font ingrandito a 38px)
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

        // Temperatura attuale subito sotto
        currentTempText.y = cityText.y + 65;

        // Blocco centrale posizionato più al centro (h * 0.35) e con più respiro tra le righe
        line1Text.y = h * 0.35;
        stateText.y = line1Text.y + 80;
        line3Text.y = stateText.y + 90;

        // Tabella fasce orarie spinta in basso
        forecastTableText.y = h * 0.72;
    }

    function loadWeather()
    {
        var url = "https://api.open-meteo.com/v1/forecast"
            + "?latitude=41.786"
            + "&longitude=15.443"
            + "&current=temperature_2m"
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

                // Lettura della temperatura attuale
                if (json.current != null && json.current.temperature_2m != null)
                {
                    var currentTemp:Int = Math.round(json.current.temperature_2m);
                    currentTempText.text = currentTemp + "°C";
                }

                var yesterdayMax:Float = json.daily.temperature_2m_max[0];
                var todayMax:Float = json.daily.temperature_2m_max[1];

                // Aggiorna lo stato "PIÙ CALDO" / "PIÙ FREDDO"
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

                // Generazione tabella oraria (Mattina, Pomeriggio, Sera, Notte)
                var morningTemp:Int = Math.round(json.hourly.temperature_2m[32]);   // h 08:00
                var noonTemp:Int = Math.round(json.hourly.temperature_2m[36]);      // h 12:00
                var eveningTemp:Int = Math.round(json.hourly.temperature_2m[43]);   // h 19:00
                var nightTemp:Int = Math.round(json.hourly.temperature_2m[47]);     // h 23:00

                forecastTableText.text = 
                    "Mattina     " + morningTemp + "°C\n\n" +
                    "Pomeriggio  " + noonTemp + "°C\n\n" +
                    "Sera        " + eveningTemp + "°C\n\n" +
                    "Notte       " + nightTemp + "°C";
            }
            catch (err:Dynamic)
            {
                stateText.text = "ERRORE";
                stateText.color = 0xFF3333;
            }
        });

        loader.load(new URLRequest(url));
    }
}