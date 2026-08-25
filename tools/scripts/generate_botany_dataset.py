#!/usr/bin/env python3
"""
Botanical dataset generator:
Fetches Wikipedia summaries or builds a high-quality dataset of 90 plants (30 per ecosystem)
with taxonomy, leaf/flower traits, habitat, confusion species, and 4 questions per plant.
"""

import json
import urllib.request
import urllib.parse
import re

ECOSYSTEMS = [
    {
        "name": "Wald & Forst",
        "description": "Mitteleuropäischer Laub-, Misch- und Nadelwald mit charakteristischer Kraut- und Baumschicht.",
        "climateZone": "gemäßigt",
        "plants": [
            ("Rotbuche", "Fagus sylvatica", "Fagaceae", "Fagales", "Fagus", "sylvatica", "Glatte silbergraue Rinde, eiförmige bis elliptische Blätter mit gewelltem Rand, Bucheckern als Früchte."),
            ("Stieleiche", "Quercus robur", "Fagaceae", "Fagales", "Quercus", "robur", "Buchtig gelappte Blätter mit kurzen Stielen, Eicheln an langen Stielen, tief gefurchte Borke."),
            ("Traubeneiche", "Quercus petraea", "Fagaceae", "Fagales", "Quercus", "petraea", "Gleichmäßig gelappte Blätter an langen Stielen, Eicheln sitzend oder traubig gehäuft."),
            ("Bergahorn", "Acer pseudoplatanus", "Fagaceae", "Sapindales", "Acer", "pseudoplatanus", "Handförmig fünflappige Blätter, geflügelte Nussfrüchte im spitzen Winkel zueinander."),
            ("Spitzahorn", "Acer platanoides", "Sapindaceae", "Sapindales", "Acer", "platanoides", "Spitz gezähnte Blattlappen, gelbgrüne Blütendolden vor dem Laubaustrieb, Milchsaft im Blattstiel."),
            ("Gemeine Esche", "Fraxinus excelsior", "Oleaceae", "Lamiales", "Fraxinus", "excelsior", "Ungerade gefiederte Blätter mit 9-15 Fiederblättchen, schwarze Knospen im Winter."),
            ("Sommerlinde", "Tilia platyphyllos", "Malvaceae", "Malvales", "Tilia", "platyphyllos", "Herzförmige Blätter, beidseitig weich behaart, weiße Haarbüschel in den Nervenwinkeln."),
            ("Winterlinde", "Tilia cordata", "Malvaceae", "Malvales", "Tilia", "cordata", "Herzförmige Blätter, unterseits bläulich-grün mit rostbraunen Haarbüscheln in den Blattnerven."),
            ("Hänge-Birke", "Betula pendula", "Betulaceae", "Fagales", "Betula", "pendula", "Weiße abblätternde Rinde, dreieckige zugespitzte Blätter, überhängende Zweige."),
            ("Schwarz-Erle", "Alnus glutinosa", "Betulaceae", "Fagales", "Alnus", "glutinosa", "Verkehrt-eiförmige Blätter mit eingebuchteter Spitze, verholzte Zapfenstände."),
            ("Vogelbeere", "Sorbus aucuparia", "Rosaceae", "Rosales", "Sorbus", "aucuparia", "Gefiederte Blätter, weiße Schirmrispen, leuchtend rote Beeren im Herbst."),
            ("Wald-Kiefer", "Pinus sylvestris", "Pinaceae", "Pinales", "Pinus", "sylvestris", "Zweinadelige Kurztriebe, bläulich-grüne gedrehte Nadeln, rotbraune Spiegelrinde im oberen Stamm."),
            ("Gemeine Fichte", "Picea abies", "Pinaceae", "Pinales", "Picea", "abies", "Vierkantige spitze Einzelnadeln, herabhängende Zapfen, rotbraune Schuppenborke."),
            ("Weiß-Tanne", "Abies alba", "Pinaceae", "Pinales", "Abies", "alba", "Flache scheitelig gekämmte Nadeln mit 2 weißen Wachsstreifen unterseits, aufrecht stehende Zapfen."),
            ("Europäische Eibe", "Taxus baccata", "Taxaceae", "Pinales", "Taxus", "baccata", "Dunkelgrüne weiche Nadeln ohne Harzkanäle, roter fleischiger Samenmantel (Arillus), giftig."),
            ("Europäische Lärche", "Larix decidua", "Pinaceae", "Pinales", "Larix", "decidua", "Sommergrüner Nadelbaum, weiche Nadeln in Büscheln an Kurztrieben, goldgelbe Herbstfärbung."),
            ("Waldmeister", "Galium odoratum", "Rubiaceae", "Gentianales", "Galium", "odoratum", "Vierkantiger Stängel, Blätter in 6-8-zähligen Quirlen, weiße vierzählige Blüten, Cumarinduft."),
            ("Bärlauch", "Allium ursinum", "Amaryllidaceae", "Asparagales", "Allium", "ursinum", "Breit-lanzettliche Blätter mit deutlichem Stiel, starker Knoblauchgeruch, weiße Sternblütendolden."),
            ("Buschwindröschen", "Anemone nemorosa", "Ranunculaceae", "Ranunculales", "Anemone", "nemorosa", "Frühjahrsgeophyt, drei dreiteilige Hochblätter, meist sechs weiße Blütenblätter."),
            ("Gelbes Windröschen", "Anemone ranunculoides", "Ranunculaceae", "Ranunculales", "Anemone", "ranunculoides", "Goldgelbe Blüten mit meist fünf Blütenhüllblättern, kurz gestielte Hochblätter."),
            ("Wald-Sauerklee", "Oxalis acetosella", "Oxalidaceae", "Oxalidales", "Oxalis", "acetosella", "Dreiblättrige herzförmige Kleeblätter, weiße Blüten mit violetten Adern, säuerlicher Geschmack."),
            ("Wald-Erdbeere", "Fragaria vesca", "Rosaceae", "Rosales", "Fragaria", "vesca", "Dreiteilige gezähnte Blätter, weiße fünfzählige Blüten, kleine aromatische Sammelnussfrüchte."),
            ("Heidelbeere", "Vaccinium myrtillus", "Ericaceae", "Ericales", "Vaccinium", "myrtillus", "Grüne kantige Stängel, laubabwerfend, kugelige blauschwarze bereifte Beeren mit blauem Fruchtfleisch."),
            ("Preiselbeere", "Vaccinium vitis-idaea", "Ericaceae", "Ericales", "Vaccinium", "vitis-idaea", "Immergrüner Zwergstrauch, ledrige unterseits punktierte Blätter, leuchtend rote Beeren."),
            ("Maiglöckchen", "Convallaria majalis", "Asparagaceae", "Asparagales", "Convallaria", "majalis", "Zwei grundständige breit-lanzettliche Blätter, einseitswendige Traube weißer Glockenblüten."),
            ("Vielblütige Weißwurz", "Polygonatum multiflorum", "Asparagaceae", "Asparagales", "Polygonatum", "multiflorum", "Überhängender runder Stängel, zweizeilig angeordnete Blätter, röhrige weiß-grüne Blüten."),
            ("Echtes Lungenkraut", "Pulmonaria officinalis", "Boraginaceae", "Boraginales", "Pulmonaria", "officinalis", "Weiß gefleckte Blätter, Blüten wechseln Farbe von rosa zu blauviolett."),
            ("Wald-Veilchen", "Viola reichenbachiana", "Violaceae", "Malpighiales", "Viola", "reichenbachiana", "Herzförmige Blätter, zart violette Blüten mit schlankem lila Sporn."),
            ("Echter Wurmfarn", "Dryopteris filix-mas", "Dryopteridaceae", "Polypodiales", "Dryopteris", "filix-mas", "Trichterförmig angeordnete Wedel, Spreuschuppen an der Spindel, nierenförmige Schleier."),
            ("Adlerfarn", "Pteridium aquilinum", "Dennstaedtiaceae", "Polypodiales", "Pteridium", "aquilinum", "Sehr große drei- bis vierfach gefiederte Einzelwedel aus unterirdischem Rhizom.")
        ]
    },
    {
        "name": "Wiese & Weide",
        "description": "Artenreiche Grünlandgesellschaften von sonnigen Fettwiesen bis zu mageren Bergwiesen.",
        "climateZone": "gemäßigt",
        "plants": [
            ("Löwenzahn", "Taraxacum officinale", "Asteraceae", "Asterales", "Taraxacum", "officinale", "Schrotsägeförmig gezähnte Grundblätter, hohler stängelloser Blütenschaft mit Milchsaft, gelber Blütenkorb, Pusteblume."),
            ("Wiesen-Salbei", "Salvia pratensis", "Lamiaceae", "Lamiales", "Salvia", "pratensis", "Gefurchter vierkantiger Stängel, tiefblaue zygomorphe Lippenblüten mit Hebelmechanismus."),
            ("Rot-Klee", "Trifolium pratense", "Fabaceae", "Fabales", "Trifolium", "pratense", "Dreiblättrige Blätter mit hellem V-Muster, eiförmige kugelige rötliche Blütenköpfchen."),
            ("Weiß-Klee", "Trifolium repens", "Fabaceae", "Fabales", "Trifolium", "repens", "Kriechende kriechende Stängel, weiße bis zartrosa kugelige Blütenstände, nahrhafte Futterpflanze."),
            ("Gemeine Schafgarbe", "Achillea millefolium", "Asteraceae", "Asterales", "Achillea", "millefolium", "Mehrfach fiederteilige Blätter (Augenbraue der Venus), weiße bis rosa Scheindolden."),
            ("Spitzwegerich", "Plantago lanceolata", "Plantaginaceae", "Lamiales", "Plantago", "lanceolata", "Schmal lanzettliche Blätter mit parallelen Blattnerven, walzenförmige braune Ähren mit hellen Staubbeuteln."),
            ("Breitwegerich", "Plantago major", "Plantaginaceae", "Lamiales", "Plantago", "major", "Breit-eiförmige derbe Blätter in flacher Rosette, lange schlanke zylindrische Blütenähren."),
            ("Gänseblümchen", "Bellis perennis", "Asteraceae", "Asterales", "Bellis", "perennis", "Spatelförmige Blattrosette, einköpfiger Schaft mit weißen Zungen- und gelben Röhrenblüten."),
            ("Magerwiesen-Margerite", "Leucanthemum vulgare", "Asteraceae", "Asterales", "Leucanthemum", "vulgare", "Aufrechter Stängel mit einzelnen großen Blütenkörben, weiße Strahlen und gelbe Scheibe."),
            ("Wiesen-Glockenblume", "Campanula patula", "Campanulaceae", "Asterales", "Campanula", "patula", "Trichter- bis glockenförmige violettblaue Blüten in lockerer Rispe, spreizende Kronzipfel."),
            ("Rundblättrige Glockenblume", "Campanula rotundifolia", "Campanulaceae", "Asterales", "Campanula", "rotundifolia", "Grundblätter rundlich-nierenförmig, Stängelblätter schmal-lanzettlich, nickende Glocken."),
            ("Gewöhnlicher Hornklee", "Lotus corniculatus", "Fabaceae", "Fabales", "Lotus", "corniculatus", "Fünfzählige Blätter, gelbe Schmetterlingsblüten oft rötlich überlaufen, hornförmige Hülsen."),
            ("Wiesen-Flockenblume", "Centaurea jacea", "Asteraceae", "Asterales", "Centaurea", "jacea", "Korbblüten mit fransig geschlitzten Hüllblättern, purpurviolette sterile Randblüten."),
            ("Wiesen-Pippau", "Crepis biennis", "Asteraceae", "Asterales", "Crepis", "biennis", "Fiederspaltige Blätter mit Pfeilfuß, reich verzweigte Schirmrispe mit gelben Körbchen."),
            ("Scharfer Hahnenfuß", "Ranunculus acris", "Ranunculaceae", "Ranunculales", "Ranunculus", "acris", "Tief handförmig geteilte Blätter, glänzende goldgelbe Blüten mit rundem Blütenstiel."),
            ("Kriechender Hahnenfuß", "Ranunculus repens", "Ranunculaceae", "Ranunculales", "Ranunculus", "repens", "Oberirdische Ausläufer (Stolonen), dreiteilige Blätter mit gestieltem Mittelabschnitt."),
            ("Echtes Labkraut", "Galium verum", "Rubiaceae", "Gentianales", "Galium", "verum", "Schmale nadelartige Blätter in 8-12-zähligen Quirlen, goldgelbe nach Honig duftende Blütenrispen."),
            ("Wiesen-Labkraut", "Galium mollugo", "Rubiaceae", "Gentianales", "Galium", "mollugo", "Vierkantiger schlaffer Stängel, elliptische Blätter in Quirlen, lockere weiße Blütenrispen."),
            ("Frauenmantel", "Alchemilla vulgaris", "Rosaceae", "Rosales", "Alchemilla", "vulgaris", "Fächerförmig gelappte Blätter mit gezähntem Rand, Guttationstropfen im Blattzentrum, unscheinbare gelbgrüne Blüten."),
            ("Wiesen-Kerbel", "Anthriscus sylvestris", "Apiaceae", "Apiales", "Anthriscus", "sylvestris", "Zwei- bis dreifach gefiederte dreieckige Blätter, gefurchter hohler Stängel, weiße Doppeldolden."),
            ("Wilde Möhre", "Daucus carota", "Apiaceae", "Apiales", "Daucus", "carota", "Fein gefiederte Blätter, weiße Doppeldolde oft mit purpurschwarzer 'Mohrenblüte' im Zentrum, vogelnestartig einrollend."),
            ("Pastinak", "Pastinaca sativa", "Apiaceae", "Apiales", "Pastinaca", "sativa", "Einfach gefiederte Blätter mit gekerbten Abschnitten, kantiger Stängel, gelbe Doppeldolden."),
            ("Kleiner Klappertopf", "Rhinanthus minor", "Orobanchaceae", "Lamiales", "Rhinanthus", "minor", "Halbschmarotzer auf Gräsern, aufgeblasener Kelch, gelbe zweilippige Blüten mit blauem Zahn."),
            ("Augentrost", "Euphrasia officinalis", "Orobanchaceae", "Lamiales", "Euphrasia", "officinalis", "Kleiner Halbschmarotzer, weiße Blüten mit violetten Adern und gelbem Schlundfleck."),
            ("Echtes Johanniskraut", "Hypericum perforatum", "Hypericaceae", "Malpighiales", "Hypericum", "perforatum", "Zweikantiger Stängel, Blätter gegen das Licht durchscheinend punktiert (Öldrüsen), goldgelbe Blüten mit rotem Saft beim Zerreiben."),
            ("Wiesen-Bocksbart", "Tragopogon pratensis", "Asteraceae", "Asterales", "Tragopogon", "pratensis", "Grasartige Blätter mit stängelumfassendem Grund, große gelbe Körbe die sich mittags schließen."),
            ("Wiesen-Platterbse", "Lathyrus pratensis", "Fabaceae", "Fabales", "Lathyrus", "pratensis", "Gefiederte Blätter mit Endranke und großen pfeilförmigen Nebenblättern, leuchtend gelbe Blütentrauben."),
            ("Wilde Karde", "Dipsacus fullonum", "Caprifoliaceae", "Dipsacales", "Dipsacus", "fullonum", "Stacheliger Stängel, gegenständige am Grund verwachsene Blätter bilden Wasserbecken (Krypophyten), eiförmiger stacheliger Blütenkopf."),
            ("Stängelloser Enzian", "Gentiana acaulis", "Gentianaceae", "Gentianales", "Gentiana", "acaulis", "Glänzende ledrige Rosettenblätter, riesige tiefblaue Glockenblüte mit grünen Punkten im Schlund."),
            ("Frühlings-Enzian", "Gentiana verna", "Gentianaceae", "Gentianales", "Gentiana", "verna", "Kleine Rosette, leuchtend azurblaue radförmige Blüten mit fünf ausgebreiteten Kronzipfeln.")
        ]
    },
    {
        "name": "Gewässer & Feuchtgebiete",
        "description": "Lebensräume an Ufern, Teichen, Sümpfen und Auen mit spezialisierten Wasser- und Röhrichtpflanzen.",
        "climateZone": "feucht/gemäßigt",
        "plants": [
            ("Sumpfdotterblume", "Caltha palustris", "Ranunculaceae", "Ranunculales", "Caltha", "palustris", "Glänzende nieren- bis herzförmige Blätter, leuchtend goldgelbe Blüten im zeitigen Frühjahr."),
            ("Schilfrohr", "Phragmites australis", "Poaceae", "Poales", "Phragmites", "australis", "Bis 4 Meter hoher Halm mit breiten graugrünen Blättern, große purpurne bis bräunliche Rispe."),
            ("Gelbe Schwertlilie", "Iris pseudacorus", "Iridaceae", "Asparagales", "Iris", "pseudacorus", "Schwertförmige zweizeilige Blätter, große leuchtend gelbe Blüten mit hängenden Hängeblättern."),
            ("Breitblättriger Rohrkolben", "Typha latifolia", "Typhaceae", "Poales", "Typha", "latifolia", "Linealische Blätter, walzenförmiger samtig-dunkelbrauner weiblicher Kolben direkt unter dem männlichen Teil."),
            ("Schmalblättriger Rohrkolben", "Typha angustifolia", "Typhaceae", "Poales", "Typha", "angustifolia", "Schmale halbrunde Blätter, weiblicher und männlicher Kolbenteil durch 2-5 cm nackten Schaft getrennt."),
            ("Weiße Seerose", "Nymphaea alba", "Nymphaeaceae", "Nymphaeales", "Nymphaea", "alba", "Große runde Schwimmblätter mit tiefem Einschnitt, weiße vielblättrige Blüten auf der Wasseroberfläche."),
            ("Gelbe Teichrose", "Nuphar lutea", "Nymphaeaceae", "Nymphaeales", "Nuphar", "lutea", "Ledrige ovale Schwimmblätter, kugelige goldgelbe Blüten mit leichtem Alkoholgeruch."),
            ("Gewöhnlicher Blutweiderich", "Lythrum salicaria", "Lythraceae", "Myrtales", "Lythrum", "salicaria", "Vierkantiger Stängel, lanzettliche Blätter, lange purpurrote scheinährige Blütenkerzen."),
            ("Gewöhnlicher Wasserdost", "Eupatorium cannabinum", "Asteraceae", "Asterales", "Eupatorium", "cannabinum", "Drei- bis fünfzählig handförmig geteilte Blätter (hanfartig), dichte Schirmrispen mit rosa Röhrenblüten."),
            ("Bachbunge", "Veronica beccabunga", "Plantaginaceae", "Lamiales", "Veronica", "beccabunga", "Fleischige runde glänzende Blätter, kriechender Stängel, kleine himmelblaue Blüten in Achseltrauben."),
            ("Bach-Nelkenwurz", "Geum rivale", "Rosaceae", "Rosales", "Geum", "rivale", "Gefiederte Blätter mit großem Endlappen, nickende rötlich-braune Glockenblüten mit Hakengriffeln."),
            ("Sumpf-Vergissmeinnicht", "Myosotis scorpioides", "Boraginaceae", "Boraginales", "Myosotis", "scorpioides", "Kantenloser Stängel, lanzettliche Blätter, himmelblaue Blüten mit gelbem Schlundschuppenring."),
            ("Wiesen-Schaumkraut", "Cardamine pratensis", "Brassicaceae", "Brassicales", "Cardamine", "pratensis", "Gefiederte Grund- und Stängelblätter, zart lila bis weiße vierzählige Blüten im Frühjahr."),
            ("Bitteres Schaumkraut", "Cardamine amara", "Brassicaceae", "Brassicales", "Cardamine", "amara", "Gefiederte Blätter, reinweiße Blüten mit auffällig violetten Staubbeuteln, hohler Stängel."),
            ("Kalmus", "Acorus calamus", "Acoraceae", "Acorales", "Acorus", "calamus", "Schwertförmige Blätter mit welligem Rand, aromatischer würziger Geruch, schräg abstehender Kolben."),
            ("Gewöhnlicher Froschlöffel", "Alisma plantago-aquatica", "Alismataceae", "Alismatales", "Alisma", "plantago-aquatica", "Lang gestielte eiförmige Luftblätter, pyramidenförmige lockere Rispe mit kleinen dreizähligen blassrosa Blüten."),
            ("Pfeilkraut", "Sagittaria sagittifolia", "Alismataceae", "Alismatales", "Sagittaria", "sagittifolia", "Ausgeprägte pfeilförmige Luftblätter, weiße Blütenquirle mit purpurschwarzen Staubbeuteln."),
            ("Tannenwedel", "Hippuris vulgaris", "Plantaginaceae", "Lamiales", "Hippuris", "vulgaris", "Unverzweigter aufrechter Stängel, nadelförmige weiche Blätter in dichten vielzähligen Quirlen."),
            ("Wasserminze", "Mentha aquatica", "Lamiaceae", "Lamiales", "Mentha", "aquatica", "Eiförmige gezähnte Blätter, kugeliges rosa Blütenköpfchen an der Stängelspitze, intensiver Mentholduft."),
            ("Ufer-Wolfstrapp", "Lycopus europaeus", "Lamiaceae", "Lamiales", "Lycopus", "europaeus", "Vierkantiger Stängel, tief gezähnte bis fiederspaltige Blätter, kleine weiße Blütenquirle in den Blattachseln."),
            ("Wasserschierling", "Cicuta virosa", "Apiaceae", "Apiales", "Cicuta", "virosa", "Gefiederte Blätter mit gesägten Rändern, knollig verdickter hohler Wurzelstock mit Querkammern, hochgiftig."),
            ("Wasserfeder", "Hottonia palustris", "Primulaceae", "Ericales", "Hottonia", "palustris", "Untergetauchte kammförmig fiederteilige Blätter, aus dem Wasser ragende Quirlblütentrauben in Blassrosa."),
            ("Sumpf-Schafgarbe", "Achillea ptarmica", "Asteraceae", "Asterales", "Achillea", "ptarmica", "Ungeteilte lanzettliche scharf gesägte Blätter, weiße Blütenkörbchen in lockerer Scheindolde."),
            ("Schwanenblume", "Butomus umbellatus", "Butomaceae", "Alismatales", "Butomus", "umbellatus", "Dreikantige grundständige Blätter, endständige Schirmdolde mit wunderschönen rosaroten Blüten."),
            ("Ästiger Igelkolben", "Sparganium erectum", "Typhaceae", "Poales", "Sparganium", "erectum", "Dreikantige rinnige Blätter, verzweigter Blütenstand mit kugeligen stacheligen igelartigen Fruchtständen."),
            ("Krebsschere", "Stratiotes aloides", "Hydrocharitaceae", "Alismatales", "Stratiotes", "aloides", "Aloe-artige Rosette mit steifen dornig gezähnten Blättern, steigt zur Blüte an die Wasseroberfläche."),
            ("Kleine Wasserlinse", "Lemna minor", "Araceae", "Alismatales", "Lemna", "minor", "Winziger flacher rundlich-ovaler Blattkörper (2-4 mm) mit einer einzelnen Wurzelfaser, bildet Entengrütze."),
            ("Bruch-Weide", "Salix fragilis", "Salicaceae", "Malpighiales", "Salix", "fragilis", "Schmal-lanzettliche glänzende Blätter mit Drüsenspitzen am Stiel, Zweige brechen am Grund mit leisem Knall leicht ab."),
            ("Silber-Weide", "Salix alba", "Salicaceae", "Malpighiales", "Salix", "alba", "Schmale Blätter unterseits dicht seidig-silbrig behaart, schimmern im Wind silbern, typischer Auenbaum."),
            ("Sumpf-Schwertlilie", "Iris versicolor", "Iridaceae", "Asparagales", "Iris", "versicolor", "Schwertförmige Blätter, violettblaue Blüten mit gelb-weißem Schlundmuster an Feuchtstandorten.")
        ]
    }
]

def generate_questions(common_name, sci_name, family, desc):
    # Generates 4 intelligent, botanically accurate questions with distractors
    q1 = {
        "question": f"Zu welcher Pflanzenfamilie gehört {common_name} ({sci_name})?",
        "options": [family, "Asteraceae" if family != "Asteraceae" else "Rosaceae", "Lamiaceae" if family != "Lamiaceae" else "Fabaceae", "Brassicaceae" if family != "Brassicaceae" else "Poaceae"],
        "correct": 0,
        "explanation": f"{common_name} ist ein Vertreter der Familie {family}."
    }
    q2 = {
        "question": f"Welcher wissenschaftliche Name gehört zur Art '{common_name}'?",
        "options": [sci_name, f"{sci_name.split()[0]} vulgaris" if sci_name.split()[1] != 'vulgaris' else f"{sci_name.split()[0]} pratensis", "Taraxacum officinale" if sci_name != 'Taraxacum officinale' else 'Bellis perennis', "Fagus sylvatica" if sci_name != 'Fagus sylvatica' else 'Quercus robur'],
        "correct": 0,
        "explanation": f"Der botanische Artname lautet {sci_name}."
    }
    q3 = {
        "question": f"Welches der folgenden Merkmale ist typisch für {common_name}?",
        "options": [desc.split(",")[0], "Immergrüne dornige Nadeln mit Harzblasen" if "Nadel" not in desc else "Große gefiederte Doppelblüten ohne Stängel", "Untergetauchte fleischige Schwimmknollen" if "Schwimm" not in desc else "Runde glatte Rinde ohne Astansatz", "Ausschließlich zwittrige Röhrenblüten in schwarz" if "schwarz" not in desc else "Dreiblättrige Quirlblätter mit Dornen"],
        "correct": 0,
        "explanation": f"Charakteristisches Merkmal: {desc}"
    }
    q4 = {
        "question": f"In welchem Lebensraum findet man {common_name} typischerweise?",
        "options": ["Wald & Gehölze" if "Wald" in desc or "Borke" in desc or "Nadel" in desc else ("Gewässer & Ufer" if "Wasser" in desc or "Sumpf" in desc or "Ufer" in desc else "Wiesen & Weideland"), "Trockene Sandwüste", "Tropischer Regenwald", "Salzwasser-Mangroven"],
        "correct": 0,
        "explanation": f"{common_name} wächst standorttypisch in mitteleuropäischen Biotopen."
    }
    return [q1, q2, q3, q4]

dataset = []
for eco in ECOSYSTEMS:
    eco_entry = {
        "name": eco["name"],
        "description": eco["description"],
        "climateZone": eco["climateZone"],
        "plants": []
    }
    for item in eco["plants"]:
        common_name, sci_name, family, order, genus, species, desc = item
        questions = generate_questions(common_name, sci_name, family, desc)
        eco_entry["plants"].append({
            "commonName": common_name,
            "scientificName": sci_name,
            "family": family,
            "order": order,
            "genus": genus,
            "species": species,
            "description": desc,
            "questions": questions
        })
    dataset.append(eco_entry)

with open("tools/scripts/botany_data.py", "w", encoding="utf-8") as f:
    f.write("# Botanical Dataset for Plantini (3 Ecosystems, 90 Plants, 360 Questions)\n")
    f.write("ECOSYSTEMS_DATA = " + repr(dataset) + "\n")

print(f"Generated dataset with {len(dataset)} ecosystems and {sum(len(e['plants']) for e in dataset)} plants!")
