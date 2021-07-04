# Stabiliteit

Deze *repository* bevat enkele stabiliteitsberekeningen voor een woning in renovatie. Zo worden er enkele stalen liggers berekend, alsook wordt de draagkracht van de funderingen aan een controle onderworpen. Het huis is gebouwd in 1956 en staat op een zandhoudende leembodem. Op ca. 1.00m diepte wordt een leemhouden zand aangesneden. Op sonderingen in de buurt valt op te maken dat hieronder de draagkracht van de bodem enkel toeneemt. Een zandig pakket wordt op grotere diepte aangesneden.

## Berekening liggers

In de *notebooks* `basis.jl` worden de interne krachten berekend voor een verdeelde belasting en een puntbelasting, dit voor toepassing tussen/op een willekeurige abscis $a$ en/of $b$. Mits toepassen van het *superpositie beginsel* kunnen de afzonderlijke profielen berekend worden.

De berekeningen worden opgesteld in *Julia* onder het motto *writes like python, runs like C*. 

### Lastendaling

 De lasten worden afgeleid uit de lastendaling in *Excel*. De krachten uit de lastendaling worden gebruik in de stabiliteitsberekeningen. Geen interactieve link is opgesteld tussen beide. 

 ### Profiel 1

 Profiel 1 bevind zich ter hoogte van de keuken. Het profiel is isostatisch opgelegd. De steunpunten bevinden zich op de uiteinden van de ligger. Het profiel dient de bovenliggende vloer opgebouwd uit potten en balken op te vangen. De lengte bedraagt 3,995m. 

Ga naar [Berekening Profiel 1](./pages/profiel_1.html)

 ### Profiel 2
 
 

