# Stabiliteit

Deze *repository* bevat enkele stabiliteitsberekeningen voor een woning in renovatie. Zo worden er enkele stalen liggers berekend, alsook wordt de draagkracht van de funderingen aan een controle onderworpen. Het huis is gebouwd in 1956 en staat op een zandhoudende leembodem. Op ca. 1.00m diepte wordt een leemhouden zand aangesneden. Op sonderingen in de buurt valt op te maken dat hieronder de draagkracht van de bodem enkel toeneemt. Een zandig pakket wordt op grotere diepte aangesneden.

## Lastendaling

De lasten worden afgeleid uit de lastendaling in *Excel*. De krachten uit de lastendaling worden gebruik in de stabiliteitsberekeningen. Geen interactieve link is opgesteld tussen beide. 

## Berekening liggers

In de *notebooks* `basis.jl` worden de interne krachten berekend voor een verdeelde belasting en een puntbelasting, dit voor toepassing tussen/op een willekeurige abscis $a$ en/of $b$. Mits toepassen van het *superpositie beginsel* kunnen de afzonderlijke profielen berekend worden.

De berekeningen worden opgesteld in *Julia* onder het motto *writes like python, runs like C*. 

### Profiel 1

Profiel 1 bevind zich ter hoogte van de keuken. Het profiel is isostatisch opgelegd. De steunpunten bevinden zich op de uiteinden van de ligger. Het profiel dient de bovenliggende vloer opgebouwd uit potten en balken op te vangen. De lengte bedraagt 3,995m. 

Ga naar [Berekening Profiel 1](./pages/profiel_1.html)

### Profiel 2
 
Profiel 2 bevind zich ter hoogte van de keuken, zijde living. Het profiel is isostatisch opgelegd, maar kraagt gedeeltelijk uit, dit midden in de woning. De steunpunten bevinden zich op het uiteinde van de ligger naar de tuin toe, en binnen de ligger ter hoogte van de living. Het profiel dient de bovenliggende vloer opgebouwd uit potten en balken op te vangen. De lengte bedraagt X,XXXm. 

Ga naar [Berekening Profiel 2](./pages/profiel_2.html)

### Profiel 3

Profiel 3 bevind zich tussen de nieuwe kolom boven de kelder en het nieuw keldergat. Het profiel is hyperstatisch opgelegd. De steunpunten bevinden zich op de uiteinden van de ligger en ter hoogte van de nieuwe muur tussen de wasruimte en de keuken. Het profiel dient in theorie geen lasten van de bovenliggende vloer, zijnde de vloer van de badkamer, op te nemen. Veiligheidshalve nemen we toch een deel van de belasting van deze vloer op. De bovenliggende muur dient door het profiel opgenomen te worden. 

Ga naar [Berekening Profiel 3](./pages/profiel_3.html)

### Profiel 4

Profiel 4 bevind zich ter hoogte van de keuken. Het profiel is isostatisch opgelegd. De steunpunten bevinden zich op de uiteinden van de ligger. Het profiel dient de bovenliggende vloer opgebouwd uit potten en balken op te vangen. De lengte bedraagt 3,995m. 

Ga naar [Berekening Profiel 4](./pages/profiel_4.html)

### Profiel 5

Profiel 1 bevind zich ter hoogte van de keuken. Het profiel is isostatisch opgelegd. De steunpunten bevinden zich op de uiteinden van de ligger. Het profiel dient de bovenliggende vloer opgebouwd uit potten en balken op te vangen. De lengte bedraagt 3,995m. 

Ga naar [Berekening Profiel 1](./pages/profiel_1.html)

## Berekening kolommen

