# No Aquilo - Design-Spezifikation

## Technische Basis

Der Mod zielt ausschließlich auf Factorio und Space Age 2.1. Factorio 2.0 wird nicht mehr unterstützt. Die Migration wurde gegen die installierten 2.1.9-Prototypdaten geprüft.

Für No Aquilo relevante Änderungen gegenüber 2.0:

- Rezepte verwenden `categories` statt `category` und `additional_categories`.
- Die kombinierte Kategorie `chemistry-or-cryogenics` existiert nicht mehr. Ersatzrezepte nennen `chemistry` und `cryogenics` explizit.
- Unabhängige Produktausbeuten verwenden `independent_probability` statt `probability`; dies betrifft die 1-%-Lithiumausbeute des Schrottrecyclings.
- Recycling ist ein eigenes, von Space Age benötigtes `recycler`-Modul; Recycling-Grafiken kommen aus `__recycler__`.
- Quality ist nur noch eine empfohlene Space-Age-Abhängigkeit. No Aquilo darf keine Quality-Abhängigkeit voraussetzen.
- `solar-system-edge` wird durch die neue Technologie `stellar-discovery-solar-system-edge` freigeschaltet. No Aquilo behält deren Voraussetzungen `fusion-reactor` und `railgun` bei.

## Ziel

No Aquilo entfernt Aquilo aus der spielbaren Space-Age-Progression, ohne die späte Spielphase abzukürzen oder Inhalte zu verschenken. Spieler sollen Aquilo nicht erforschen, bereisen, als Logistikziel sehen oder als Voraussetzung für spätere Technologien benötigen.

Die ehemalige Aquilo-Rolle wird auf die drei inneren Spezialplaneten verteilt:

| Planet | Rolle in No Aquilo |
| --- | --- |
| Fulgora | Lithium aus Scrap-Verwertung und später Lithium Recovery |
| Vulcanus | Fluorit als feste Fluorquelle |
| Gleba | Spoilage als Grundlage für Ammoniak |

Der zentrale Fortschrittsvertrag lautet: Nach der Industrialisierung von Fulgora, Vulcanus und Gleba ist die Cryogenic- und Endgame-Kette vollständig ohne Aquilo erreichbar.

## Scope

Die erste Version ist für neue Space-Age-Spiele ausgelegt. Bestehende Saves, in denen Aquilo bereits entdeckt oder besucht wurde, sind kein Migrationsziel.

Aquilo muss nicht physisch aus `data.raw.planet` gelöscht werden. Entscheidend ist, dass Aquilo aus der normalen Spielerführung verschwindet:

- keine Forschung,
- keine Route,
- kein Unlock,
- kein Importziel,
- kein Rezept- oder Factoriopedia-Hinweis,
- keine notwendige `surface_conditions`-Bindung.

Der interne Planet-Prototyp bleibt für Space-Age-Datenreferenzen erhalten, wird aber ausdrücklich aus der Factoriopedia verborgen. Dasselbe gilt für den intern erhaltenen `ice-platform`-Tile-Prototyp.

Kompatibilität mit anderen Space-Age-Overhaul-Mods ist kein Ziel der ersten Version.

## Progressionsübersicht

Die neue Progression ersetzt die ursprüngliche Aquilo-Stufe durch eine kombinierte Drei-Planeten-Hürde:

1. Spieler erschließen Fulgora, Vulcanus und Gleba.
2. Die Ersatzforschungen `ammonia-synthesis`, `fluorine-processing` und `lithium-processing` werden mit den drei inneren Planet-Science-Packs erforscht.
3. `cryogenic-plant` wird erst nach diesen drei Ersatzforschungen erreichbar.
4. Cryogenic Science, Quantum Processors, Fusion, Foundation, Railgun und Promethium bleiben erreichbar.
5. Der Weg zum `solar-system-edge` führt direkt von Fulgora aus weiter.

## Gemeinsame Science Packs

Die folgenden Technologien verwenden dieselbe Science-Pack-Familie:

- `ammonia-synthesis`
- `fluorine-processing`
- `lithium-processing`
- `lithium-recovery`

Science Packs:

| Enthalten | Ausgeschlossen |
| --- | --- |
| `automation-science-pack` | `military-science-pack` |
| `logistic-science-pack` | `cryogenic-science-pack` |
| `chemical-science-pack` | `promethium-science-pack` |
| `production-science-pack` |  |
| `utility-science-pack` |  |
| `space-science-pack` |  |
| `metallurgic-science-pack` |  |
| `agricultural-science-pack` |  |
| `electromagnetic-science-pack` |  |

Damit starten die Ersatztechnologien erst, wenn Vulcanus, Gleba und Fulgora sinnvoll genutzt werden.

## Technologien

| Technologie | Kosten | Zeit | Voraussetzungen | Unlocks / Änderung |
| --- | ---: | ---: | --- | --- |
| `ammonia-synthesis` | 500 | 60 | `metallurgic-science-pack`, `agricultural-science-pack`, `electromagnetic-science-pack` | `ammonia-synthesis` |
| `fluorine-processing` | 500 | 60 | `metallurgic-science-pack`, `agricultural-science-pack`, `electromagnetic-science-pack` | `fluorine-extraction` |
| `lithium-processing` | 500 | 60 | `planet-discovery-fulgora` | `lithium-plate`, sichtbares lithiumhaltiges Scrap-Recycling |
| `lithium-recovery` | 2000 | 60 | `lithium-processing`, `ammonia-synthesis`, `fluorine-processing` | `lithium-recovery` |
| `cryogenic-plant` | unverändert, sofern der Trigger sauber bleibt | unverändert | `lithium-processing`, `ammonia-synthesis`, `fluorine-processing` | `cryogenic-plant`, `fluoroketone`, `fluoroketone-cooling` |

`lithium-processing` verliert den ursprünglichen 2.1-Research-Trigger `mine-entity` für `lithium-iceberg-big` und `lithium-iceberg-huge`. Der Trigger ist ohne Aquilo unmöglich und wird durch normale Forschungskosten ersetzt.

`cryogenic-plant` darf den bestehenden Trigger `craft-item = lithium-plate` behalten, wenn die neuen Voraussetzungen zuverlässig verhindern, dass der Trigger vor der Ersatzkette greift. Falls das im Spiel unklar wirkt, wird `cryogenic-plant` später ebenfalls auf normale Forschung umgestellt.

## Rezepte

| Rezept | Maschine | Input | Output | Zeit |
| --- | --- | --- | --- | ---: |
| `ammonia-synthesis` | Chemical Plant (`chemistry`), Cryogenic Plant (`cryogenics`) | 2 Spoilage, 2 Iron Ore, 100 Steam | 50 Ammonia | 2 s |
| `fluorine-extraction` | Chemical Plant (`chemistry`), Cryogenic Plant (`cryogenics`) | 10 Fluorit, 100 Sulfuric Acid | 100 Fluorine | 4 s |
| `scrap-lithium-recycling` | Recycler / Recycling-Kategorie | 1 Scrap | normale Scrap-Ergebnisse plus 1% Lithium | wie `scrap-recycling` |
| `lithium-recovery` | Chemical Plant (`chemistry`), Cryogenic Plant (`cryogenics`) | 50 Scrap, 50 Petroleum Gas | 10 Lithium | 10 s |

`scrap-lithium-recycling` ist ein eigenständiges sichtbares Rezept im UI. Das frühe originale `scrap-recycling` bleibt unverändert, damit Lithium vor `lithium-processing` nicht in Rezeptansichten oder Factoriopedia sichtbar wird.

`lithium-recovery` ist bewusst deutlich stärker und planbarer als der 1%-Drop. Der hohe Forschungspreis von 2000 und die drei Voraussetzungen halten es hinter der vollständigen Ersatzkette.

## Fluorit

Vulcanus erhält Fluorit als neue feste Fluorquelle.

| Eigenschaft | Wert |
| --- | --- |
| Prototype-Name | `fluorite` |
| Deutscher Name | Fluorit |
| Typ | Ore |
| Stack Size | 50 |
| Rocket Capacity | 500 |
| Item Weight | `2 * kg` |
| Icon-Basis | `calcite` |
| Farbgebung | an `uranium-ore` orientiert |

Die Raketenkapazität wird in Factorio 2.1 über das Item-Gewicht modelliert. `2 * kg` entspricht typischen Erzen wie Iron Ore und ergibt bei Stack Size 50 die gewünschte Transportgröße.

Fluorit soll auf Vulcanus seltener als Calcite sein. Es ist ein Endgame-Gate und soll zuverlässig automatisierbar, aber nicht beiläufig verfügbar sein.

Autoplace-Richtung:

- kleine bis mittlere Patches,
- bevorzugt in vulkanischen Zonen,
- Abbau mit normalen Mining Drills,
- keine neue Flüssigkeitsquelle wie der originale `fluorine-vent`.

## Aquilo entfernen

Aquilo wird aus der normalen Progression entfernt.

### Technologien und Unlocks

- `planet-discovery-aquilo` wird entfernt.
- Der Unlock-Effekt `space_location = "aquilo"` wird entfernt.
- Alle Aquilo-Recipe-Unlocks aus `planet-discovery-aquilo` werden entfernt.

### Space Connections

Entfernen:

- `gleba-aquilo`
- `fulgora-aquilo`
- `aquilo-solar-system-edge`

Beibehalten:

- `solar-system-edge-shattered-planet`

Neu hinzufügen:

| Verbindung | From | To | Length | Asteroiden |
| --- | --- | --- | ---: | --- |
| `fulgora-solar-system-edge` | `fulgora` | `solar-system-edge` | 150000 | Aquilo-zu-Edge-Profil wiederverwenden |

Diese Route ersetzt den Aquilo-Zwischenstopp durch eine längere Plattformprüfung.

### Entfernte Aquilo-Progression

Die folgenden Prototypen dürfen in der normalen Progression nicht sichtbar oder erreichbar sein:

- `ammoniacal-solution-separation`
- `solid-fuel-from-ammonia`
- `ammonia-rocket-fuel`
- `ice-platform`
- `lithium-brine`
- `fluorine-vent`, sofern keine neue Vulcanus-Verwendung definiert wird
- Aquilo-only Map- und Resource-Pfade, sofern sie Spielerführung oder UI-Reste erzeugen

Wenn hartes Löschen interne Referenzen destabilisiert, darf ein Prototype intern versteckt bleiben. Spieler dürfen ihn dann aber nicht über Forschung, Rezeptlisten, Factoriopedia, Logistik oder normale Karten-/Routenmechaniken finden.

## Surface Conditions

Aquilo-only `surface_conditions` werden entfernt. Bedingungen anderer Planeten und Space-only-Bedingungen bleiben erhalten.

| Entfernen | Beibehalten |
| --- | --- |
| Aquilo-only Druck-/Oberflächenbedingungen, die erforderliche Endgame-Rezepte blockieren | Vulcanus-Bedingungen wie `pressure = 4000` |
| Aquilo-only Bedingungen auf Cryogenic Chain, Fusion, Foundation, Railgun und verwandten Rezepten | Gleba-Bedingungen wie `pressure = 2000` |
| Aquilo-only Bedingungen auf relevanten Gegenständen, Entitäten oder Rezepten | Fulgora-Bedingungen wie `magnetic-field = 99` |
|  | Space-only-Bedingungen wie `gravity = 0` |

Der Patch darf nicht pauschal alle `surface_conditions` entfernen. Jede entfernte Bedingung muss an eine konkrete Aquilo-Abhängigkeit gebunden sein.

## Default Import Locations

Alle normalen Gegenstände mit `default_import_location = "aquilo"` werden neu zugeordnet.

| Ziel | Gegenstände |
| --- | --- |
| `fulgora` | `cryogenic-science-pack`, `promethium-science-pack`, `railgun-turret`, `lithium`, `lithium-plate`, `quantum-processor`, `fusion-power-cell`, `fusion-reactor`, `fusion-generator`, `cryogenic-plant`, `fluoroketone-cold-barrel`, `fluoroketone-hot-barrel` |
| `vulcanus` | `foundation` |
| `gleba` | bewusst keine Gegenstände |

`ice-platform` bekommt keine neue Import Location, weil es aus der normalen Progression verschwindet.

`promethium-science-pack` bleibt Space-only herstellbar. Die Fulgora-Importzuordnung ist nur eine UI-/Logistik-Konvention und darf die `gravity = 0`-Bedingung nicht entfernen.

Die Fluoroketon-Barrels sind automatisch erzeugte Items. Sie müssen trotzdem explizit auf Fulgora umgestellt werden, damit keine Aquilo-Logistikempfehlung über erzeugte Barrel-Prototypen übrig bleibt.

## Cryogenic Chain

Diese Kette muss ohne Aquilo erreichbar bleiben:

- `cryogenic-plant`
- `fluoroketone`
- `fluoroketone-cooling`
- `cryogenic-science-pack`
- `quantum-processor`
- `fusion-power-cell`
- `fusion-reactor`
- `fusion-generator`
- `fusion-reactor-equipment`
- `railgun`
- `railgun-turret`
- `foundation`
- `captive-biter-spawner`
- `promethium-science-pack`

Recipe-Kategorien sollen möglichst original bleiben. Chemical Plant, Cryogenic Plant und Electromagnetic Plant behalten dadurch ihre Rollen.

## UI, Locale und Factoriopedia

Spielerführung muss No Aquilo konsistent darstellen.

Zu prüfen und anzupassen:

- Technology Tree,
- Starmap,
- Space route tooltips,
- Factoriopedia-Einträge,
- Tips and Tricks,
- Simulationen,
- Rezeptbeschreibungen,
- Item- und Entity-Locale,
- Default Import Location-Anzeigen.

Es darf keinen normalen Hinweis geben, der Spieler zu Aquilo, `lithium-brine`, `ammoniacal-solution`, `ice-platform` oder Aquilo-Routen führt.

## Implementierungsstruktur

Die erste Implementierung sollte data-stage-only bleiben. Runtime-Code ist nur nötig, wenn eine konkrete Mechanik ihn erfordert.

Vorgeschlagene Struktur:

| Datei | Zweck |
| --- | --- |
| `data.lua` | neue Prototypen: Fluorit, Rezepte, Technologien |
| `data-updates.lua` | frühe Patches an bestehenden Space-Age-Prototypen |
| `data-final-fixes.lua` | finale Konsistenzprüfung und späte Kompatibilitätspatches |
| `prototypes/fluorite.lua` | Fluorit-Item, Resource und Autoplace |
| `prototypes/recipes.lua` | Ammonia Synthesis, Fluorine Extraction, Lithium-Rezepte |
| `prototypes/technology.lua` | neue und geänderte Technologien |
| `prototypes/no-aquilo-patches.lua` | Aquilo-Gates, Surface Conditions, Default Imports, Routes |
| `locale/en/no-aquilo.cfg` | englische Locale |
| `locale/de/no-aquilo.cfg` | deutsche Locale |

Empfohlene Helper:

- `remove_technology(technology_name)`
- `remove_technology_effect(technology_name, predicate)`
- `add_unlock(technology_name, recipe_name)`
- `replace_prerequisites(technology_name, prerequisites)`
- `set_science_unit(technology_name, count, ingredients, time)`
- `remove_research_trigger(technology_name)`
- `remove_aquilo_surface_conditions(prototype)`
- `set_default_import_location(item_name, location_or_nil)`
- `remove_space_connection(connection_name)`

Pflicht-Prototypen sollen bei fehlenden Namen klar fehlschlagen. Stille No-ops sind bei Progression-Patches gefährlich.

## Balance-Stellschrauben

Die erste spielbare Version sollte mit den oben definierten Werten starten. Danach sind diese Stellschrauben relevant:

| Bereich | Stellschrauben |
| --- | --- |
| Lithium zu leicht | `lithium-recovery`-Kosten, Petroleum-Gas-Bedarf, Crafting Time, Scrap-Bedarf |
| Lithium zu grindlastig | `lithium-recovery` früher günstiger machen oder 1%-Recycling-Ausbeute erhöhen |
| Fluorit zu häufig | Autoplace-Frequenz, Patchgröße, Richness |
| Fluorit zu selten | Startgebietsnähe auf Vulcanus, Patchgröße, Richness |
| Edge-Route zu leicht | Asteroidenprofil, Länge, Spawn-Dichte |
| Edge-Route zu hart | Länge oder große Asteroiden reduzieren |

Die wichtigsten Playtest-Messpunkte sind:

- Zeit bis zur ersten Cryogenic Plant,
- Zeit bis zum ersten stabilen Quantum Processor-Fluss,
- Scrap-Verbrauch pro Fusion-Setup,
- Fluorit-Förderrate pro Vulcanus-Basis,
- Plattformverluste auf `fulgora-solar-system-edge`.

## Nicht-Ziele

- Aquilo nur verstecken, aber intern weiter als Reiseziel verlangen.
- `planet-discovery-aquilo` behalten.
- Alle `surface_conditions` global entfernen.
- Früh sichtbares Lithium im originalen `scrap-recycling`.
- `lithium-brine` als normalen Pfad behalten.
- `ice-platform` für andere Oberflächen wiederverwenden.
- Promethium oder Quantum Processors vor Cryogenic Science freischalten.

## Akzeptanzkriterien

Eine erste spielbare Version gilt als akzeptiert, wenn alle folgenden Punkte erfüllt sind:

- Aquilo ist nicht erforschbar, bereisbar oder als logistisches Ziel sichtbar.
- Der interne Aquilo-Planet und der `ice-platform`-Tile sind nicht in der Factoriopedia sichtbar.
- `planet-discovery-aquilo` ist entfernt.
- Kein erforderlicher Fortschritt verweist auf Aquilo.
- `gleba-aquilo`, `fulgora-aquilo` und `aquilo-solar-system-edge` existieren nicht mehr als normale Routen.
- `fulgora-solar-system-edge` existiert mit `length = 150000` und dem Aquilo-zu-Edge-Asteroidenprofil.
- `stellar-discovery-solar-system-edge` setzt `fusion-reactor` und `railgun` voraus und schaltet `solar-system-edge` frei.
- Keine normale Progression nutzt `default_import_location = "aquilo"`.
- `ice-platform`, `lithium-brine` und `ammoniacal-solution-separation` sind aus der normalen Progression entfernt.
- `solid-fuel-from-ammonia` und `ammonia-rocket-fuel` sind aus der normalen Progression entfernt.
- `rocket-fuel-productivity` enthält keinen Effekt für das entfernte Rezept `ammonia-rocket-fuel`.
- `lithium-processing` hat Forschungskosten 500, Time 60 und die gemeinsame Science-Pack-Familie.
- Rohes Lithium ist erst nach `lithium-processing` sichtbar.
- Lithiumhaltiges Scrap-Recycling erscheint nach `lithium-processing` als eigenes UI-Rezept.
- `lithium-recovery` kostet 2000, Time 60, setzt `lithium-processing`, `ammonia-synthesis` und `fluorine-processing` voraus und produziert 10 Lithium aus 50 Scrap und 50 Petroleum Gas in 10 Sekunden.
- `ammonia-synthesis` produziert 50 Ammonia aus 2 Spoilage, 2 Iron Ore und 100 Steam in 2 Sekunden.
- `fluorine-extraction` produziert 100 Fluorine aus 10 Fluorit und 100 Sulfuric Acid in 4 Sekunden.
- Fluorit nutzt `calcite` als Icon-Basis und ist farblich an `uranium-ore` angelehnt.
- Cryogenic Science ist ohne Aquilo erreichbar.
- Quantum Processor, Fusion Reactor, Fusion Generator, Foundation, Railgun und Promethium Science sind ohne Aquilo erreichbar.
- Fulgora, Vulcanus und Gleba bleiben alle relevant.
- Space-only Bedingungen bleiben erhalten.
- Die Mod lädt ohne Prototype-Fehler.
- Ein neues Testspiel kann von den drei inneren Planet-Science-Packs bis zur Freischaltung des Solar System Edge fortschreiten.
