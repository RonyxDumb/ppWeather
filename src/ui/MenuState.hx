package ui;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

#if android
import extension.androidtools.Tools;
import extension.haptics.Haptic;
#end

class MenuState extends FlxState
{
    private var titleText:FlxText;
    private var btnOption1:FlxButton;
    private var btnOption2:FlxButton;

    override public function create():Void
    {
        super.create();

        // 1. Titolo del Menu
        titleText = new FlxText(0, FlxG.height * 0.18, FlxG.width, "Seleziona Interfaccia");
        titleText.setFormat("fonts/notosansmono_regular.ttf", 38, FlxColor.WHITE, CENTER);
        titleText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
        add(titleText);

        // 2. Pulsante 1: Nuova Interfaccia (Dinamica)
        btnOption1 = new FlxButton(0, FlxG.height * 0.40, "Meteo Sfondo Dinamico", function() {
            triggerHaptic();
            FlxG.switchState(new MainPageBackground());
        });
        styleAndroidButton(btnOption1);
        add(btnOption1);

        // 3. Pulsante 2: Vecchia Interfaccia
        btnOption2 = new FlxButton(0, FlxG.height * 0.58, "Meteo Classico", function() {
            triggerHaptic();
            FlxG.switchState(new MainPage());
        });
        styleAndroidButton(btnOption2);
        add(btnOption2);

        // Centra i pulsanti orizzontalmente
        btnOption1.x = (FlxG.width - btnOption1.width) / 2;
        btnOption2.x = (FlxG.width - btnOption2.width) / 2;
    }

    private function styleAndroidButton(btn:FlxButton):Void
    {
        btn.makeGraphic(440, 75, 0xFF2A2A3D);
        btn.label.setFormat("fonts/notosansmono_regular.ttf", 22, FlxColor.WHITE, CENTER);
        btn.label.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
        
        // Centra il testo in larghezza e riduce l'offset verticale del testo
        btn.label.fieldWidth = btn.width;
        btn.label.offset.y = -20; // Offset corretto per centrare verticalmente l'etichetta
    }

    private function triggerHaptic():Void
    {
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }
}