# Stabiliteit

Deze *repository* bevat enkele stabiliteitsberekeningen voor een woning in renovatie. Zo worden er enkele stalen liggers berekend, alsook wordt de draagkracht van de funderingen aan een controle onderworpen. Het huis is gebouwd in 1956 en staat op een zandhoudende leembodem. Op ca. 1.00m diepte wordt een leemhouden zand aangesneden. Op sonderingen in de buurt valt op te maken dat hieronder de draagkracht van de bodem enkel toeneemt. Een zandig pakket wordt op grotere diepte aangesneden.

## Lastendaling

De lasten worden afgeleid uit de lastendaling in *Excel*. De krachten uit de lastendaling worden gebruik in de stabiliteitsberekeningen. Geen interactieve link is opgesteld tussen beide. 

## Randvoorwaardes

De staalkwaliteit is **S235**. Wel ben ik van het idee eens het prijsverschil te vragen voor een kolom uit S355 en S235. Immers zou ik voor de kolommen dan eventueel hanteren voor de hogere sterkteklasse, ondankt dat eigenlijk het falen van een kolom dikwijls afhangt van tweede orde effecten en deze door een andere staalklasse niet wijzigen gezien de vervormingen gelijk blijven (zelfde *E-modulus*). 

## Berekening profielen/liggers

In de *notebooks* `basis.jl` worden de interne krachten berekend voor een verdeelde belasting en een puntbelasting, dit voor toepassing tussen/op een willekeurige abscis $a$ en/of $b$. Mits toepassen van het *superpositie beginsel* kunnen de afzonderlijke profielen berekend worden.

De berekeningen worden opgesteld in *Julia* onder het motto *writes like python, runs like C*. 

### Profiel 1 - HEB220 (S235) - L = ca. 3,995m

Profiel 1 bevind zich ter hoogte van de keuken. Het profiel is isostatisch opgelegd. De steunpunten bevinden zich op de uiteinden van de ligger. Het profiel dient de bovenliggende vloer opgebouwd uit potten en balken op te vangen. De lengte bedraagt ca. 3,995m. Een vervorming van ca. 7mm treedt op, aanvaardbaar gezien de grenswaarde op 8mm ligt. Bij voorkeur heeft het profiel dus een zeeg zodat deze 7mm gecompenseerd wordt. Zeker als het naastgelegen profiel een ander zakking heeft. De verbinding met profiel 5 is met een zuivere afschuifverbinding met bouten. Er wordt enkel op het lijf gerekend voor de overdracht van deze dwarskracht. Het lijf moet hier nog bijkomend op gecontroleerd worden.

Ga naar [Berekening Profiel 1](./pages/profiel_1.html)

### Profiel 2 - HEB220 (S235) - L = ca. 5,400m
 
Profiel 2 bevind zich ter hoogte van de keuken, zijde living. Het profiel is isostatisch opgelegd, maar kraagt gedeeltelijk uit, dit midden in de woning. De steunpunten bevinden zich op het uiteinde van de ligger naar de tuin toe, en binnen de ligger ter hoogte van de living. Het profiel dient de bovenliggende vloer opgebouwd uit potten en balken op te vangen. De lengte bedraagt ca 5,40m waarbij ongeveer 1,28m in uitkraging zit. De doorbuiging van het profiel wordt ingeschat op 6,0mm. Dit is 1,0mm minder dan profiel 1. Gelukkig komt deze vervorming ongeveer bij beide voor op abscis 2,0m.  

Ga naar [Berekening Profiel 2](./pages/profiel_2.html)

### Profiel 3 - IPE180 (S235) - L = ca. 3,535m

Profiel 3 bevind zich tussen de nieuwe kolom boven de kelder en het nieuw keldergat. Het profiel is hyperstatisch opgelegd. De steunpunten bevinden zich op de uiteinden van de ligger en ter hoogte van de nieuwe muur tussen de wasruimte en de keuken. Het profiel dient in theorie geen lasten van de bovenliggende vloer, zijnde de vloer van de badkamer, op te nemen. Veiligheidshalve nemen we toch een deel van de belasting van deze vloer op. De bovenliggende muur dient door het profiel opgenomen te worden. 

Ga naar [Berekening Profiel 3](./pages/profiel_3.html)

### Profiel 4 - Betonnen balk OF IPE180 (S235) - L = ca. 1,80m

Profiel 4, een eenvoudig opgelegde ligger tussen de traphal en de inkomhal. Het profiel ondersteunt de vloer van de traphal (een betonplaat) en een deel van een niet-dragende wand. De balk zouden we kunnen opleggen in een betonslof die wordt gemaakt in de dragende muur. Deze moet er sowieso komen gezien het metselwerk uit assesteen een heel geringe draagkracht heeft (4 MPa max). 

Ga naar [Berekening Profiel 4](./pages/profiel_4.html)

### Profiel 5 - HEB220 (S235) - L = ca. 8,050m

Profiel 5 is een hyperstatische ligger die over de volledige breedte van de woning reikt. Het profiel hoort in theorie de vloer van de badkamer en de kamer niet te ondersteunen. Wel wordt er een deel van het dak afgedragen op deze muur. Het profiel wordt aan de zijde van de buur ondersteund door een bestaande muur. Op het knooppunt tussen de liggers die de verdiepingsvloer dragen, profiel 1 & 2, komt een kolom te staan. Rechts wordt het profiel nog door 2 muren ondersteund. 

Ga naar [Berekening Profiel 5](./pages/profiel_5.html)

## Berekening kolommen

Er worden 3 kolommen voorzien in de woning. De krachtsafdracht of eerder resulterende krachten worden berekend onder de berekening van de liggers/profielen, gezien deze krachten afdragen naar de kolommen.

### Kolom 1 - SHS 140/6.3 (S235) - L = ca. 2,900m

Kolom 1 wordt geplaatst ter ondersteuning van de profielen 1 & 2, dit op de hoek van de kelderverdieping. Om te voorkomen dat de hoek van de kelder gaat uischeuren worden een uitbreiding van de fundering er voorzien. Ook zit net op de locatie waar we de kolom willen afzetten een buis, de voerbuis van de voormalige afvoer van de stookolieketel naar de schoorsteen. Deze opening moet gedicht worden. De hoogte van de kolom wordt bepaald uit de verdiepingshoogte (2,700m) waarvan we de profiel hoogte aftrekken van profiel 1 & 2 (HEB220 = 0,220m) en de uitgraving bij optellen die we tot op heden op 0,380m inschatten. 

Ga naar [Berekening Kolom 1](./pages/kolom_1.html)

### Kolom 2 - SHS 90/4 (S235) - L = ca. 2,600m

Kolom 2 komt op de rand van de kelder te staan. Vooralleer deze kolom geplaatst kan worden is een aanpassing van de kelder nodig. De opening naar de kelder wordt gedeeltelijk gedicht. De kolom komt te staan op de kruising van de nieuwe wand tussen de wasplaats en de keuken en de bestaande scheiding tussen de hal en de bestaande keuken. 

Ga naar [Berekening Kolom 2](./pages/kolom_2.html)

### Kolom 3 - SHS 140/5 (S235) -  L = ca. 2,900m

Ter hoogte van deze kolom komen de profieln 1, 2 en 5 samen. De profielen 1 & 2 worden d.m.v. een boutverbinding vast gemaakt aan de ligger die opzich steunt op de kolom.  

Ga naar [Berekening Kolom 3](./pages/kolom_3.html)

## Installatie

Installeer zowel `Pluto.jl` als `SQLite.jl`
