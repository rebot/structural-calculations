### A Pluto.jl notebook ###
# v0.15.0

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 992f5882-98c6-47e4-810c-81293a396c75
using PlutoUI, ImageView, Images, Conda, PyCall, SymPy, Roots, Plots, HTTP, JSON, Luxor, DotEnv, SQLite, DataFrames, UUIDs, Underscores

# ╔═╡ d46d3ca7-d893-46c1-9ee7-1c88c9219a9e
situatieschets = load("./assets/img/profiel_5.jpg")

# ╔═╡ ece68d5e-1cb3-44e7-8c74-ca910d293ce9
PlutoUI.TableOfContents()

# ╔═╡ 2a3d44ad-9ec2-4c21-8825-dbafb127f727
md"## Indeling
De krachtsafdracht is bepaald voor volgende indeling. In de lastendaling zijn de resulterende belasting begroot ter hoogte van de bovenzijde van de muren van het gelijkvloers. Op onderstaande figuur wordt een onderschijdt gemaakt tussen muren met een **dragende functie** (**rood**)  en deze met een **niet dragende functie** (**geel**)."

# ╔═╡ c6f5a862-cae1-4e9c-a905-72a4122c11a7
md"""
!!! danger "Controleer de lastendaling"
	Alvorens het rekenblad verder aan te vullen, is het belangrijk dat met de correcte uitgangspunten gewerkt wordt. Controleer aldus je resulterende krachten. Bekijk in de lastendaling of de **nuttige last** van $200 kN/m^2$ werd meegenomen, alsook de sneeuwlast en in welke situatie (*oud* of *nieuw*) de lasten zijn doorgerekend.
"""

# ╔═╡ 6a04789a-c42a-4ac9-8d05-ee20442ad60d
load("./assets/img/indeling.jpg")

# ╔═╡ 31851342-e653-45c2-8df6-223593a7f942
md"## Probleemstelling: Hyperstatische ligger met 1 tussensteunpunt
Hyperstatische ligger met 1 tussensteunpunt, 2 variabele lijnlasten en 1 puntlast. De puntbelasting is afkomstig van **profiel 1** en **profiel 2**, het samenstel uit hun reactiekrachten ter hoogte van dit steunpunt. Uit de berekening moet blijken dat de kracht direct wordt opgenomen door het steunpunt indien het zich $\infty$ stijf gedraagd. In realiteit heeft het steunpunt een axiale stijfheid, deze wordt becijferd en meegenomen in de berekening."

# ╔═╡ 001ddb8b-3a71-48f8-adcc-a957741d57b1
md"""
!!! info "Veerstijfheid van het steunpunt"
	Om enige veiligheid in de berekening mee te nemen, wordt het tussensteunpunt als een veer gemodelleerd, hierbij is de volgende wet van kracht: $F = k\cdot v$ waarbij $k$ voor de veerconstante staat, die op zich gelijk is aan $k = \text{EA}/L$, de axiale stijfheid van de ondersteunende kolom. Een vork van stijfheden wordt toegepast in de berekening, waarbij de axiale stijfheid wordt vermenigvuldigd met $\left[1/\sqrt{2}; 1; \infty\right]$.
"""

# ╔═╡ 4ce3251e-f45c-4546-81b8-2e08d4ec9964
naam = "Profiel 5"

# ╔═╡ a81fbf3e-f5c7-41c7-a71e-68f8a9589b45
md"Naam van het profiel; $\text{naam}$ = $naam"

# ╔═╡ ab13bfac-70c7-4b36-ba3f-988a96555af5
ligger = (
	naam = "HE 220 B",
	kwaliteit = "S235"
)

# ╔═╡ ba610d7b-89bf-4ed7-b4b5-4753e9ebc28d
kolom = (
	naam = "SHS 120/6.3",
	kwaliteit = "S235"
)

# ╔═╡ 542f69ac-77c5-47d7-be6c-94ba82a50ef7
md"""
!!! danger "Opmerking"
	Bij de controle in **UGT** wordt de momentweerstand niet verminderd in functie van de dwarskracht. Er wordt op toegezien dat de `Check 4` de waarde van $0.50$ niet overschrijdt. Indien de *Unity Check* groter is, dan grijpen we terug naar NBN EN 1993 om een aangepaste controle uit te voeren.
"""

# ╔═╡ 8f910bf3-5227-4113-9476-6136194a5e60
md"### Beschrijving belastingsschema
Definiëer de randvoorwaarden of *Boundary Conditions* $(\text{BC})$. Voor een **verdeelde belasting** geef je de parameters $a$, $b$, $L$ en $p$ in waarbij een *positieve* waarde van $p$ een neerwaartse belasting is. Voor een **puntbelasting** geef je de parameters $a$, $L$ en $p$ in. Ook de stijfheid $\text{EI}$."

# ╔═╡ c4df4b92-a3c6-43bd-a594-9d1f8c76015f
md"""
In het desbetreffende geval waarbij er **twee verdeelde belastingen** aangrijpen naast elkaar en een puntlast ter hoogte van het steunpunt, herleidt het aantal paramaters zich tot $a$, $x_{steun}$, $L$, $p_1$, $p_2$ en $F$. De ondersteuning ter hoogte van het tussensteunpunt wordt vervangen door een kracht $R_3$, een kracht die afhankelijk is van de vervorming ter hoogte van het steunpunt $v_{xsteun}$. Mits het opleggen van een bijkomende kinematische randvoorwaarde, dat de vervorming er ter hoogte van dit punt gelijk moet zijn aan de verhouding tussen de te berekenen kracht $R_3$ en de axiale stijfheid, kan een oplossing bekomen worden voor het belastingsschema.

$R_3 = \dfrac{\text{EA}}{L}\ v(x_{steun}) \longrightarrow v(x_{steun}) = \dfrac{L}{\text{EA}}\ R_3$
"""

# ╔═╡ ddeaf6b6-5e91-46fa-adf8-026bf6933dee
@drawsvg begin
	sethue("black")
	endpnts = (-225, 0), (225, 0)
	pnt_a = Point(-45, 0)
	pnt_x = Point(0, 0)
	pnts = Point.(endpnts)
	@layer (
		fontsize(20);
		poly(pnts, :stroke);
		circle.(pnts, 4, :fill);
		Luxor.label.(["1", "2"], [:NW, :NE], pnts, offset=15)
	)
	@layer (
		# Verdeelde last 1
		fontsize(16);
		Luxor.translate(0, -50);
		len_1 = distance(pnts[1], pnt_a);
		for i = 0:fld(len_1, 15)
			Luxor.arrow(pnts[1] + (15 * i, 0), pnts[1] + (15 * i, 45));
		end;
		poly((pnts[1], pnt_a), :stroke);
		Luxor.label("p₁", :N, midpoint(pnts[1], pnt_a), offset=15);
	)
	@layer (
		# Verdeelde last 2
		fontsize(16);
		Luxor.translate(0, -30);
		len_2 = distance(pnt_a, pnts[2]);
		for i = 0:fld(len_2, 15)
			Luxor.arrow(pnt_a + (15 * i, 0), pnt_a + (15 * i, 25));
		end;
		poly((pnt_a, pnts[2]), :stroke);
		Luxor.label("p₂", :N, midpoint(pnt_a, pnts[2]), offset=15);
	)
	@layer (
		# Tussensteunpunt
		fontsize(16);
		Luxor.translate(0, 10);
		poly((pnt_x , pnt_x - (0, 10)), :stroke);
		poly((pnt_x , Point(5, 2.5)), :stroke);
		for i in 1:6
			sign = i |> isodd ? -1 : 1;
			poly((Point(-sign * 5, i * 5 - 2.5) , Point(sign * 5, (i + 1) * 5 - 2.5)), :stroke);
		end;
		poly((Point(5, 32.5) , Point(0, 35)), :stroke);
		poly((Point(0, 35) , Point(0, 45)), :stroke);
		Luxor.label("R₃", :W, Point(0, 45), offset=5);
	)
	@layer (
		fontsize(16);
		Luxor.translate(0, 10);
		Luxor.arrow(pnts...);
		Luxor.label("L", :SW, pnts[2], offset=15);
		Luxor.translate(0, 10);
		Luxor.arrow(pnts[1], pnt_x);
		Luxor.label("x_steun", :SE, pnt_x, offset=15);
		Luxor.translate(0, 10);
		Luxor.arrow(pnts[1], pnt_a);
		Luxor.label("a", :SW, pnt_a, offset=15);
	)
end (800) (170)

# ╔═╡ 3bb458cb-1a11-4102-b588-ab67cbcb28da
md"""
!!! note "Te definiëren parameters"
	In de tabel met de **randvoorwaarden** (`rvw`) geef je de parameters $a$, $x_steun$, $L$, $p_1$ en $p_2$ in, alsook de grenstoestand (`:UGT` of `:GGT`). De parameters die je moet invullen volgen uit de **generalisering** dat in een volgende paragraaf is opgesteld.
"""

# ╔═╡ 99a918eb-1cf3-48fe-807b-3807c3189faa
md"Definieer in onderstaande tabel de verschillende belastingsgevallen"

# ╔═╡ 28e28737-8800-4d9f-a758-5640d14519b9
geom = (
	a = 5.40 - 1.94,
	x_steun = 5.40 - 2.04,
	L = 5.40
)

# ╔═╡ d0ad3ac3-771c-4266-9564-38a836ab4df0
opp_badkamer = 3.9 * 3.9 # m²

# ╔═╡ 97c8c6de-ed1b-42ba-8024-af8d86caf252
opp_kamer3 = 5.2 * 4 # m²

# ╔═╡ 54af6858-4010-493c-a730-2e1e14ec0aee
verh_m13_1 = (geom[:L] - geom[:a]) / 3.9 # Verhouding deel 1 t.o.v. muur 13

# ╔═╡ d75d858b-33e2-45d4-9e60-424048dc0c67
verh_m15_2 = geom[:a] / 4 # Verhouding deel 2 t.o.v. muur 15

# ╔═╡ 901d9ca8-d25d-4e61-92e4-782db7fd1701
md"Definieer in onderstaande tabel de verschillende combinaties. Voor **GGT** wordt gerekend met het $\psi_1$ gelijk aan $0.5$ voor de **nuttige overlast** in de *frequente* combinatie, dit volgens Categorie A volgens NBN EN 1990."

# ╔═╡ 9369fece-8b5e-4817-aee3-3476d43e1c2c
combinaties = DataFrame([
	(check=:GGT, naam="p1", formule="g1 + gp + 0.5 * q1_vloer"),
	(check=:UGT, naam="p1", formule="1.35 * (g1 + gp) + 1.5 * (q1_vloer + 0.5 * q1_sneeuw)"),
	(check=:GGT, naam="p2", formule="g2 + gp + 0.5 * q2_vloer"),
	(check=:UGT, naam="p2", formule="1.35 * (g2 + gp) + 1.5 * (q2_vloer + 0.5 * q2_sneeuw)"), 
	(check=:GGT, naam="F", formule="G + 0.5 * Q_vloer"),
	(check=:UGT, naam="F", formule="1.35 * G + 1.5 * (Q_vloer + 0.5 * Q_sneeuw)"),
])

# ╔═╡ 8d2a4c22-579c-4e92-a36d-4f5a763a9395
md"Twee hulpvariabelen voor later..."

# ╔═╡ 78a060bd-f930-4205-a956-abbb72797c1c
md"Voor de vervorming en hoekverdraaiing moet de stijfheid in acht genomen worden"

# ╔═╡ ede7539a-c98b-4521-bff7-969e6652e20c
md"""
#### Eigenschappen van het profiel
Eigenschappen van het gekozen profiel - type $(ligger[:naam])
"""

# ╔═╡ 5bacbd35-70eb-401d-bb62-23f6c17410b0
md"Haal informatie van het profiel op en bewaar het in `info`"

# ╔═╡ 7828d5a1-0a0a-45e5-acf1-a287638eb582
f_yd = begin 
	f_yk = parse(Int64, ligger[:kwaliteit][2:end]) # MPa = N/mm² - Representatieve waarde
	γ_M0 = 1.0 # Materiaalfactor op constructiestaal
	f_yk / γ_M0 # MPa = N/mm² - Rekenwaarden 
end

# ╔═╡ 8eea80b3-9824-4c5a-b1e7-76244ecadeb6
md"""
#### Keuze steun
De stijfheid is bepaald uit de materiaal karakteristieken van de de steun.

Keuze = *$(kolom[:naam])*
"""

# ╔═╡ 1cebf7c3-566f-43ac-ae1c-4ade8d6b3dfe
E = 210_000 # N/mm² of 10⁶ N/m²

# ╔═╡ 18874aab-46ce-41ab-a275-6fd13ed088b4
L_kolom = 2.8 # m

# ╔═╡ b66c98c7-fcbc-4d04-a1dc-9452cae611a9
md"""
### Oplossing belastingsschema
Met behulp van het **superpositiebeginsel** generaliseren we het probleem door een samenstel van de effecten, $V$, $M$, $\alpha$ en $v$, door de afzonderlijke aangrijpende belastingen te nemen.
"""

# ╔═╡ 0bcb8652-280f-41ca-83b8-df2b07113576
md"""
!!! danger "Opgepast!"
	Bij het gebruiken van de syntax `R11(deel...)` moet je opletten hoe `deel` is opgebouwd, immers worden de substituties niet gelijktijdig uitgevoerd, maar één voor één, en telkens wordt de formule geëvalueerd en vereenvoudigd. Dus pas je `a => b` (`a` naar `b`) aan en dan `b => L` (`b` naar `L`), dan wordt de eerder omzetting dus ook verder doorgevoerd.
"""

# ╔═╡ 7badb26d-2b53-422e-889a-1c17e009a933
p1, p2, R3, x_steun = symbols("p_1 p_2 R_3 x_{steun}", real=true)

# ╔═╡ c63034f7-fee5-4b29-af59-dc64679a3733
md"Omdat de ligger **hyperstatisch** is, wordt er *gesneden* naar het steunpunt en wordt een fictieve kracht $R_3$ in rekening gebracht, deze kracht wordt als een externe belasting ingerekend"

# ╔═╡ b70d1695-7e91-4903-a239-2a3adb4c3bd8
md"#### Reactiekrachten"

# ╔═╡ bdaf28c5-98f5-478d-ab0f-c886d93fabf1
md"""
!!! tip "Opstellen vergelijkingen"
	Bij het opstellen van de vergelijkingen maak je gebruik van de functies `R11`, `R12`, `V1`, `M1`, `α1` en `v1` voor **gespreide lasten** en van de formules `R21`, `R22`, `V2`, `M2`, `α2` en `v2` voor een **geconcentreerde last**
"""

# ╔═╡ 03dfa81c-eaa3-4273-bfff-ab4c8159ee35
md"#### Dwarskracht en momenten
Oplossing neerschrijven van de dwarkracht en het buigend moment"

# ╔═╡ eaf76ba4-846a-4a49-a5b9-2a03745f2305
md"#### Hoekverdraaiing en doorbuiging
Oplossing neerschrijven van de hoekverdraaiing en de doorbuiging"

# ╔═╡ 72062ccd-540a-4bc4-9588-d5f6539a59ea
md"#### Maximale interne krachten
Maximale interne krachten en hun voorkomen ($x$ abscis)"

# ╔═╡ 7ddacc3e-3877-4c7d-8127-b37a5e30b85a
md"""
!!! tip "lambdify"
	`lambdify` wordt gebruikt om de formules om te zetten van hun `SymPy` vorm naar een pure `Julia` vorm
"""

# ╔═╡ 348b1476-41e2-4312-8eff-4b8200218659
md"""
Substitueer alle parameters en los op naar $R_3$
"""

# ╔═╡ 45618fab-0dc4-43c3-ab0f-d24490e88695
rnd = (n -> round.(n, digits=3))

# ╔═╡ 5fc33aba-e51e-4968-9f27-95e8d77cf9f1
md"Onderstaande tabel bevat de **gesubstitueerde** generieke oplossingen"

# ╔═╡ 0823262b-1e9d-4288-abd4-48c6f0894457
md"Hieronder wordt een **overzicht tabel** weergegeven, waarbij de minimum en maximum waardes van de verschillende effecten, zijnde $V$, $M$, $\alpha$ en $v$ worden weergegeven"

# ╔═╡ d99644ec-8b84-47a7-81a7-f87657cf3820
md"""
#### Maak grafieken aan
"""

# ╔═╡ b290bdba-193a-404f-befd-814fad9b4878
function minmax(pair)
	name, v = pair
	# v: vector van functies
	plot_size = (200, 160)
	# Definieer de plot stijlen
	if name == :V
		c = "lightsalmon"
		ylabel = "kN"
	elseif name == :M
		c = "dodgerblue"
		ylabel = "kNm"
	elseif name == :α
		c = "grey"
		ylabel = "rad"
	elseif name == :v
		c = "purple"
		ylabel = "m"
	else
		c = "black"
		ylabel = "-"
	end
	# Geef de resultaten weer
	results = Array{Union{Nothing, Array{Float64}}}(nothing, length(v))
	for (i, fn) in enumerate(v)
		results[i] = fn.(0:0.1:geom[:L])
	end
	y1, y2 = collect.(zip((zip(results...) .|> extrema)...))
	return plot(0:0.1:geom[:L], y1, fillrange=y2, size=plot_size, legend=false, fillalpha = 0.35, c=c, ylabel=ylabel)
end

# ╔═╡ 1339c53c-fa89-4078-bd69-54cb6888a12f
 function grafiek(r) 
	rng = 0:0.05:r.L
	plot_size = (200, 160)
	plot1 = plot(rng, r.V, lw=2, c="lightsalmon", ylabel="kN", size=plot_size, legend=false)
	plot2 = plot(rng, r.M, lw=2, c="dodgerblue", ylabel="kNm", size=plot_size, legend=false)
	plot3 = plot(rng, r.α, lw=2, c="grey", ylabel="rad", size=plot_size, legend=false)
	plot4 = plot(rng, r.v, lw=2, c="purple", ylabel="m", size=plot_size, legend=false)
	return [plot1, plot2, plot3, plot4]
	#return plot(plot1, plot2, plot3, plot4, layout=(2,2), legend=false)
end

# ╔═╡ 86a64b87-1085-41e0-a0b4-e846bae2ffba
md"""
# Achterliggende berekeningen

Hieronder wordt de algemene uitwerking van de balkentheorie behandeld.
"""

# ╔═╡ 2b4be6eb-8ad5-422a-99d8-a45a20e02c69
md"## *Dependencies* en hulpfuncties
Hieronder worden de *dependencies* geladen en de hulpfuncties gedefinieerd"

# ╔═╡ 06bc1b2b-f26a-47c6-83b7-a639e17f3bc2
begin
	DotEnv.config()
	md"Laad de *environment variables* met `DotEnv.config()`"
end

# ╔═╡ 8d61adab-5ddb-483a-8330-21fc94613bd1
db = SQLite.DB("assets/db/db.sqlite")

# ╔═╡ 3e479359-d1a8-4036-8e9c-04317efde55a
begin
	sections = DBInterface.execute(db, "SELECT name FROM sections") |> DataFrame
	columns = DBInterface.execute(db, "SELECT name FROM tubes") |> DataFrame
	select_profiel = @bind __profiel Select(sections[!, "name"], default=ligger[:naam])
	select_kolom = @bind __kolom Select(columns[!, "name"], default=kolom[:naam])
	select_staalkwaliteit = @bind __staalkwaliteit Select(["S235", "S355"], default=ligger[:kwaliteit])
	md"""
	Lijst met beschikbare profielen: $select_profiel in kwaliteiten $select_staalkwaliteit
	
	Lijst met beschikbare kolommen: $select_kolom in kwaliteiten $select_staalkwaliteit
	"""
end

# ╔═╡ a45968e2-42a0-4307-bcf6-4ea559024799
DBInterface.execute(db, """
SELECT
	name, G, b, h, tw, tf, "Wel.y", Iy
FROM (
	SELECT
		s.*,
		ABS(s.Iy - (
				SELECT
					t.Iy FROM sections AS t
				WHERE
					t.name = "$(ligger[:naam])")) AS afstand
	FROM
		sections AS s
	ORDER BY
		afstand ASC
	LIMIT 10)
ORDER BY
	Iy ASC;	
""") |> DataFrame

# ╔═╡ 43453fa0-512b-4960-a0bb-fb44e538b6a6
profiel = DBInterface.execute(db, "SELECT * FROM sections WHERE name = '$(ligger[:naam])';") |> DataFrame

# ╔═╡ c4c79ab2-d6b7-11eb-09d0-e3cbf2c9d6e9
md"""
# Berekening $naam - $(profiel[1, "name"])
Bereking van **$naam**, een **hyperstatische** ligger **onder muur 13 en 15**. Het profiel hoort in theorie de vloer van de badkamer en kamer 3 niet te ondersteunen, gezien deze afdraagt van respectievelijk muur 1 naar muur 4 en 5, van muur 4 en 6 naar muur 9. Veiligheidshalve rekenen we 20% mee van de last t.g.v. de vloer van de badkamer en kamer 3.

Lasten zijn afkomstig van het dak tot het eerste verdiep. Er wordt gerekend met een **nuttige belasting** van $200 kN/m^2$ en een krachtsafdracht van de vloeroppervlaktes tussen de draagmuren (dus **krachtsafdracht** in **1 richting**), tenzij hier uitdrukkelijk van afgeweken wordt.
"""

# ╔═╡ 7e9d76e1-ee9f-4b3c-bf5f-9b6901f192e6
belastingsgevallen = DataFrame([
	(naam="g1", waarde=(18.797 + 0.2 * opp_badkamer * 3.07) * verh_m13_1 , beschrijving="Perm. last - lastendaling"),
	(naam="g2", waarde=(17.577 + 0.18 * opp_kamer3 * 3.07) * verh_m15_2, beschrijving="Perm. last - lastendaling"),
	(naam="G", waarde=150, beschrijving="Perm. last - lastendaling"),	
	(naam="gp", waarde=profiel[1, "G"] * 0.01, beschrijving="Perm. last - profiel"),
	(naam="q1_vloer", waarde=(0.2 * opp_badkamer * 2.0) * verh_m13_1, beschrijving="Var. last - nuttige overlast"),
	(naam="q2_vloer", waarde=(0.18 * opp_kamer3 * 2.0) * verh_m15_2, beschrijving="Var. last - nuttige overlast"),
	(naam="Q_vloer", waarde=60, beschrijving="Var. last - nuttige overlast"),
	(naam="q1_sneeuw", waarde=(4.01) * verh_m13_1, beschrijving="Var. last - sneeuwlast"),
	(naam="q2_sneeuw", waarde=(4.01) * verh_m15_2, beschrijving="Var. last - sneeuwlast"),
	(naam="Q_sneeuw", waarde=20, beschrijving="Var. last - sneeuwlast")
])

# ╔═╡ 8c7359a5-4daf-4c6e-b92a-75b96636b26c
resultaatklasse = begin
	waarde = s -> first(belastingsgevallen[belastingsgevallen.naam .== s,:waarde])
	regex_namen = Regex(join(belastingsgevallen[:,:naam], "|"))
	hulp1 = select(combinaties, :,
		AsTable(:) => ByRow(r -> replace(r.formule, regex_namen => s -> waarde(s)) |> (eval ∘ Meta.parse)) => :uitkomst
	)
end

# ╔═╡ 1383f2c6-12fa-4a36-8462-391131d1aaee
maatgevend = unstack(combine(groupby(resultaatklasse, [:naam, :check]), :uitkomst => maximum => :waarde), :check, :naam, :waarde)

# ╔═╡ 4b9528fc-554f-49df-8fb8-49613f892e36
rvw = begin
	maatgevend[!, "a"] .= geom[:a]
	maatgevend[!, "x_steun"] .= geom[:x_steun]
	maatgevend[!, "L"] .= geom[:L]
	maatgevend
end

# ╔═╡ 020b1acb-0966-4563-ab52-79a565ed2252
isGGT = rvw.check .== :GGT

# ╔═╡ 8e5c04fd-d83c-49e8-b6b1-5a6a101c56c9
isUGT = rvw.check .== :UGT

# ╔═╡ 03e08a96-29c2-4921-b107-ded3f7dce079
buigstijfheid = 210000 * (profiel[!, "Iy"] |> first) / 10^5 # kNm²

# ╔═╡ 54a849f3-51ee-43e3-a90c-672046d3afa8
W_el = profiel[1, "Wel.y"] # cm3

# ╔═╡ a1b7232f-4c34-4bd7-814a-2bacc4cb1fb4
M_Rd = W_el * f_yd / 1000 # kNm

# ╔═╡ 5c4d049a-a2c4-48dc-a0dd-8199153c831a
V_Rd = (profiel[!, "Avz"] |> first) * f_yd / 10 # kN

# ╔═╡ 88658420-969a-4786-87ad-bc56455503f8
steun = DBInterface.execute(db, "SELECT * FROM tubes WHERE name = '$(kolom[:naam])';") |> DataFrame

# ╔═╡ 2eb8de93-f0a2-402e-98a6-474a483acb06
A = steun[!, :A] |> first # mm²

# ╔═╡ f6d87218-d41c-4f03-8d57-c03f33910c86
k = E * A / L_kolom / 1000 # kN/m

# ╔═╡ 91f347d9-e9b6-4e53-9093-20d1987f8ca8
md"Start de `plotly` backend"

# ╔═╡ 60615a85-81d3-4237-8ad4-e43e856b8902
plotly()

# ╔═╡ a3aa1221-123b-4c8c-87ae-db7116c443fb
md"Herschaal het font"

# ╔═╡ 137f4eb4-9e67-4991-95e6-f31b3fa6cd11
begin
	Plots.scalefontsizes() 		# Reset the font
	Plots.scalefontsizes(2/3)	# Make the font 2 times smaller
end

# ╔═╡ a841663b-a218-445f-8249-a28a766cbde5
md"Symbolische notatie wordt gehanteerd om de basis op te stellen. Het opstellen van de vergelijken doen we via `SymPy`, bekend vanuit **Python**. Het pakket kun je aanroepen via `PyCall`, wat we ook zullen doen voor enkele functies, maar kan ook via `SymPy.jl` dat wat *Julia* specifieke syntax toevoegd om gebruik te maken van het pakket. Doordat in de *backend* verbinding wordt gelegd met een *Python* omgeving, is snelheid beperkt:

`SymPy` oproepen via `PyCall` doe je als volgt:
```julia
import Pkg; Pkg.add(\"Conda\")
import Pkg; Pkg.add(\"PyCall\")
# Install SymPy using Conda
using Conda, PyCall
Conda.add(\"sympy\")
# PyCall uses the python interpreter included in the Conda.jl package
sympy = pyimport(\"sympy\")
```

Naast bovenstaande roepen we ook `SymPy.jl` op om gebruik te maken van `SymPy` via  *Julia* specifieke syntax: 
```julia
import Pkg; Pkg.add(\"SymPy\")
```
"

# ╔═╡ 8d67ceaf-7303-4fb2-9577-a7fd2db6d233
function _heaviside(t)
	# Bij t=0 is sign(t) = 0 of deze functie 0.5
	0.5 .* (sign.(t) .+ 1)
end

# ╔═╡ 048926fe-0fa3-44c4-8772-0e4adae576a4
md"Ook `SymPy` heeft een methode Heaviside - functie te gebruiken via `PyCall`"

# ╔═╡ 79cf1b35-6ec0-4950-9f47-e800dee0b44a
# Bij deze definitie is de waarde bij t=0 gelijk aan 'onbestaande'
heaviside = sympy.functions.special.delta_functions.Heaviside

# ╔═╡ 265977b4-0fd8-4e38-aa46-6be5bcd00420
function interval(t, a, b)
	# Bij t=b wordt een waarde van 0.5 geretourneerd (limitatie)
	heaviside(t-a,0) .- heaviside(t-b,0) 
end

# ╔═╡ 6428b28d-7aa9-489d-b2b9-c08db5876342
md"Naast `Heaviside` is er ook een methode `Piecewise` via `PyCall` aan te roepen. Helaas ondersteunen deze functie wel geen Array calls, dus moet je de `map` functie in *Julia* gaan gebruiken om bijvoorbeeld te gaan plotten"

# ╔═╡ 7683a362-ab86-4f19-964d-e71a61e86436
# Functie roep je aan met f(t) = piecewise((5, t < 2), (10, t <= 4))
piecewise = sympy.functions.elementary.piecewise.Piecewise

# ╔═╡ c5fc9f07-5262-42c8-bada-bf8e1edd3929
md"Eigen `Check` type met ook een eigen uitdraai"

# ╔═╡ 666bbf88-8d84-416f-a369-d2e20a7935f1
@enum Check OK=true NOK=false

# ╔═╡ 454abf3b-b2a0-4d58-acfc-d3ff4a9e0255
md"""
#### Controle
Aftoetsen van de interne krachten en vervormingen
!!! warning "Controles"
	Maak gebruik van *enumerate* `Check` met waarde *false* of *true*.

`Check(true)` resulteert in de uitdraai: $(Check(true))

`Check(false)` resulteert in de uitdraai: $(Check(false))
"""

# ╔═╡ 598e31e9-b7d1-40c7-82e4-743997cb4063
function Base.show(io::IO, mime::MIME"text/html", c::Check)
	id = UUIDs.uuid4().value
	color = (c == Check(false)) ? "crimson" : "yellowgreen"
	Base.write(io, """
		<style>
		.marked-$id {
			color: white;
			background-color: $(color);
			padding: 0 2px;
		}
		</style>
		<mark class="marked-$id">$(string(c))</mark>
		""")
end

# ╔═╡ 2b3b4a17-3fdd-442d-872c-e5c77c9fd00a
md"Definieer een nieuwe *type* getiteld *Unity Check* of `UC`" 

# ╔═╡ d4ccd49b-d34f-4ac5-a463-c3ecb306c285
struct TwoColumn{L, R}
    left::L
    right::R
end

# ╔═╡ 37fd4df6-63c9-44eb-9e92-1635f428a341
function Base.show(io, mime::MIME"text/html", tc::TwoColumn)
    write(io, """<div style="display: flex; align-items: center; justify-content: center;"><div>""")
    show(io, mime, tc.left)
    write(io, """</div><div style="flex: 1; padding-left: 2px;">""")
    show(io, mime, tc.right)
    write(io, """</div></div>""")
end

# ╔═╡ 46776f90-5dc9-422b-bfc2-9b9a94d97243
mutable struct UC
	beschrijving::Markdown.MD
	waarde::Float64 # teller
	limiet::Float64 # noemer
	check::Check 
	UC(beschrijving, waarde, limiet) = (uc = new(beschrijving, waarde, limiet); uc.check = Check(waarde / limiet <= 1); uc)
end

# ╔═╡ 9364f897-0666-4ebe-9725-3c864db07b42
check1 = (t, n) -> UC(md"$\dfrac{\sigma_{s}}{0.8\ f_{yd}}$", t, n)

# ╔═╡ b93d2ce0-ac8a-4487-9d1d-0300db4a9df8
check2 = (t, n) -> UC(md"$\dfrac{v_{max}}{v_{lim}}$", t, n)

# ╔═╡ c46e9ee1-6fc4-476d-b77c-17c46ed5a09d
check3 = (t, n) -> UC(md"$\dfrac{M_{Ed}}{M_{Rd}}$", t, n)

# ╔═╡ fb4abf40-d5ee-490b-b2eb-89233d9b337a
check4 = (t, n) -> UC(md"$\dfrac{V_{Ed}}{V_{Rd}}$", t, n)

# ╔═╡ 24bb7ff8-ab30-4f14-9f32-f80fa703ff1c
function controle(r::NamedTuple)
	checks = Array{Union{Missing, UC}}(missing, 4)
	if r.check == :GGT
		# Check 1 - Controleer de spanning in het staal
		M_ggt = maximum(r.M .|> (abs)) # kNm
		σ_ggt = (M_ggt / W_el) * 1000 # MPa
		checks[1] = check1(σ_ggt, 0.8 * f_yd)
		# Check 2 - Controleer de doorbuiging van de balk
		v_lim = r.L / 500 * 1000 # mm
		v_max = maximum(r.v .|> (abs)) * 1000 # mm
		checks[2] = check2(v_max, v_lim)
	elseif r.check == :UGT
		# Check 3 - Controle doorsnede
		M_Ed = maximum(r.M .|> (abs))
		checks[3] = check3(M_Ed, M_Rd)
		# Check 3 - Controle doorsnede
		V_Ed = maximum(r.V .|> (abs))
		checks[4] = check4(V_Ed, V_Rd)
	end
	return checks
end

# ╔═╡ 6c9ec52c-fd12-4d28-ba4b-179c0093e6e8
function Base.show(io::IO, mime::MIME"text/html", uc::UC)
	afronden = t -> (d -> round(d, digits=t))
	subs = Dict(
		"beschrijving" => uc.beschrijving.content[1].formula, 
		"waarde" => uc.waarde |> afronden(1),
		"limiet" => uc.limiet |> afronden(1),
		"uc" => (uc.waarde / uc.limiet) |> afronden(2)
	)
	format = raw"$\text{UC} = beschrijving = \dfrac{waarde}{limiet} = uc\rightarrow$"
	
	Base.write(io, """<div style="display: flex; align-items: center; justify-content: center;"><div>""")
	Base.show(io, mime, Markdown.parse(replace(format, r"beschrijving|waarde|limiet|uc" => s -> subs[s])))
	Base.write(io, """</div><div style="flex: 1; padding-left: 2px;">""")
	Base.show(io, mime, uc.check)
	Base.write(io, """</div></div>""")
end

# ╔═╡ 494217c7-510c-4993-b995-741d42f9d502
md"## Interne krachtswerking"

# ╔═╡ 1773c88b-7d9e-4617-a3b9-084e93da50b8
md"""
> **Superpositiebeginsel**
>
> Wanneer een lichaam onderworpen is aan verschillende krachtsverwerkingen ($F$, $M$, $\Delta T$...) mag men het effect ($\sigma$, $\epsilon$, $v$, $\alpha$...) van elk van die belastingen, waarbij ze afzonderlijk op het lichaam inwerken, optellen of superponeren indien een aantal geldigheidsvoorwaarden vervuld zijn:
> - De (veralgemeende) verplaatsingen zijn klein
> - De materialen zijn lineair elastisch en kunnen met andere woorden door de wetten van *Hooke* worden beschreven
> - Er is **geen** energiedissipatie in de verbindingen door wrijving
"""

# ╔═╡ 04b77a81-2e9c-4af9-80a4-088c3b52ca81
md"Gebruik `@syms` om *SymPy symbols* te definiëren of gebruik de functie `symbols`. De laatste optie heeft het voordeel dat je nadien je invoergegevens nog kan wijzigen. Bij het gebruik van `@syms` kan je dit niet langer. Ook heb je flexibiliteit over de naam bij het gebruik van `symbols`"

# ╔═╡ 43ff70cc-235f-44e4-9a32-beabd9de7abb
md"### Steunpunten
Bepaal de krachten in de steunpunten door het momentenevenwicht uit te schrijven in de steunpunten. Het moment ter hoogte van de steunpunten is $0$, dus uit dit gegeven bereken je eenvoudig de krachten ter hoogte van de steunpunten. Bij een **statisch** bepaalde constructie bepaal je dus in 1 tijd je reactiekrachten.

> Hyperstatische constructie?

Een **hyperstatische** constructie kun je oplossen door het *snijden* in de krachten en het te vervangen door onbekende krachten. Je gaat door met *snijden* tot je een statisch bepaalde constructie bekomt. Bij de oplossing leg je nadien bijkomende beperkingen op. Ter hoogte van het steunpunt zal bijvoorbeeld de vervorming er gelijk moeten zijn aan $0$ of de rotatie $0$ indien je *gesneden* hebt in een momentvaste verbinding"

# ╔═╡ 96134cde-f7e4-4bd5-b3c0-2fa05708f7f4
md"### Kinematische randvoorwaarden
Leg de kinematische randvoorwaarden op om de constantes te gaan bepalen. Deze voorwaarden bestaan onderander uit $v(t=>0) = 0$ en $v(t=>L) = 0$. De ligger heeft een continue vervorming en ook de hoekverdraaiing verloopt continu. 

> Hyperstatische constructie?

Bij een **hyperstatische** constructie worden extra randvoorwaarden opgelegd. Zo zal bijvoorbeeld naar de verticale kracht van een steunpunt *gesneden* zijn en dien nu opgelegd te worden dat de vervorming er gelijk is aan $0$."

# ╔═╡ 99e49c7b-b2dd-49dc-bee1-336d4d1334b1
md"### Oplossing basisschema's
Bepaal de dwarskrachten $V(t)$ en momenten $M(t)$ voor een eenvoudig opgelegde ligger met twee verdeelde belastingen. Nadien bepalen we ook de hoekverdraaiing $\alpha(t)$ en de doorbuiging $v(t)$."

# ╔═╡ 9c08891c-1269-43f8-8095-28eee34bbb3a
md"#### Dwarskracht $V$ en buigend moment $M$
Berekening van de interne krachten. BIj een **statisch** bepaalde constructie zijn deze niet afhankelijk van de *stijfheid*, bij een **hyperstatische** constructie wel en volgt het dwarskrachtverloop pas uit het oplossen van een stelsel"

# ╔═╡ db19bc67-2894-4bd7-a03c-6d28dfedd4d2
md"""
#### Hoekverdraaiing $\alpha$ en doorbuiging $v$
Deze worden berekend uit de kromming $\chi$.

We wensen de **vervormingen** $v(t)$ te kennen van de ligger, hiervoor grijpen we terug naar de volgende theorie. De kromming $\chi$ is gelijk aan de verhouding tussen het moment en de buigstijfheid, dit bij kleine vervormingen.

$$\chi = \dfrac{\text{M}}{\text{EI}} = \dfrac{d\alpha}{dt} = \dfrac{d^2v}{dt^2}$$

Merk op dat we hier $t$ hanteren als indicatie voor de positie op de ligger.

De ligger wordt opgeknipt in een aantal delen, een *piecewise* functie. Elk deel wordt geintegreerd. Constantes komen op de proppen die nadien via een stelsel bepaald dienen te worden. Voor elk deel wordt een **unieke** constante gedefinieerd.
"""

# ╔═╡ 2421b3f9-2b25-45b5-9ca7-37e65c249235
t = symbols("t", real=true, positive=true)

# ╔═╡ 041cc722-eee1-4456-95bb-f2ad7c1ee771
a, b, p, p_a, p_b, F, L, EI = symbols("a b p p_a p_b F L EI", real=true)

# ╔═╡ 5d5aeb91-0507-4cab-8151-8b19389bb720
deel1 = (
	a => 0,
	b => a,
	p => p1
)

# ╔═╡ a34c804b-399a-4e40-a556-1e590757d048
deel2 = (
	b => L,
	p => p2,
)

# ╔═╡ 6d812a7f-93e4-4d83-8c38-88d1c92f92cf
deel3 = (
	a => x_steun,
	F => F
)

# ╔═╡ 7fa928b9-599d-43c3-b2d7-6890892e3771
deel4 = (
	a => x_steun,
	F => R3
)

# ╔═╡ 84f36442-a43b-4488-b700-8cd399c20e4f
#fn = r -> (i -> lambdify(i(mapping(r)...)))
function fn(r)
	sol = Dict(collect(keys(r)) .|> eval .=> collect(values(r)))
	return i -> lambdify(i(
			sol...,
			EI => buigstijfheid
	))
end

# ╔═╡ e7ba9264-9bff-45dc-89f8-44d09cf3898f
md"""
### Schema 1. Verdeelde belasting $p$ van $a$ tot $b$

**Eenvoudig** opgelegde ligger, opwaartse kracht = positief (steunpunten). Aangrijpende kracht $p$ is neerwaarts gericht.
"""

# ╔═╡ 30cf07bb-6304-4ee0-8e7b-7430d6ab8167
md"""
!!! info "Toelichting"
	Dit is een speciaal geval van paragraaf §3 Variabele verdeelde belasting $p_a$ van $a$ tot $p_b$ ter hoogte van $b$, waarbij $p_a$ gelijk wordt gesteld aan $p_b$. De waarde van de verdeelde belasting wordt gelijk gesteld aan $p$. De *mapping* wordt vastgelegd in `BC31`, de *boundary condition* toegepast op §3 ter bekoming van de oplossing van §1
"""

# ╔═╡ 68457ff5-7dc4-45b6-9c1f-9db34d0c9fc8
BC31 = (
	p_a => p,
	p_b => p
)

# ╔═╡ c89bfe59-0c2d-423e-abac-4ea86981f479
@drawsvg begin
	sethue("black")
	endpnts1 = (-200, 0), (200, 0)
	pnt_a1 = Point(-100, 0)
	pnt_b1 = Point(50, 0)
	dst_1 = distance(pnt_a1, pnt_b1)
	pnts1 = Point.(endpnts1)
	@layer (
		fontsize(20);
		poly(pnts1, :stroke);
		circle.(pnts1, 4, :fill);
		for i = 0:10
			Luxor.arrow(Point(-100 + 15 * i, -45), Point(-100 + 15 * i, -5));
		end;
		Luxor.label.(["1", "2"], [:NW, :NE], pnts1, offset=15)
	)
	@layer (
		fontsize(16);
		Luxor.translate(0, -45);
		poly((pnt_a1, pnt_b1), :stroke);
		Luxor.label("p", :N, midpoint(pnt_a1, pnt_b1), offset=15);
	)
	@layer (
		fontsize(16);
		Luxor.translate(0, 10);
		Luxor.arrow(pnts1...);
		Luxor.label("L", :SW, pnts1[2], offset=15);
		Luxor.translate(0, 10);
		Luxor.arrow(pnts1[1], pnt_b1);
		Luxor.label("b", :SW, pnt_b1, offset=15);
		Luxor.translate(0, 10);
		Luxor.arrow(pnts1[1], pnt_a1);
		Luxor.label("a", :SW, pnt_a1, offset=15);
	)
end (800) (150)

# ╔═╡ 81f8c16e-9863-42b3-a91c-df51323b091f
md"Moment in de steunpunten = $0$ $\rightarrow$ evenwicht er rond uitschrijven ter bepalen van de steunpuntsreacties"

# ╔═╡ a824cc32-c7e4-471b-afa6-88facbea9eed
md"#### 1.1 Bepalen dwarskracht $V(t)$"

# ╔═╡ ff0dd91a-a69e-4314-8afc-abbb2d80a3ae
md"#### 1.2 Bepalen moment $M(t)$"

# ╔═╡ 4e664ecf-c7b1-4f43-a17f-7b05a4fc1abd
md"#### 1.3 Bepalen hoekverdraaiing $\alpha(t)$"

# ╔═╡ c41fc340-b391-4b57-906a-942747f6deae
md"#### 1.4 Bepalen doorbuiging $v(t)$"

# ╔═╡ 5b6e5cbb-c629-468a-994d-144868734d87
md"""
#### 1.5 Kinematische randvoorwaarden
De ligger heeft een continue vervorming en ook de hoekverdraaiing verloopt continu.

De kinemtatische randvoorwaarden hoeven echter niet meer opgelegd te worden, omdat de oplossing volgt uit de generieke situatie met een lineair varierende belasting $p_a$ tot $p_b$.
"""

# ╔═╡ 57aff837-27ed-460d-b8e6-61c7274d1ccf
md"""
### Schema 2. Puntlast $F$ ter hoogte van abscis $a$

**Eenvoudig** opgelegde ligger, reactiekracht opwaarts = positief, aangrijpende kracht neerwaarts = positief 
"""

# ╔═╡ 1fbb3eff-fa40-4beb-9c05-ae03887d75cd
@drawsvg begin
	sethue("black")
	endpnts2 = (-200, 0), (200, 0)
	pnt_a2 = Point(-40, 0)
	pnts2 = Point.(endpnts1)
	@layer (
		fontsize(20);
		poly(pnts2, :stroke);
		circle.(pnts2, 4, :fill);
		Luxor.label.(["1", "2"], [:NW, :NE], pnts2, offset=15)	
	)
	@layer (
		fontsize(16);
		Luxor.translate(0, -45);
		Luxor.arrow(pnt_a2, pnt_a2 + (0, 40));
		Luxor.label("F", :E, pnt_a2, offset=5);
	)
	@layer (
		fontsize(16);
		Luxor.translate(0, 10);
		Luxor.arrow(pnts2...);
		Luxor.label("L", :SW, pnts2[2], offset=15);
		Luxor.translate(0, 10);
		Luxor.arrow(pnts2[1], pnt_a2);
		Luxor.label("a", :SW, pnt_a2, offset=15);
	)
end (800) (150)

# ╔═╡ fd50008b-367d-407f-8044-ee322eb634d8
md"Moment in de steunpunten = $0$ $\rightarrow$ evenwicht er rond uitschrijven ter bepalen van de steunpuntsreacties"

# ╔═╡ a20cdfb2-83b4-4d76-87a7-d4e4965e15e3
R21 = (F .* (L - a)) ./ L

# ╔═╡ 425dbfc2-7430-4270-8d49-3a1dc818d2d4
R22 = (F .* a) ./ L

# ╔═╡ 55c36b3a-29e4-4451-aa18-b5e17ff212f6
md"#### 2.1 Bepalen dwarskracht $V(t)$"

# ╔═╡ 639ad713-3175-4b56-a6e0-b9cc4b5c9e20
begin
	V21 = - R21  		# Van t: 0 -> a
	V22 = - R21 .+ F 	# Van t: a -> L
	V2 = V21 .* interval(t, -1e-10, a) .+ V22 .* interval(t, a, L)
end

# ╔═╡ b41b056d-145f-4000-8414-a1e3c1b4ccd4
md"#### 2.2 Bepalen moment $M(t)$"

# ╔═╡ b6e8a57f-b9fc-422f-a61b-61d1b243441b
begin
	M21 = R21 .* t 					# Van t: 0 -> a
	M22 = R22 .* (L - t)		  	# Van t: a -> L
	M2 = M21 .* interval(t, -1e-10, a) .+ M22 .* interval(t, a, L)
end

# ╔═╡ 626f22a6-e5b9-4406-99d5-8824cc06b9b3
md"#### 2.3 Bepalen hoekverdraaiing $\alpha(t)$"

# ╔═╡ 5d69109b-9099-4ee7-bf10-649e22067a19
C21, C22 = symbols("C_1 C_2", real=true)

# ╔═╡ bb6cef33-bb5a-4f59-a95b-0dd2ffc07fc5
begin
	α21 = integrate(M21, t) + C21 	# Van t: 0 -> a
	α22 = integrate(M22, t) + C22 	# Van t: a -> L
	α2_ = α21 .* interval(t, -1e-10, a) .+ α22 .* interval(t, a, L)
end

# ╔═╡ e8555970-8bd0-404f-8a83-8e696a8cebc1
md"#### 2.4 Bepalen doorbuiging $v(t)$"

# ╔═╡ 446347ec-acec-4245-8a7a-b01f4f6bf228
D21, D22 = symbols("D_1 D_2", real=true)

# ╔═╡ 61ffd882-8114-4d8f-a696-e6aef6f0406e
begin
	v21 = integrate(α21, t) + D21 	# Van t: 0 -> a
	v22 = integrate(α22, t) + D22 	# Van t: a -> L
	v2_ = v21 .* interval(t, -1e-10, a) .+ v22 .* interval(t, a, L)
end

# ╔═╡ 1c48fbe9-9cb6-4c3c-b3a1-3239e46b7058
md"#### 2.5 Kinematische randvoorwaarden
De ligger heeft een continue vervorming en ook de hoekverdraaiing verloopt continu."

# ╔═╡ 8f4da1f8-3f3c-404d-bac0-79598f92c96f
rvw2 = [
		# Vervormingen
		v21(t=>0), 
		v21(t=>a) - v22(t=>a), 
		v22(t=>L), 
		# Hoekverdraaiingen 
		α21(t=>a) - α22(t=>a)
	]

# ╔═╡ 86a4e54c-4461-417b-8322-62bdc08ffab1
opl2 = solve(rvw2, [C21, C22, D21, D22])

# ╔═╡ 299e05b2-c2e8-45bd-9277-1a71fed36ba9
EIα2 = α2_(opl2...)

# ╔═╡ a9146129-509a-44f1-8e6b-0de0295e5e75
α2 = EIα2 / EI

# ╔═╡ d974e8c6-ecf2-42ed-b004-a6e9ff7936c8
EIv2 = v2_(opl2...)

# ╔═╡ 7b685a83-6541-4fd7-8d2f-502a07c252a7
v2 = EIv2 / EI

# ╔═╡ 97d0a7c9-7ae3-49fa-a56b-52d7bd25784b
md"""
### Schema 3. Variabele verdeelde belasting $p_a$ van $a$ tot $p_b$ ter hoogte van $b$

**Eenvoudig** opgelegde ligger, opwaartse kracht = positief (steunpunten). Aangrijpende kracht $p_a$ en $p_b$ is neerwaarts gericht.
"""

# ╔═╡ b4b675ab-53d5-4f46-9cfc-dca47acce67a
@drawsvg begin
	sethue("black")
	endpnts3 = (-200, 0), (200, 0)
	pnt_a3 = Point(-100, 0)
	pnt_b3 = Point(50, 0)
	pnts3 = Point.(endpnts3)
	@layer (
		fontsize(20);
		poly(pnts3, :stroke);
		circle.(pnts3, 4, :fill);
		for i = 0:10
			Luxor.arrow(Point(-100 + 15 * i, -45 - 2 * i), Point(-100 + 15 * i, -5));
		end;
		Luxor.label.(["1", "2"], [:NW, :NE], pnts3, offset=15)
	)
	@layer (
		fontsize(16);
		Luxor.translate(0, -45);
		poly((pnt_a3, pnt_b3 - (0, 20)), :stroke);
		Luxor.label("p_a", :NW, pnt_a3, offset=15);
		Luxor.label("p_b", :NE, pnt_b3, offset=15);
	)
	@layer (
		fontsize(16);
		Luxor.translate(0, 10);
		Luxor.arrow(pnts3...);
		Luxor.label("L", :SW, pnts3[2], offset=15);
		Luxor.translate(0, 10);
		Luxor.arrow(pnts3[1], pnt_b3);
		Luxor.label("b", :SW, pnt_b3, offset=15);
		Luxor.translate(0, 10);
		Luxor.arrow(pnts3[1], pnt_a3);
		Luxor.label("a", :SW, pnt_a3, offset=15);
	)
end (800) (150)

# ╔═╡ e0f01459-d164-4cac-a5eb-a65aa3f466d9
md"Moment in de steunpunten = $0$ $\rightarrow$ evenwicht er rond uitschrijven ter bepalen van de steunpuntsreacties"

# ╔═╡ 2dc0930e-6807-4ca6-8b49-fb5fafb41d52
R31 = ((p_a + p_b) / 2 * (b - a) * (p_a * (L - a) + p_b * (L - b)) / (p_a + p_b)) / L

# ╔═╡ fd639425-e97f-4eb0-928b-f1479b09cae6
R11 = SymPy.simplify(R31(BC31...))

# ╔═╡ 04dafcd3-8568-426b-9c5f-b21fc09d5e88
R1 = R11(deel1...) + R11(deel2...) + R21(deel3...) + R21(deel4...)

# ╔═╡ 6472775b-5fc7-493c-a71c-7aed44657e4c
R32 = ((p_a + p_b) / 2 * (b - a) * (p_a * a + p_b * b) / (p_a + p_b)) / L

# ╔═╡ 90ad790e-78a9-4a65-89ef-887d3ffcc54f
R12 = SymPy.simplify(R32(BC31...))

# ╔═╡ dfd9aed7-9922-4a47-a0b9-20b0bae0ccbf
R2 = R12(deel1...) + R12(deel2...) + R22(deel3...) + R22(deel4...)

# ╔═╡ d348331c-7418-4f8b-a749-64f7ee824cb6
md"#### 3.1 Bepalen dwarskracht $V(t)$"

# ╔═╡ 51102b12-9a4f-4081-82e9-283c64053056
begin
	p_t = (p_b .- p_a) ./ (b .- a) .* (t .- a) + p_a	# hulpfunctie
	V31 = - R31  										# Van t: 0 -> a
	V32 = - R31 .+  ((p_a .+ p_t) ./ 2) .* (t .- a) 	# Van t: a -> b
	V33 = + R32  										# Van t: b -> L
	V3 = V31 .* interval(t, -1e-10, a) .+ V32 .* interval(t, a, b) .+ V33 .* interval(t, b, L)
end

# ╔═╡ d7d3fb8b-ed92-44d5-92a2-2cd6144ef4f4
V1 = SymPy.simplify(V3(BC31...))

# ╔═╡ 842f1dbd-32b7-4adf-a0c8-6ca6a5fb323d
V = V1(deel1...) + V1(deel2...) + V2(deel3...) + V2(deel4...)

# ╔═╡ b782e7c4-2c58-4a54-9f32-ed4ec4ac491c
md"#### 3.2 Bepalen moment $M(t)$"

# ╔═╡ 6b6bc466-64b9-4c3a-9e30-ffea398c51aa
begin
	M31 = R31 .* t 			# Van t: 0 -> a
	M32 = R31 .* t - ((p_a .+ p_t) ./ 2) .* (p_a / (p_a + p_t)) .* (t .- a) ^ 2  
	M33 = R32 .* (L .- t) 	# Van t: b -> L
	M3 = M31 .* interval(t, -1e-10, a) .+ M32 .* interval(t, a, b) .+ M33 .* interval(t, b, L)
end

# ╔═╡ bf900b34-521f-4b81-914b-8ec88a7cea45
M1 = SymPy.simplify(M3(BC31...))

# ╔═╡ 5ac2cbd5-0117-404c-a9e7-301269c7e700
M = M1(deel1...) + M1(deel2...) + M2(deel3...) + M2(deel4...)

# ╔═╡ 7fe06e69-573b-4bbf-9ccd-5ba3d508fab4
md"#### 3.3 Bepalen hoekverdraaiing $\alpha(t)$"

# ╔═╡ d6d93146-fb11-4051-aaab-222fcf090911
C31, C32, C33 = symbols("C_1 C_2 C_3", real=true)

# ╔═╡ 37aab722-a75b-4f8d-a752-a33e0338ad8c
begin
	α31 = integrate(M31, t) + C31 	# Van t: 0 -> a
	α32 = integrate(M32, t) + C32 	# Van t: a -> b
	α33 = integrate(M33, t) + C33 	# Van t: b -> L
	α3_ = α31 .* interval(t, -1e-10, a) .+ α32 .* interval(t, a, b) .+ α33 .* interval(t, b, L)
end

# ╔═╡ 81f9b18a-bd28-4147-b9d3-9ec8925a2d01
md"#### 3.4 Bepalen doorbuiging $v(t)$"

# ╔═╡ 2db71caa-018b-4787-a125-ae4cd6fabd3a
D31, D32, D33 = symbols("D_1 D_2 D_3", real=true)

# ╔═╡ 3e2ac75b-c8a0-467a-816e-907f4e7b809f
begin
	v31 = integrate(α31, t) + D31 	# Van t: 0 -> a
	v32 = integrate(α32, t) + D32 	# Van t: a -> b
	v33 = integrate(α33, t) + D33 	# Van t: b -> L
	v3_ = v31 .* interval(t, -1e-10, a) .+ v32 .* interval(t, a, b) .+ v33 .* interval(t, b, L)
end

# ╔═╡ e581f1f6-8507-49d3-b1b9-6afbff2c2d92
md"#### 3.5 Kinematische randvoorwaarden
De ligger heeft een continue vervorming en ook de hoekverdraaiing verloopt continu."

# ╔═╡ bd459a19-79cd-40a8-b9f3-55ce5b0aba7d
rvw3 = [
		# Vervormingen
		v31(t=>0), 
		v31(t=>a) - v32(t=>a), 
		v32(t=>b) - v33(t=>b), 
		v33(t=>L), 
		# Hoekverdraaiingen 
		α31(t=>a) - α32(t=>a), 
		α32(t=>b) - α33(t=>b)
	]

# ╔═╡ 509d8c4d-6b75-49a6-aba1-91894fb8f580
opl3 = solve(rvw3, [C31, C32, C33, D31, D32, D33])

# ╔═╡ 8611a01a-9bb0-49f1-b452-e1aeeb545c51
EIα3 = α3_(opl3...)

# ╔═╡ 01265ddd-3798-4e38-b054-2b1837f9bad7
α3 = EIα3 / EI # rad

# ╔═╡ 0ce3368c-17ce-4187-9961-37a4cecefa34
α1 = SymPy.simplify(α3(BC31...)) 

# ╔═╡ 20d3d42b-cb8c-4263-956a-8211292b81ba
α = α1(deel1...) + α1(deel2...) + α2(deel3...) + α2(deel4...)

# ╔═╡ 28c28e03-76a9-48fd-b68f-121be0d1b74f
EIv3 = v3_(opl3...)

# ╔═╡ 34ff7b5b-77a9-4793-8a21-baf3a23c2b95
v3 = EIv3 / EI # volgens gekozen lengteenheid

# ╔═╡ d5e3126e-74fb-4f5c-a140-8cf033122adb
v1 = SymPy.simplify(v3(BC31...)) # volgens gekozen lengteenheid

# ╔═╡ 3bbe41e1-b5ca-4b4b-a6e5-1f5449ab2178
v = v1(deel1...) + v1(deel2...) + v2(deel3...) + v2(deel4...)

# ╔═╡ b2a214ad-de66-4ceb-8827-f7229912529c
R3_opl = solve(Eq(v(t=>x_steun),0), [R3]) |> first # Los op naar R3

# ╔═╡ d0ac941f-aba4-4384-8fd8-c5c66ec2bb43
vergelijking = rvw -> Eq.(
	v(
		t=>x_steun, # Evalueer de vervorming ter hoogte van x_steun
		Dict(collect(keys(rvw)) .|> eval .=> collect(values(rvw)))...,
		EI=>buigstijfheid # Substitueer de buigstijfheid van de balk
	),
	R3 ./ (k * [1/sqrt(2), 1, oo]) # De vervorming ter hoogte van de steun (t=x_steun) = R3 / k met k = EA/L
)

# ╔═╡ 463975d9-aae8-4f6d-ae34-2477acf6a9cc
rvw_volledig = DataFrames.flatten(
	select(rvw, : , AsTable(DataFrames.Not(:check)) => 
		ByRow(
			r -> solve.(vergelijking(r), [R3]) .|> (N ∘ first)
		) => :R3
	),
	:R3
)

# ╔═╡ b91ad51c-f9f7-4236-8040-1959533f1793
opl = select(rvw_volledig, :, AsTable(DataFrames.Not(:check)) => 
	ByRow(r -> 
		fn(r).([V,M,α,v])) => [:V, :M, :α, :v]
)

# ╔═╡ 40fe2709-43b6-419c-9acb-2b2763345811
overzicht = combine(
	groupby(
		select(opl, :check, :L,
			AsTable(:) => ByRow(r -> [
					r.V.(0:0.1:geom[:L]),
					r.M.(0:0.1:geom[:L]),
					r.α.(0:0.1:geom[:L]),
					r.v.(0:0.1:geom[:L])
			] .|> (rnd ∘ extrema)) => [:V, :M, :α, :v]
		),
		[:check, :L]
	),
	AsTable([:V, :M, :α, :v]) => (
		r -> NamedTuple{keys(r)}(
			extrema.(
				Iterators.flatten.(values(r))
			)
		)
	) => [:V, :M, :α, :v]
)

# ╔═╡ 882a3f47-b9f0-4a92-98b2-881f8ce84f6d
overzicht

# ╔═╡ 6fd851f5-87f8-402c-ab64-004251404491
begin 
	controle_ggt_check2 = true
	controle_ggt_check2 = abs(minimum(overzicht[isGGT, :v][1])) <= 5/500
	controle_ugt_check1 = true
	md"""
	### Controle
	Controle van de voorwaarden in **GGT** en **UGT**. Bepalend zijn in het desbetreffende geval de doorsnedecontroles in **GGT**. Geen stabiliteitscontrole (*Torsional Lateral Buckling*, *Web Crippling*, ...) zijn momenteel uitgevoerd.

	Definitie (zie ook `NBN B03-003`):
	-  $\delta_{0}$: tegenpijl balk in onbelaste toestand
	-  $\delta_{1}$: ogenblikkelijke verandering t.g.v. perm. belastingen
	-  $\delta_{2}$: toename onder invloed van variabele belsting (kar. geval)
	-  $\delta_{max} = \delta_{1} + \delta_{2} - \delta_{0}$

	Controles in **GGT**
	1. **Check 1**: Max 80% van $f_{yd}$ in de meest getrokken/gedrukte vezel
	2. **Check 2**: Vervormingen van de ligger beperkt tot $L/500$ voor $\delta_{2}$ en $L/400$ voor $\delta_{max}$. 
	   - Toegelaten vervorming $v_{lim}$ en optredende $v_{max}$ in **GGT** Karakteristiek

	Controles in **UGT**
	3. **Check 3**: Doorsnedecontrole $UC = \dfrac{M_{Ed}}{M_{Rd}}$ met $M_{Rd} = W_{el;y}\ f_{yd}$ 
	3. **Check 4**: Dwarskrachtcontrole $UC = \dfrac{V_{Ed}}{V_{Rd}}$ met $V_{Rd} = A_{V}\ \dfrac{f_{yd}}{\sqrt{3}}$ 
	"""
end

# ╔═╡ e4e895b7-19f4-4eb5-9536-c1a729fd8fcf
controles = DataFrames.stack(
	select(overzicht, 
		:check, 
		AsTable(:) => 
			ByRow(controle) => ["Check $i" for i in 1:4]
	), 
	DataFrames.Not(:check), 
	:check, 
	variable_name="nummer", 
	value_name="unity check"
) |> dropmissing

# ╔═╡ 8703a7d1-2838-4c98-8b93-1d4af8cf2b21
controles

# ╔═╡ 64063bd8-e592-425e-87c1-ed9e96db24a9
grafieken = combine(
	groupby(opl, :check), 
	AsTable([:V, :M, :α, :v]) => (
		r -> NamedTuple{(:V, :M, :α, :v)}(minmax.(collect(pairs(r))))
	) => [:V, :M, :α, :v]
)

# ╔═╡ e5f707ce-54ad-466e-b6a6-29ad77168590
grafieken

# ╔═╡ 38db521f-f478-459e-83f7-6a7dbbd5568a
md"""
### Voorbeelden
"""

# ╔═╡ 8a382890-6b33-478e-abd6-cc0aa079f8d2
begin
	value_p = @bind _p Scrubbable(0:50, default=2)
	md"""
	Waarde voor $p$: $value_p kN/m
	"""
end

# ╔═╡ b0cb9a50-a7e2-48ef-ae7d-431d04a7e055
BC1 = a => 1, b => 3, L => 5, p => _p, EI => buigstijfheid

# ╔═╡ 4c329718-55a7-415c-91e0-a2e0199169de
md"""
#### Vb. Schema 1 - Verdeelde belasting $p$

Verdeelde belasting volgens $BC1
"""

# ╔═╡ 8a01cacf-e69a-48bb-ab25-cc0cd3f77071
begin
	plot(0:0.1:5, V1(BC1...), label="Dwarskracht [kN]", legend=false)
	plot!(0:0.1:5, M1(BC1...), label="Moment [kNm]")
	plot!(0:0.1:5, α1(BC1...) .* 1000, line = (1, :dashdot), label="Hoekverdraaiing [mrad]")
	plot!(0:0.1:5, v1(BC1...) .* 1000, line = (1, :dashdot), label="Doorbuiging [mm]")
end

# ╔═╡ dbd3985e-0c0f-41f0-9361-859fd7f2ea6c
begin
	value_F = @bind _F Scrubbable(0:200, default=50)
	value_a = @bind _a Scrubbable(0:0.01:5, default=2)
	md"""
	Waarde voor $a$: $value_a m
	
	Waarde voor $F$: $value_F kN
	"""
end

# ╔═╡ 2c9b754b-4632-460e-866e-54e1b6d8e0e7
BC2 = a => _a, L => 5, F => _F, EI => buigstijfheid

# ╔═╡ 741caaac-8f2b-4e64-a15d-d363382b6e3f
md"""
#### Vb. Schema 2 - Puntbelasting $F$

Puntbelasting volgens $BC2
"""

# ╔═╡ 5d6c0fb3-0dd1-427b-b732-b387640cb9f3
begin
	plot(0:0.1:5, V2(BC2...), label="Dwarskracht [kN]", legend=false)
	plot!(0:0.1:5, M2(BC2...), label="Moment [kNm]")
	plot!(0:0.1:5, α2(BC2...) .* 1000, line = (1, :dashdot), label="Hoekverdraaiing [mrad]")
	plot!(0:0.1:5, v2(BC2...) .* 1000, line = (1, :dashdot), label="Doorbuiging [mm]")
end

# ╔═╡ a1fd525b-5d0e-4164-9d20-f8741053f35e
begin
	value_p_a = @bind _p_a Scrubbable(0:100, default=10)
	value_p_b = @bind _p_b Scrubbable(0:100, default=15)
	md"""
	Waarde voor $p_a$: $value_p_a kN
	
	Waarde voor $p_b$: $value_p_b kN
	"""
end

# ╔═╡ 95e4a0fb-da8a-4e3c-a0d0-214d559ad90e
BC3 = a => 1, b => 3, L => 5, p_a => _p_a, p_b => _p_b, EI => buigstijfheid

# ╔═╡ 69ff9357-edf4-4045-9151-9bb9fbf92492
md"""
#### Vb. Schema 3 - Lineair variërende lijnbelasting $p_a$ tot $p_b$

Puntbelasting volgens $BC3
"""

# ╔═╡ 4534935a-001b-4b3f-8843-f9574f5b06aa
begin
	plot(0:0.1:5, V3(BC3...), label="Dwarskracht [kN]", legend=false)
	plot!(0:0.1:5, M3(BC3...), label="Moment [kNm]")
	plot!(0:0.1:5, α3(BC3...) .* 1000, line = (1, :dashdot), label="Hoekverdraaiing [mrad]")
	plot!(0:0.1:5, v3(BC3...) .* 1000, line = (1, :dashdot), label="Doorbuiging [mm]")
end

# ╔═╡ 0be51e3f-ed13-46c1-921a-ab20aa707595
md"""
#### 3.4 Samenstel krachten

Samenstel van krachten uit **3.1**, **3.2** en **3.3**
"""

# ╔═╡ f0418f1f-3dab-4b1f-8a18-6d8ddcf07523
begin
	_Vcombined = V1(BC1...) + V2(BC2...) + V3(BC3...)
	_Mcombined = M1(BC1...) + M2(BC2...) + M3(BC3...)
	_αcombined = α1(BC1...) + α2(BC2...) + α3(BC3...)
	_vcombined = v1(BC1...) + v2(BC2...) + v3(BC3...)
	plot(0:0.1:5, _Vcombined, label="Dwarskracht [kN]", legend=false)
	plot!(0:0.1:5, _Mcombined, label="Moment [kNm]")
	plot!(0:0.1:5, _αcombined .* 1000, line = (1, :dashdot), label="Hoekverdraaiing [mrad]")
	plot!(0:0.1:5, _vcombined .* 1000, line = (1, :dashdot), label="Doorbuiging [mm]")
end



# ╔═╡ bf202301-c645-4698-b931-6626758c569a
md"## Theorie"

# ╔═╡ 5f8aab19-c664-4460-8737-0e9c6a758a4a
md"""
### Virtuele arbeid

> Virturele **rek**
>    
> Op een infinitesimaal deeltje van een staaf $dx$ worden uitwendige normaalkrachten $n$ opgelegd. Indien er geen samengang in het materiaal zou bestaan, dan wordt het mootje uiteengereten. Een virtuele, axiale verplaatsing $\delta u$ wordt opgelegd, en een vervorming $(\delta x)'$ of $d\delta x/dx$ wat ook wel gelijk is aan $\delta \varepsilon$ (virtuele **rek**) wordt aan de rechterzijde opgeteld bij de translatie.
>
> $-n\ \delta u + n\ (\delta u + \delta \varepsilon\ dx) + \displaystyle\sum_{i} \overrightarrow{R_i}\ \delta\overrightarrow{u_i} = 0$  

> Virturele **kromming**
>    
> Op een infinitesimaal deeltje van een staaf $dx$ worden uitwendige krachtenkoppel $m$ opgelegd. Indien er geen samengang in het materiaal zou bestaan, dan wordt het mootje uiteengereten. Een virtuele, axiale rotatie $\delta \alpha$ wordt opgelegd, en een vervorming $(\delta \alpha)'$ of $d\delta \alpha/dx$ wat ook wel gelijk is aan $\delta \chi$ (virtuele **kromming**) wordt aan de rechterzijde van de moot opgeteld bij de rotatie.
>
> $-m\ \delta \alpha + m\ (\delta \alpha + \delta \chi\ dx) + \displaystyle\sum_{i} \overrightarrow{R_i}\ \delta\overrightarrow{u_i} = 0$  

"""

# ╔═╡ 64dafd98-afca-45b3-9aad-5697a4edc08e
md"""
Wens je bijvoorbeeld het moment te kennen ten gevolge van een last $F$, dan pas je het principe van virtuele arbeid toe waarbij je snijdt ter hoogte van het aangrijpingspunt van $F$ en dit vervangt door een koppel met waarde $M$ en een scharnier. De vervormingen zijn klein. De virtuele verplaatsing in $C$ is gelijk aan $x$. Volgend evenwicht schrijven we uit.

$$F\cdot x = M\ \delta\theta_{AC} + M\ \delta\theta_{CB}$$

Omdat de vervormingen klein zijn, kunnen we volgende hanteren:

$$\delta\theta_{AC} = \arctan\left(\dfrac{x}{|AC|}\right) \stackrel{\text{kleine vervormingen}}{\approx} \dfrac{x}{|AC|}$$

Dus vergelijking kan omgevormd tot volgende oplossing:

$$F\cdot x = M\ \dfrac{x}{|AC|} + M\ \dfrac{x}{|CB|} = M\cdot x\ \left(\dfrac{1}{|AC|} + \dfrac{1}{|CB|}\right)$$

Vervang $|AC|$ door $a$ en $|CB|$ door $b$ en los op naar $M$:

$$M = F\cdot \dfrac{a\ b}{a + b}$$

"""

# ╔═╡ d53c7125-c433-452a-bbf6-06aa43b756f3
@drawsvg begin
	sethue("black")
	endpoints = (-200, -50), (200, -50)
	breakpoint = (-50, 0)
	projection = (breakpoint[1], 0)
	points1 = Point.(sort(collect(endpoints)))
	points2 = Point.(sort(collect((endpoints..., breakpoint)))) .+ Point(0, 50)
	@layer (
		fontsize(20);
		poly(points1, :stroke);
		circle.(points1, 4, :fill);
		Luxor.arrow(Point(-50, -110), Point(-50, -60));
		Luxor.label("F", :E, Point(-50, -110), offset=5);
		Luxor.arrow(Point(-50, 5), Point(-50, 45));
		Luxor.label("x", :SE, Point(-50, 10), offset=5);
		Luxor.label.(["A", "B"], [:NW,:NE] , points1, offset=10);
		Luxor.label.(["A", "C", "B"], [:NW,:S,:NE] , points2, offset=10);
	)
	@layer (
		setdash("shortdashed");
		poly(points1 .+ Point(0, 50), :stroke);
		setdash("solid");
		poly(points2, :stroke);
		Luxor.arrow(points2[1], 80, 0, π/10);
		fontsize(14);
		Luxor.label("δθ", :SE, points2[1] + Point(80, 0), offset=10);
		sethue("firebrick"); 
		circle.(points2, 4, :fill)
	)
	@layer (
		sethue("firebrick");
		Luxor.arrow(points2[2] - Point(60, 0), 40, -π/4, π/4);
		Luxor.scale(-1, 1);
		Luxor.arrow(Point((-1, 1) .* (breakpoint .- (-60, -50))), 40, -π/4, π/4);
	)
end (800) (300)

# ╔═╡ eb54b362-4f84-405d-8414-ef35ede5d7de
md"Afhankelijk van het gegeven die je zoekt, ga je anders gaan snijden in je constructie"

# ╔═╡ 0b786728-2437-4d7f-aa68-b911c145699a
md"""### Integralen en analogiëen van *Mohr*

!!! warning "Bereking volgens KOORDE"
	Bij de integralen van *Mohr* wordt de hoekverdraaiing en de vervorming berekend volgens een koorde tussen twee punten (dus onafh. van de elastica)

> Berekenen **doorbuiging** ten opzichte van een koorde
> 1. Gereduceerd momentenvlak of kromming: $\chi = \dfrac{M}{\text{EI}}$
> 2. Doorbuiging $a$ in punt $P$ t.o.v. koorde $AB$
> 3. Stel **hulplichaam** op met lengte = koorde $AB$, eenvoudig opgelegd
> 4. Belast hulplichaam met kracht $q = \dfrac{M}{\text{EI}}$
> 5. Bereken **moment** hulplichaam in $P$
> Definitie: *De verticale verplaatsing van een punt $P$, gelegen tussen de punten $A$ en $B$ van een al dan niet doorgaande, al dan niet prismatische balk, en gemeten ten opzichte van de koorde $AB$ in de belaste en dientengevolge vervormde stand, is gelijk aan het buigend moment in het punt $P$ van een eenvoudig opgelegde hulpligger $AB$, die een fictieve, gespreide belasting draagt, waarvan de amplitude in ieder punt gelijk is aan het plaatselijke, gereduceerde moment in het oospronkelijk gestel.*

> Berekenen **hoekverdraaiing** ten opzichte van een koorde
> 1. Gereduceerd momentenvlak of kromming: $\chi = \dfrac{M}{\text{EI}}$
> 2. Hoekverdraaiing $a$ in punt $P$ t.o.v. koorde $AB$
> 3. Stel **hulplichaam** op met lengte = koorde $AB$, eenvoudig opgelegd
> 4. Belast hulplichaam met kracht $q = \dfrac{M}{\text{EI}}$
> 5. Bereken **dwarskracht** hulplichaam in $P$
> Definitie: *De wenteling van de raaklijn in een punt $P$, gelegen tussen de punten $A$ en $B$ van een al dan niet doorgaande, al dan niet prismatische balk, en gemeten ten opzichte van de koorde $AB$ in de belaste en dientengevolge vervormde stand, is op het teken na gelijk aan de dwarskracht in het punt $P$ van een eenvoudig opgelegde hulpligger $AB$, die een fictieve, gespreide belasting draagt, waarvan de amplitude in ieder punt gelijk is aan het plaatselijke, gereduceerde moment in het oorspronkelijke gestel.*
"""

# ╔═╡ ee7c93aa-73c9-4f46-8ac1-5898a3bf61bf
md"""
### Stelling van *Green*

!!! warning "Bereking volgens RAAKLIJN"
	Bij de stelling van *Green* wordt de hoekverdraaiing en de vervorming berekend volgens een raaklijn in een bepaald punt van de elastica

> Elastische **verticale verplaatsing** van een doorsnede ten opzichte van de raaklijn aan de elastica in een andere doorsnede
> 1. Gereduceerd momentenvlak of kromming: $\chi = \dfrac{M}{\text{EI}}$
> 2. Verplaatsing $a$ in punt $P$ t.o.v. doorsnede $A$
> 3. Stel **hulplichaam** op met lengte = koorde $AP$, ingeklemd in $A$
> 4. Belast hulplichaam met kracht $q = \dfrac{M}{\text{EI}}$
> 5. Bereken het **moment** in $A$ van het hulplichaam
> Definitie: *Om de elastische doorbuiging van een doorsnede $P$ ten opzichte van de raaklijn aan de elastica in een andere doorsnede $A$ te bepalen, neemt men het statisch moment van het gereduceerde momentenvlak tussen $A$ en $P$ om het punt waar men de verplaatsing wenst te kennen.*

> Elastische **draaiing** van een doorsnede ten opzichte van de raaklijn aan de elastica in een andere doorsnede
> 1. Gereduceerd momentenvlak of kromming: $\chi = \dfrac{M}{\text{EI}}$
> 2. Draaiing $\theta$ in punt $P$ t.o.v. doorsnede $A$
> 3. Stel **hulplichaam** op met lengte = koorde $AP$, ingeklemd in $A$
> 4. Belast hulplichaam met kracht $q = \dfrac{M}{\text{EI}}$
> 5. Bereken het **dwarskracht** in $A$ van het hulplichaam / oppervlakte onder het gereduceerde momentenvlak
> Definitie: *De elastische draaiing van een doorsnede van een balk ten opzichte van een andere doorsnede wordt gegeven door de oppervlakte van het gereduceerde momentenvlak begrepen tussen beide doorsneden.*
"""

# ╔═╡ a9aeee4c-c0d6-45cc-8b2d-03fcfdee8e37
md"""
### Doorbuiging door dwarskrachten

!!! danger "Bijkomende doorbuiging t.g.v. dwarskrachten"
	**Schuifspanningen** $\tau_{xy}$ zijn vergezeld van glijdingen $\gamma_{xy} = \tau_{xy}\ /\ G$ → deze zijn **maximaal** t.h.v. de **staafas**, waarbij $\tau_{max}$ gelijk is aan $\dfrac{V_y\ S_{max}}{e_0\ I_z}$ met $S_{max}$ gelijk aan het statisch moment rond de staafas en $e_0$ de breedte ter hoogte van de staafas. 
"""

# ╔═╡ febed0ae-59eb-4820-b237-81612ca5ac19
@drawsvg begin
	sethue("black")
	Luxor.translate(-100, 0)
	Luxor.rect(0 ,0 ,200 ,50 , :stroke)
	@layer (
		fontsize(16);
		Luxor.translate(0, 50);
		Luxor.arrow(Point(240, -25), Point(240, -90));
		Luxor.label("dv₁", :E, Point(240, -55), offset=5);
		Luxor.arrow(Point(0, 20), Point(200, 20));
		Luxor.label("dx", :S, Point(100, 20), offset=10);
		Luxor.arrow(Point(-20, -50), Point(-20, 0));
		Luxor.label("Vy", :W, Point(-20, -25), offset=5);
		Luxor.arrow(Point(220, 0), Point(220, -50));
		Luxor.label("Vy", :E, Point(220, -15), offset=5);
	)
	@layer (
		setdash("dotted");
		Luxor.transform([1, -0.3, 0, 1, 0, 0]);
		Luxor.rect(0 ,0 ,200 ,50 , :stroke);
	)
end (800) (200)

# ╔═╡ 2cd45cb4-ba74-4a54-8f3e-8cdf2223c8e9
md"""
Uitschrijven van bovenstaande vervorming waarbij de doorbuiging $v_1$ een gevolg is van de dwarskracht $V_y$

$\dfrac{dv_1}{dx}=\gamma=\dfrac{\lambda\ V_y}{G\ A}=-\dfrac{\lambda}{G\ A}\cdot\dfrac{dM_z}{dx}$

Bij een prismatische doorsnede resulteert dit in:

$\dfrac{d^2v}{dx^2}=\dfrac{M_z}{EI_z}+\dfrac{d^2v_1}{dx^2}=\dfrac{M_z}{EI_z}+\dfrac{\lambda\ p}{G\ A}$

**Mohr** en **Greene**: analogieën van *Mohr* en stelling van *Greene* nog steeds toepasbaar, mits het gereduceerd moment wordt vervangen door bovenstaande formulering.
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Conda = "8f4d0f93-b110-5947-807f-2305c1781a2d"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
DotEnv = "4dc1fcf4-5e3b-5448-94ab-0c38ec0385c1"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
ImageView = "86fae568-95e7-573e-a6b2-d8a6b900c9ef"
Images = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
Luxor = "ae8d54c2-7ccd-5906-9d76-62fc9837b5bc"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PyCall = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"
Roots = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
SQLite = "0aa819cd-b072-5ff4-a722-6bc24af294d9"
SymPy = "24249f21-da20-56a4-8eb1-6a02cf4ae2e6"
UUIDs = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
Underscores = "d9a01c3f-67ce-4d8c-9b55-35f6e4050bb1"

[compat]
Conda = "~1.5.2"
DataFrames = "~1.2.0"
DotEnv = "~0.3.1"
HTTP = "~0.9.12"
ImageView = "~0.10.13"
Images = "~0.23.3"
JSON = "~0.21.1"
Luxor = "~2.13.0"
Plots = "~1.18.1"
PlutoUI = "~0.7.9"
PyCall = "~1.92.3"
Roots = "~1.0.9"
SQLite = "~1.1.4"
SymPy = "~1.0.49"
Underscores = "~2.0.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ATK_jll]]
deps = ["Artifacts", "Glib_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "a5a8f114e4d70bee6cf82ed28b488d57f1fa9467"
uuid = "7b86fcea-f67b-53e1-809c-8f1719c154e8"
version = "2.36.0+0"

[[AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "485ee0867925449198280d4af84bdb46a2a404d0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.0.1"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[ArrayInterface]]
deps = ["IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "045ff5e1bc8c6fb1ecb28694abba0a0d55b5f4f5"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "3.1.17"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "a4d07a1c313392a77042855df46c5f534076fab9"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.0"

[[AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "f31f50712cbdf40ee8287f0443b57503e34122ef"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.3"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BinaryProvider]]
deps = ["Libdl", "Logging", "SHA"]
git-tree-sha1 = "ecdec412a9abc8db54c0efc5548c64dfce072058"
uuid = "b99e7846-7c00-51b0-8f62-c81ae34c0232"
version = "0.5.10"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c3598e525718abcc440f69cc6d5f60dda0a1b61e"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.6+5"

[[Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "d0b3f8b4ad16cb0a2988c6788646a5e6a17b6b1b"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.0.5"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "e2f47f6d8337369411569fd45ae5753ca10394c6"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.0+6"

[[CatIndices]]
deps = ["CustomUnitRanges", "OffsetArrays"]
git-tree-sha1 = "a0f80a09780eed9b1d106a1bf62041c2efc995bc"
uuid = "aafaddc9-749c-510e-ac4f-586e18779b91"
version = "0.2.2"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "dcc25ff085cf548bc8befad5ce048391a7c07d40"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "0.10.11"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random", "StaticArrays"]
git-tree-sha1 = "ed268efe58512df8c7e224d2e170afd76dd6a417"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.13.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "32a2b8af383f11cbb65803883837a149d10dfe8a"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.10.12"

[[ColorVectorSpace]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "StatsBase"]
git-tree-sha1 = "4d17724e99f357bfd32afa0a9e2dda2af31a9aea"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.8.7"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[CommonSolve]]
git-tree-sha1 = "68a0743f578349ada8bc911a5cbd5a2ef6ed6d1f"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.0"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "dc7dedc2c2aa9faf59a55c622760a25cbefbe941"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.31.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[ComputationalResources]]
git-tree-sha1 = "52cb3ec90e8a8bea0e62e275ba577ad0f74821f7"
uuid = "ed09eef8-17a6-5b46-8889-db040fac31e3"
version = "0.3.2"

[[Conda]]
deps = ["JSON", "VersionParsing"]
git-tree-sha1 = "299304989a5e6473d985212c28928899c74e9421"
uuid = "8f4d0f93-b110-5947-807f-2305c1781a2d"
version = "1.5.2"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[CoordinateTransformations]]
deps = ["LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "6d1c23e740a586955645500bbec662476204a52c"
uuid = "150eb455-5306-5404-9cee-2592286d6298"
version = "0.6.1"

[[Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[CustomUnitRanges]]
git-tree-sha1 = "537c988076d001469093945f3bd0b300b8d3a7f3"
uuid = "dc8bdbbb-1ca9-579f-8c36-e416f6a65cce"
version = "1.0.1"

[[DBInterface]]
git-tree-sha1 = "d3e9099ef8d63b180a671a35552f93a1e0250cbb"
uuid = "a10d1c49-ce27-4219-8d33-6db1a4562965"
version = "2.4.1"

[[DataAPI]]
git-tree-sha1 = "ee400abb2298bd13bfc3df1c412ed228061a2385"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.7.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "1dadfca11c0e08e03ab15b63aaeda55266754bad"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.2.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "4437b64df1e0adccc3e5d1adbc3ac741095e4677"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.9"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[Dbus_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "97f1325c10bd02b1cc1882e9c2bf6407ba630ace"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.12.16+3"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distances]]
deps = ["LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "abe4ad222b26af3337262b8afb28fab8d215e9f8"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.3"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "a32185f5428d3986f47c2ab78b1f216d5e6cc96f"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.5"

[[DotEnv]]
git-tree-sha1 = "d48ae0052378d697f8caf0855c4df2c54a97e580"
uuid = "4dc1fcf4-5e3b-5448-94ab-0c38ec0385c1"
version = "0.3.1"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "92d8f9f208637e8d2d28c664051a00569c01493d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.1.5+1"

[[EllipsisNotation]]
deps = ["ArrayInterface"]
git-tree-sha1 = "8041575f021cba5a099a456b4163c9a08b566a02"
uuid = "da5c29d0-fa7d-589e-88eb-ea29b0a81949"
version = "1.1.0"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "LibVPX_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "3cc57ad0a213808473eafef4845a74766242e05f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.3.1+4"

[[FFTViews]]
deps = ["CustomUnitRanges", "FFTW"]
git-tree-sha1 = "70a0cfd9b1c86b0209e38fbfe6d8231fd606eeaf"
uuid = "4f61f5a4-77b1-5117-aa51-3ab5ef4ef0cd"
version = "0.3.1"

[[FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "f985af3b9f4e278b1d24434cbb546d6092fca661"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.4.3"

[[FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3676abafff7e4ff07bbd2c42b3d8201f31653dcc"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.9+8"

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "256d8e6188f3f1ebfa1a5d17e072a0efafa8c5bf"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.10.1"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "35895cf184ceaab11fd778b4590144034a167a2f"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.1+14"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "cbd58c9deb1d304f5a245a0b7eb841a2560cfec6"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.1+5"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "dba1e8614e98949abfa60480b13653813d8f0157"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+0"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "b83e3125048a9c3158cbb7ca423790c7b1b57bea"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.57.5"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "e14907859a1d3aee73a019e7b3c98e9e7b8b5b3e"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.57.3+0"

[[GTK3_jll]]
deps = ["ATK_jll", "Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Libepoxy_jll", "Pango_jll", "Pkg", "Wayland_jll", "Xorg_libX11_jll", "Xorg_libXcomposite_jll", "Xorg_libXcursor_jll", "Xorg_libXdamage_jll", "Xorg_libXext_jll", "Xorg_libXfixes_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "Xorg_libXrender_jll", "at_spi2_atk_jll", "gdk_pixbuf_jll", "iso_codes_jll", "xkbcommon_jll"]
git-tree-sha1 = "1f92baaf9e9cdfaa59e0f9384b7fbdad6b735662"
uuid = "77ec8976-b24b-556a-a1bf-49a033a670a6"
version = "3.24.29+0"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "15ff9a14b9e1218958d3530cc288cf31465d9ae2"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.3.13"

[[Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "47ce50b742921377301e15005c96e979574e130b"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.1+0"

[[Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "2c1cf4df419938ece72de17f368a021ee162762e"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.0"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[Gtk]]
deps = ["Cairo", "Cairo_jll", "Dates", "GTK3_jll", "Glib_jll", "Graphics", "Libdl", "Pkg", "Reexport", "Serialization", "Test", "Xorg_xkeyboard_config_jll", "adwaita_icon_theme_jll", "gdk_pixbuf_jll", "hicolor_icon_theme_jll"]
git-tree-sha1 = "50ab2805b59d448d4780f7b564c6054f657350c3"
uuid = "4c0ca9eb-093a-5379-98c5-f87ac0bbbf44"
version = "1.1.8"

[[GtkReactive]]
deps = ["Cairo", "Colors", "Dates", "FixedPointNumbers", "Graphics", "Gtk", "IntervalSets", "Reactive", "Reexport", "RoundingIntegers"]
git-tree-sha1 = "2a82c9204afbd8bfb39c0d6735bface4a3df9917"
uuid = "27996c0f-39cd-5cc1-a27a-05f136f946b6"
version = "1.0.5"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "c6a1fff2fd4b1da29d3dccaffb1e1001244d844e"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.12"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "8a954fed8ac097d5be04921d595f741115c1b2ad"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+0"

[[IdentityRanges]]
deps = ["OffsetArrays"]
git-tree-sha1 = "be8fcd695c4da16a1d6d0cd213cb88090a150e3b"
uuid = "bbac6d45-d8f3-5730-bfe4-7a449cd117ca"
version = "0.3.1"

[[IfElse]]
git-tree-sha1 = "28e837ff3e7a6c3cdb252ce49fb412c8eb3caeef"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.0"

[[ImageAxes]]
deps = ["AxisArrays", "ImageCore", "Reexport", "SimpleTraits"]
git-tree-sha1 = "794ad1d922c432082bc1aaa9fa8ffbd1fe74e621"
uuid = "2803e5a7-5153-5ecf-9a86-9b4c37f5f5ac"
version = "0.6.9"

[[ImageContrastAdjustment]]
deps = ["ColorVectorSpace", "ImageCore", "ImageTransformations", "Parameters"]
git-tree-sha1 = "2e6084db6cccab11fe0bc3e4130bd3d117092ed9"
uuid = "f332f351-ec65-5f6a-b3d1-319c6670881a"
version = "0.3.7"

[[ImageCore]]
deps = ["AbstractFFTs", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "db645f20b59f060d8cfae696bc9538d13fd86416"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.8.22"

[[ImageDistances]]
deps = ["ColorVectorSpace", "Distances", "ImageCore", "ImageMorphology", "LinearAlgebra", "Statistics"]
git-tree-sha1 = "6378c34a3c3a216235210d19b9f495ecfff2f85f"
uuid = "51556ac3-7006-55f5-8cb3-34580c88182d"
version = "0.2.13"

[[ImageFiltering]]
deps = ["CatIndices", "ColorVectorSpace", "ComputationalResources", "DataStructures", "FFTViews", "FFTW", "ImageCore", "LinearAlgebra", "OffsetArrays", "Requires", "SparseArrays", "StaticArrays", "Statistics", "TiledIteration"]
git-tree-sha1 = "bf96839133212d3eff4a1c3a80c57abc7cfbf0ce"
uuid = "6a3955dd-da59-5b1f-98d4-e7296123deb5"
version = "0.6.21"

[[ImageMagick]]
deps = ["FileIO", "ImageCore", "ImageMagick_jll", "InteractiveUtils", "Libdl", "Pkg", "Random"]
git-tree-sha1 = "5bc1cb62e0c5f1005868358db0692c994c3a13c6"
uuid = "6218d12a-5da1-5696-b52f-db25d2ecc6d1"
version = "1.2.1"

[[ImageMagick_jll]]
deps = ["JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pkg", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "1c0a2295cca535fabaf2029062912591e9b61987"
uuid = "c73af94c-d91f-53ed-93a7-00f77d67a9d7"
version = "6.9.10-12+3"

[[ImageMetadata]]
deps = ["AxisArrays", "ColorVectorSpace", "ImageAxes", "ImageCore", "IndirectArrays"]
git-tree-sha1 = "ae76038347dc4edcdb06b541595268fca65b6a42"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.5"

[[ImageMorphology]]
deps = ["ColorVectorSpace", "ImageCore", "LinearAlgebra", "TiledIteration"]
git-tree-sha1 = "68e7cbcd7dfaa3c2f74b0a8ab3066f5de8f2b71d"
uuid = "787d08f9-d448-5407-9aad-5290dd7ab264"
version = "0.2.11"

[[ImageQualityIndexes]]
deps = ["ColorVectorSpace", "ImageCore", "ImageDistances", "ImageFiltering", "OffsetArrays", "Statistics"]
git-tree-sha1 = "1198f85fa2481a3bb94bf937495ba1916f12b533"
uuid = "2996bd0c-7a13-11e9-2da2-2f5ce47296a9"
version = "0.2.2"

[[ImageShow]]
deps = ["Base64", "FileIO", "ImageCore", "Requires"]
git-tree-sha1 = "c9df184bc7c2e665f971079174aabb7d18f1845f"
uuid = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
version = "0.2.3"

[[ImageTransformations]]
deps = ["AxisAlgorithms", "ColorVectorSpace", "CoordinateTransformations", "IdentityRanges", "ImageCore", "Interpolations", "OffsetArrays", "Rotations", "StaticArrays"]
git-tree-sha1 = "d966631de06f36c8cd4bec4bb2e8fa731db16ed9"
uuid = "02fcd773-0e25-5acc-982a-7f6622650795"
version = "0.8.12"

[[ImageView]]
deps = ["AxisArrays", "Cairo", "Graphics", "Gtk", "GtkReactive", "Images", "RoundingIntegers", "StatsBase"]
git-tree-sha1 = "0ff703f031fa7c63b110931b8fa49a287d62391e"
uuid = "86fae568-95e7-573e-a6b2-d8a6b900c9ef"
version = "0.10.13"

[[Images]]
deps = ["AxisArrays", "Base64", "ColorVectorSpace", "FileIO", "Graphics", "ImageAxes", "ImageContrastAdjustment", "ImageCore", "ImageDistances", "ImageFiltering", "ImageMetadata", "ImageMorphology", "ImageQualityIndexes", "ImageShow", "ImageTransformations", "IndirectArrays", "OffsetArrays", "Random", "Reexport", "SparseArrays", "StaticArrays", "Statistics", "StatsBase", "TiledIteration"]
git-tree-sha1 = "535bcaae047f017f4fd7331ee859b75f2b27e505"
uuid = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
version = "0.23.3"

[[IndirectArrays]]
git-tree-sha1 = "c2a145a145dc03a7620af1444e0264ef907bd44f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "0.5.1"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[Interpolations]]
deps = ["AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "1470c80592cf1f0a35566ee5e93c5f8221ebc33a"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.3"

[[IntervalSets]]
deps = ["Dates", "EllipsisNotation", "Statistics"]
git-tree-sha1 = "3cc368af3f110a767ac786560045dceddfc16758"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.5.3"

[[InvertedIndices]]
deps = ["Test"]
git-tree-sha1 = "15732c475062348b0165684ffe28e85ea8396afc"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.0.0"

[[IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "81690084b6198a2e1da36fcfda16eeca9f9f24e4"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.1"

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[Juno]]
deps = ["Base64", "Logging", "Media", "Profile"]
git-tree-sha1 = "07cb43290a840908a771552911a6274bc6c072c7"
uuid = "e5e0dc1b-0480-54bc-9374-aad01c23163d"
version = "0.8.4"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "c7f1c695e06c01b95a67f0cd1d34994f3e7db104"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.2.1"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a4b12a1bd2ebade87891ab7e36fdbce582301a92"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.6"

[[LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[LibVPX_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "12ee7e23fa4d18361e7c2cde8f8337d4c3101bc7"
uuid = "dd192d2f-8180-539f-9fb4-cc70b1dcf69a"
version = "1.10.0+0"

[[Libcroco_jll]]
deps = ["Artifacts", "Glib_jll", "JLLWrappers", "Libdl", "Pkg", "XML2_jll"]
git-tree-sha1 = "a8e3b1b67458c8933992b95db9c4b37865906e3f"
uuid = "57eb2189-7eb1-52c8-ac0e-99495f550b14"
version = "0.6.13+2"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libepoxy_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "aeac8ae441bc55be433ab53b729ffac274997320"
uuid = "42c93a91-0102-5b3f-8f9d-e41de60ac950"
version = "1.5.4+1"

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "761a393aeccd6aa92ec3515e428c26bf99575b3b"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+0"

[[Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[Librsvg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libcroco_jll", "Libdl", "Pango_jll", "Pkg", "gdk_pixbuf_jll"]
git-tree-sha1 = "af3e6dc6747e53a0236fbad80b37e3269cf66a9f"
uuid = "925c91fb-5dd6-59dd-8e8c-345e74382d89"
version = "2.42.2+3"

[[Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "340e257aada13f95f98ee352d316c3bed37c8ab9"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+0"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["DocStringExtensions", "LinearAlgebra"]
git-tree-sha1 = "7bd5f6565d80b6bf753738d2bc40a5dfea072070"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.2.5"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Luxor]]
deps = ["Base64", "Cairo", "Colors", "Dates", "FFMPEG", "FileIO", "ImageMagick", "Juno", "QuartzImageIO", "Random", "Rsvg"]
git-tree-sha1 = "6fcb3142ba8016b8af1692eb16c44ae07c803a7d"
uuid = "ae8d54c2-7ccd-5906-9d76-62fc9837b5bc"
version = "2.13.0"

[[MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "c253236b0ed414624b083e6b72bfe891fbd2c7af"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+1"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "6a8a2a625ab0dea913aba95c11370589e0239ff0"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.6"

[[MappedArrays]]
git-tree-sha1 = "18d3584eebc861e311a552cbb67723af8edff5de"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.0"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[Media]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "75a54abd10709c01f1b86b84ec225d26e840ed58"
uuid = "e89f7d12-3494-54d1-8411-f7d8b9ae1f27"
version = "0.5.0"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "4ea90bd5d3985ae1f9a908bd4500ae88921c5ce7"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.0"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "b34e3bc3ca7c94914418637cb10cc4d1d80d877d"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.3"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "2bf78c5fd7fa56d2bbf1efbadd45c1b8789e6f57"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.2"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7937eda4681660b4d6aeeecc2f7e1c81c8ee4e2f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+0"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "0fa5e78929aebc3f6b56e1a88cf505bb00a354c4"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.8"

[[Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9a336dee51d20d1ed890c4a8dca636e86e2b76ca"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.42.4+10"

[[Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "2276ac65f1e236e0a6ea70baff3f62ad4c625345"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.2"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "c8abc88faa3f7a3950832ac5d6e690881590d6dc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "1.1.0"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "501c20a63a34ac1d015d5304da0e645f42d91c9f"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.0.11"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs"]
git-tree-sha1 = "b93181645c1209d912d5632ba2d0094bc00703ad"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.18.1"

[[PlutoUI]]
deps = ["Base64", "Dates", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "Suppressor"]
git-tree-sha1 = "44e225d5837e2a2345e69a1d1e01ac2443ff9fcb"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.9"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "cde4ce9d6f33219465b55162811d8de8139c0414"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.2.1"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "0d1245a357cc61c8cd61934c07447aa569ff22e6"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.1.0"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[PyCall]]
deps = ["Conda", "Dates", "Libdl", "LinearAlgebra", "MacroTools", "Serialization", "VersionParsing"]
git-tree-sha1 = "169bb8ea6b1b143c5cf57df6d34d022a7b60c6db"
uuid = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"
version = "1.92.3"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

[[QuartzImageIO]]
deps = ["ColorVectorSpace", "FileIO", "ImageCore", "Libdl"]
git-tree-sha1 = "29c1803a9d6d1c7c2130610df5da953c49366976"
uuid = "dca85d43-d64c-5e67-8c65-017450d5d020"
version = "0.7.3"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

[[Ratios]]
git-tree-sha1 = "37d210f612d70f3f7d57d488cb3b6eff56ad4e41"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.0"

[[Reactive]]
deps = ["DataStructures", "Distributed", "Test"]
git-tree-sha1 = "5862d915387ebb954016f50a88e34f79a9e5fcd2"
uuid = "a223df75-4e93-5b7c-acf9-bdd599c0f4de"
version = "0.8.3"

[[RecipesBase]]
git-tree-sha1 = "b3fb709f3c97bfc6e948be68beeecb55a0b340ae"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.1"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "2a7a2469ed5d94a98dea0e85c46fa653d76be0cd"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.3.4"

[[Reexport]]
git-tree-sha1 = "5f6c21241f0f655da3952fd60aa18477cf96c220"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.1.0"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[Roots]]
deps = ["CommonSolve", "Printf"]
git-tree-sha1 = "4d64e7c43eca16edee87219b0b11f167f09c2d84"
uuid = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
version = "1.0.9"

[[Rotations]]
deps = ["LinearAlgebra", "StaticArrays", "Statistics"]
git-tree-sha1 = "2ed8d8a16d703f900168822d83699b8c3c1a5cd8"
uuid = "6038ab10-8711-5258-84ad-4b1120ba62dc"
version = "1.0.2"

[[RoundingIntegers]]
deps = ["Test"]
git-tree-sha1 = "293ba0ab32218b9ffd596040224228def84f8da0"
uuid = "d5f540fe-1c90-5db3-b776-2e2f362d9394"
version = "0.2.0"

[[Rsvg]]
deps = ["Cairo", "Glib_jll", "Librsvg_jll"]
git-tree-sha1 = "3d3dc66eb46568fb3a5259034bfc752a0eb0c686"
uuid = "c4c386cf-5103-5370-be45-f3a111cca3b8"
version = "1.0.0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[SQLite]]
deps = ["BinaryProvider", "DBInterface", "Dates", "Libdl", "Random", "SQLite_jll", "Serialization", "Tables", "Test", "WeakRefStrings"]
git-tree-sha1 = "97261d38a26415048ce87f49a7a20902aa047836"
uuid = "0aa819cd-b072-5ff4-a722-6bc24af294d9"
version = "1.1.4"

[[SQLite_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "9a0e24b81e3ce02c4b2eb855476467c7b93b8a8f"
uuid = "76ed43ae-9a5d-5a62-8c75-30186b810ce8"
version = "3.36.0+0"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "LogExpFunctions", "OpenSpecFun_jll"]
git-tree-sha1 = "a50550fa3164a8c46747e62063b4d774ac1bcf49"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.5.1"

[[StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[Static]]
deps = ["IfElse"]
git-tree-sha1 = "2740ea27b66a41f9d213561a04573da5d3823d4b"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.2.5"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "a43a7b58a6e7dc933b2fa2e0ca653ccf8bb8fd0e"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.6"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "2f6792d523d7448bbe2fec99eca9218f06cc746d"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.8"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "000e168f5cc9aded17b6999a560b7c11dda69095"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.0"

[[Suppressor]]
git-tree-sha1 = "a819d77f31f83e5792a76081eee1ea6342ab8787"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.0"

[[SymPy]]
deps = ["CommonSolve", "LinearAlgebra", "Markdown", "PyCall", "RecipesBase", "SpecialFunctions"]
git-tree-sha1 = "09bccb8575100ddd5d55e49e55c437380abe505b"
uuid = "24249f21-da20-56a4-8eb1-6a02cf4ae2e6"
version = "1.0.49"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "8ed4a3ea724dac32670b062be3ef1c1de6773ae8"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.4.4"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TiledIteration]]
deps = ["OffsetArrays"]
git-tree-sha1 = "52c5f816857bfb3291c7d25420b1f4aca0a74d18"
uuid = "06e1c1a7-607b-532d-9fad-de7d9aa2abac"
version = "0.3.0"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[Underscores]]
git-tree-sha1 = "986a17a99a20d2c588f12585ff32458140eb9603"
uuid = "d9a01c3f-67ce-4d8c-9b55-35f6e4050bb1"
version = "2.0.0"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[VersionParsing]]
git-tree-sha1 = "80229be1f670524750d905f8fc8148e5a8c4537f"
uuid = "81def892-9a0e-5fdd-b105-ffc91e053289"
version = "1.2.0"

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll"]
git-tree-sha1 = "2839f1c1296940218e35df0bbb220f2a79686670"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.18.0+4"

[[WeakRefStrings]]
deps = ["DataAPI", "Random", "Test"]
git-tree-sha1 = "28807f85197eaad3cbd2330386fac1dcb9e7e11d"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "0.6.2"

[[WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "59e2ad8fd1591ea019a5259bd012d7aee15f995c"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.3"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[Xorg_libXcomposite_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll"]
git-tree-sha1 = "7c688ca9c957837539bbe1c53629bb871025e423"
uuid = "3c9796d7-64a0-5134-86ad-79f8eb684845"
version = "0.4.5+4"

[[Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[Xorg_libXdamage_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll"]
git-tree-sha1 = "fe4ffb2024ba3eddc862c6e1d70e2b070cd1c2bf"
uuid = "0aeada51-83db-5f97-b67e-184615cfc6f6"
version = "1.1.5+4"

[[Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[Xorg_libXtst_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll", "Xorg_libXi_jll"]
git-tree-sha1 = "0c0a60851f44add2a64069ddf213e941c30ed93c"
uuid = "b6f176f1-7aea-5357-ad67-1d3e565ea1c6"
version = "1.2.3+4"

[[Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[adwaita_icon_theme_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "hicolor_icon_theme_jll"]
git-tree-sha1 = "37c9a36ccb876e02876c8a654f1b2e8c1b443a78"
uuid = "b437f822-2cd6-5e08-a15c-8bac984d38ee"
version = "3.33.92+5"

[[at_spi2_atk_jll]]
deps = ["ATK_jll", "Artifacts", "JLLWrappers", "Libdl", "Pkg", "XML2_jll", "Xorg_libX11_jll", "at_spi2_core_jll"]
git-tree-sha1 = "f16ae690aca4761f33d2cb338ee9899e541f5eae"
uuid = "de012916-1e3f-58c2-8f29-df3ef51d412d"
version = "2.34.1+4"

[[at_spi2_core_jll]]
deps = ["Artifacts", "Dbus_jll", "Glib_jll", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXtst_jll"]
git-tree-sha1 = "d2d540cd145f2b2933614649c029d222fe125188"
uuid = "0fc3237b-ac94-5853-b45c-d43d59a06200"
version = "2.34.0+4"

[[gdk_pixbuf_jll]]
deps = ["Artifacts", "Glib_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pkg", "Xorg_libX11_jll", "libpng_jll"]
git-tree-sha1 = "031f60d4362fba8f8778b31047491823f5a73000"
uuid = "da03df04-f53b-5353-a52f-6a8b0620ced0"
version = "2.38.2+9"

[[hicolor_icon_theme_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b458a6f6fc2b1a8ca74ed63852e4eaf43fb9f5ea"
uuid = "059c91fe-1bad-52ad-bddd-f7b78713c282"
version = "0.17.0+3"

[[iso_codes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "5ee24c3ae30e006117ec2da5ea50f2ce457c019a"
uuid = "bf975903-5238-5d20-8243-bc370bc1e7e5"
version = "4.3.0+4"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "acc685bcf777b2202a904cdcb49ad34c2fa1880c"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.14.0+4"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7a5780a0d9c6864184b3a2eeeb833a0c871f00ab"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "0.1.6+4"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "c45f4e40e7aafe9d086379e5578947ec8b95a8fb"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+0"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d713c1ce4deac133e3334ee12f4adff07f81778f"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2020.7.14+2"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "487da2f8f2f0c8ee0e83f39d13037d6bbf0a45ab"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.0.0+3"

[[xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╟─c4c79ab2-d6b7-11eb-09d0-e3cbf2c9d6e9
# ╟─d46d3ca7-d893-46c1-9ee7-1c88c9219a9e
# ╟─ece68d5e-1cb3-44e7-8c74-ca910d293ce9
# ╟─2a3d44ad-9ec2-4c21-8825-dbafb127f727
# ╟─c6f5a862-cae1-4e9c-a905-72a4122c11a7
# ╟─6a04789a-c42a-4ac9-8d05-ee20442ad60d
# ╟─31851342-e653-45c2-8df6-223593a7f942
# ╟─001ddb8b-3a71-48f8-adcc-a957741d57b1
# ╠═4ce3251e-f45c-4546-81b8-2e08d4ec9964
# ╟─a81fbf3e-f5c7-41c7-a71e-68f8a9589b45
# ╟─3e479359-d1a8-4036-8e9c-04317efde55a
# ╟─a45968e2-42a0-4307-bcf6-4ea559024799
# ╠═ab13bfac-70c7-4b36-ba3f-988a96555af5
# ╠═ba610d7b-89bf-4ed7-b4b5-4753e9ebc28d
# ╟─882a3f47-b9f0-4a92-98b2-881f8ce84f6d
# ╟─e5f707ce-54ad-466e-b6a6-29ad77168590
# ╟─8703a7d1-2838-4c98-8b93-1d4af8cf2b21
# ╟─542f69ac-77c5-47d7-be6c-94ba82a50ef7
# ╟─6fd851f5-87f8-402c-ab64-004251404491
# ╠═9364f897-0666-4ebe-9725-3c864db07b42
# ╠═b93d2ce0-ac8a-4487-9d1d-0300db4a9df8
# ╠═c46e9ee1-6fc4-476d-b77c-17c46ed5a09d
# ╠═fb4abf40-d5ee-490b-b2eb-89233d9b337a
# ╟─8f910bf3-5227-4113-9476-6136194a5e60
# ╟─c4df4b92-a3c6-43bd-a594-9d1f8c76015f
# ╟─ddeaf6b6-5e91-46fa-adf8-026bf6933dee
# ╟─3bb458cb-1a11-4102-b588-ab67cbcb28da
# ╟─99a918eb-1cf3-48fe-807b-3807c3189faa
# ╠═28e28737-8800-4d9f-a758-5640d14519b9
# ╠═d0ad3ac3-771c-4266-9564-38a836ab4df0
# ╠═97c8c6de-ed1b-42ba-8024-af8d86caf252
# ╠═54af6858-4010-493c-a730-2e1e14ec0aee
# ╠═d75d858b-33e2-45d4-9e60-424048dc0c67
# ╟─7e9d76e1-ee9f-4b3c-bf5f-9b6901f192e6
# ╟─901d9ca8-d25d-4e61-92e4-782db7fd1701
# ╟─9369fece-8b5e-4817-aee3-3476d43e1c2c
# ╟─8c7359a5-4daf-4c6e-b92a-75b96636b26c
# ╟─1383f2c6-12fa-4a36-8462-391131d1aaee
# ╟─4b9528fc-554f-49df-8fb8-49613f892e36
# ╟─8d2a4c22-579c-4e92-a36d-4f5a763a9395
# ╟─020b1acb-0966-4563-ab52-79a565ed2252
# ╟─8e5c04fd-d83c-49e8-b6b1-5a6a101c56c9
# ╟─78a060bd-f930-4205-a956-abbb72797c1c
# ╟─ede7539a-c98b-4521-bff7-969e6652e20c
# ╟─5bacbd35-70eb-401d-bb62-23f6c17410b0
# ╟─43453fa0-512b-4960-a0bb-fb44e538b6a6
# ╠═03e08a96-29c2-4921-b107-ded3f7dce079
# ╟─7828d5a1-0a0a-45e5-acf1-a287638eb582
# ╟─54a849f3-51ee-43e3-a90c-672046d3afa8
# ╠═a1b7232f-4c34-4bd7-814a-2bacc4cb1fb4
# ╠═5c4d049a-a2c4-48dc-a0dd-8199153c831a
# ╟─8eea80b3-9824-4c5a-b1e7-76244ecadeb6
# ╟─88658420-969a-4786-87ad-bc56455503f8
# ╠═2eb8de93-f0a2-402e-98a6-474a483acb06
# ╠═1cebf7c3-566f-43ac-ae1c-4ade8d6b3dfe
# ╠═18874aab-46ce-41ab-a275-6fd13ed088b4
# ╠═f6d87218-d41c-4f03-8d57-c03f33910c86
# ╟─b66c98c7-fcbc-4d04-a1dc-9452cae611a9
# ╟─0bcb8652-280f-41ca-83b8-df2b07113576
# ╠═7badb26d-2b53-422e-889a-1c17e009a933
# ╟─5d5aeb91-0507-4cab-8151-8b19389bb720
# ╟─a34c804b-399a-4e40-a556-1e590757d048
# ╟─6d812a7f-93e4-4d83-8c38-88d1c92f92cf
# ╟─c63034f7-fee5-4b29-af59-dc64679a3733
# ╟─7fa928b9-599d-43c3-b2d7-6890892e3771
# ╟─b70d1695-7e91-4903-a239-2a3adb4c3bd8
# ╟─bdaf28c5-98f5-478d-ab0f-c886d93fabf1
# ╠═04dafcd3-8568-426b-9c5f-b21fc09d5e88
# ╠═dfd9aed7-9922-4a47-a0b9-20b0bae0ccbf
# ╟─03dfa81c-eaa3-4273-bfff-ab4c8159ee35
# ╠═842f1dbd-32b7-4adf-a0c8-6ca6a5fb323d
# ╠═5ac2cbd5-0117-404c-a9e7-301269c7e700
# ╟─eaf76ba4-846a-4a49-a5b9-2a03745f2305
# ╠═20d3d42b-cb8c-4263-956a-8211292b81ba
# ╠═3bbe41e1-b5ca-4b4b-a6e5-1f5449ab2178
# ╟─72062ccd-540a-4bc4-9588-d5f6539a59ea
# ╟─7ddacc3e-3877-4c7d-8127-b37a5e30b85a
# ╟─348b1476-41e2-4312-8eff-4b8200218659
# ╟─b2a214ad-de66-4ceb-8827-f7229912529c
# ╠═d0ac941f-aba4-4384-8fd8-c5c66ec2bb43
# ╟─463975d9-aae8-4f6d-ae34-2477acf6a9cc
# ╠═84f36442-a43b-4488-b700-8cd399c20e4f
# ╟─45618fab-0dc4-43c3-ab0f-d24490e88695
# ╟─5fc33aba-e51e-4968-9f27-95e8d77cf9f1
# ╟─b91ad51c-f9f7-4236-8040-1959533f1793
# ╟─0823262b-1e9d-4288-abd4-48c6f0894457
# ╟─40fe2709-43b6-419c-9acb-2b2763345811
# ╟─d99644ec-8b84-47a7-81a7-f87657cf3820
# ╟─b290bdba-193a-404f-befd-814fad9b4878
# ╠═64063bd8-e592-425e-87c1-ed9e96db24a9
# ╟─1339c53c-fa89-4078-bd69-54cb6888a12f
# ╟─454abf3b-b2a0-4d58-acfc-d3ff4a9e0255
# ╠═24bb7ff8-ab30-4f14-9f32-f80fa703ff1c
# ╟─e4e895b7-19f4-4eb5-9536-c1a729fd8fcf
# ╟─86a64b87-1085-41e0-a0b4-e846bae2ffba
# ╟─2b4be6eb-8ad5-422a-99d8-a45a20e02c69
# ╠═992f5882-98c6-47e4-810c-81293a396c75
# ╟─06bc1b2b-f26a-47c6-83b7-a639e17f3bc2
# ╟─8d61adab-5ddb-483a-8330-21fc94613bd1
# ╟─91f347d9-e9b6-4e53-9093-20d1987f8ca8
# ╠═60615a85-81d3-4237-8ad4-e43e856b8902
# ╟─a3aa1221-123b-4c8c-87ae-db7116c443fb
# ╠═137f4eb4-9e67-4991-95e6-f31b3fa6cd11
# ╟─a841663b-a218-445f-8249-a28a766cbde5
# ╠═8d67ceaf-7303-4fb2-9577-a7fd2db6d233
# ╟─048926fe-0fa3-44c4-8772-0e4adae576a4
# ╠═79cf1b35-6ec0-4950-9f47-e800dee0b44a
# ╠═265977b4-0fd8-4e38-aa46-6be5bcd00420
# ╟─6428b28d-7aa9-489d-b2b9-c08db5876342
# ╠═7683a362-ab86-4f19-964d-e71a61e86436
# ╟─c5fc9f07-5262-42c8-bada-bf8e1edd3929
# ╠═666bbf88-8d84-416f-a369-d2e20a7935f1
# ╠═598e31e9-b7d1-40c7-82e4-743997cb4063
# ╟─2b3b4a17-3fdd-442d-872c-e5c77c9fd00a
# ╠═d4ccd49b-d34f-4ac5-a463-c3ecb306c285
# ╠═37fd4df6-63c9-44eb-9e92-1635f428a341
# ╠═6c9ec52c-fd12-4d28-ba4b-179c0093e6e8
# ╠═46776f90-5dc9-422b-bfc2-9b9a94d97243
# ╟─494217c7-510c-4993-b995-741d42f9d502
# ╟─1773c88b-7d9e-4617-a3b9-084e93da50b8
# ╟─04b77a81-2e9c-4af9-80a4-088c3b52ca81
# ╟─43ff70cc-235f-44e4-9a32-beabd9de7abb
# ╟─96134cde-f7e4-4bd5-b3c0-2fa05708f7f4
# ╟─99e49c7b-b2dd-49dc-bee1-336d4d1334b1
# ╟─9c08891c-1269-43f8-8095-28eee34bbb3a
# ╟─db19bc67-2894-4bd7-a03c-6d28dfedd4d2
# ╟─2421b3f9-2b25-45b5-9ca7-37e65c249235
# ╟─041cc722-eee1-4456-95bb-f2ad7c1ee771
# ╟─e7ba9264-9bff-45dc-89f8-44d09cf3898f
# ╟─30cf07bb-6304-4ee0-8e7b-7430d6ab8167
# ╟─68457ff5-7dc4-45b6-9c1f-9db34d0c9fc8
# ╟─c89bfe59-0c2d-423e-abac-4ea86981f479
# ╟─81f8c16e-9863-42b3-a91c-df51323b091f
# ╟─fd639425-e97f-4eb0-928b-f1479b09cae6
# ╟─90ad790e-78a9-4a65-89ef-887d3ffcc54f
# ╟─a824cc32-c7e4-471b-afa6-88facbea9eed
# ╟─d7d3fb8b-ed92-44d5-92a2-2cd6144ef4f4
# ╟─ff0dd91a-a69e-4314-8afc-abbb2d80a3ae
# ╟─bf900b34-521f-4b81-914b-8ec88a7cea45
# ╟─4e664ecf-c7b1-4f43-a17f-7b05a4fc1abd
# ╟─0ce3368c-17ce-4187-9961-37a4cecefa34
# ╟─c41fc340-b391-4b57-906a-942747f6deae
# ╟─d5e3126e-74fb-4f5c-a140-8cf033122adb
# ╟─5b6e5cbb-c629-468a-994d-144868734d87
# ╟─57aff837-27ed-460d-b8e6-61c7274d1ccf
# ╟─1fbb3eff-fa40-4beb-9c05-ae03887d75cd
# ╟─fd50008b-367d-407f-8044-ee322eb634d8
# ╟─a20cdfb2-83b4-4d76-87a7-d4e4965e15e3
# ╟─425dbfc2-7430-4270-8d49-3a1dc818d2d4
# ╟─55c36b3a-29e4-4451-aa18-b5e17ff212f6
# ╟─639ad713-3175-4b56-a6e0-b9cc4b5c9e20
# ╟─b41b056d-145f-4000-8414-a1e3c1b4ccd4
# ╟─b6e8a57f-b9fc-422f-a61b-61d1b243441b
# ╟─626f22a6-e5b9-4406-99d5-8824cc06b9b3
# ╟─5d69109b-9099-4ee7-bf10-649e22067a19
# ╟─bb6cef33-bb5a-4f59-a95b-0dd2ffc07fc5
# ╟─299e05b2-c2e8-45bd-9277-1a71fed36ba9
# ╟─a9146129-509a-44f1-8e6b-0de0295e5e75
# ╟─e8555970-8bd0-404f-8a83-8e696a8cebc1
# ╟─446347ec-acec-4245-8a7a-b01f4f6bf228
# ╟─61ffd882-8114-4d8f-a696-e6aef6f0406e
# ╟─d974e8c6-ecf2-42ed-b004-a6e9ff7936c8
# ╟─7b685a83-6541-4fd7-8d2f-502a07c252a7
# ╟─1c48fbe9-9cb6-4c3c-b3a1-3239e46b7058
# ╟─8f4da1f8-3f3c-404d-bac0-79598f92c96f
# ╟─86a4e54c-4461-417b-8322-62bdc08ffab1
# ╟─97d0a7c9-7ae3-49fa-a56b-52d7bd25784b
# ╟─b4b675ab-53d5-4f46-9cfc-dca47acce67a
# ╟─e0f01459-d164-4cac-a5eb-a65aa3f466d9
# ╟─2dc0930e-6807-4ca6-8b49-fb5fafb41d52
# ╟─6472775b-5fc7-493c-a71c-7aed44657e4c
# ╟─d348331c-7418-4f8b-a749-64f7ee824cb6
# ╟─51102b12-9a4f-4081-82e9-283c64053056
# ╟─b782e7c4-2c58-4a54-9f32-ed4ec4ac491c
# ╟─6b6bc466-64b9-4c3a-9e30-ffea398c51aa
# ╟─7fe06e69-573b-4bbf-9ccd-5ba3d508fab4
# ╟─d6d93146-fb11-4051-aaab-222fcf090911
# ╟─37aab722-a75b-4f8d-a752-a33e0338ad8c
# ╟─8611a01a-9bb0-49f1-b452-e1aeeb545c51
# ╟─01265ddd-3798-4e38-b054-2b1837f9bad7
# ╟─81f9b18a-bd28-4147-b9d3-9ec8925a2d01
# ╟─2db71caa-018b-4787-a125-ae4cd6fabd3a
# ╟─3e2ac75b-c8a0-467a-816e-907f4e7b809f
# ╟─28c28e03-76a9-48fd-b68f-121be0d1b74f
# ╟─34ff7b5b-77a9-4793-8a21-baf3a23c2b95
# ╟─e581f1f6-8507-49d3-b1b9-6afbff2c2d92
# ╟─bd459a19-79cd-40a8-b9f3-55ce5b0aba7d
# ╟─509d8c4d-6b75-49a6-aba1-91894fb8f580
# ╟─38db521f-f478-459e-83f7-6a7dbbd5568a
# ╟─4c329718-55a7-415c-91e0-a2e0199169de
# ╟─8a382890-6b33-478e-abd6-cc0aa079f8d2
# ╟─b0cb9a50-a7e2-48ef-ae7d-431d04a7e055
# ╟─8a01cacf-e69a-48bb-ab25-cc0cd3f77071
# ╟─741caaac-8f2b-4e64-a15d-d363382b6e3f
# ╟─dbd3985e-0c0f-41f0-9361-859fd7f2ea6c
# ╟─2c9b754b-4632-460e-866e-54e1b6d8e0e7
# ╟─5d6c0fb3-0dd1-427b-b732-b387640cb9f3
# ╟─69ff9357-edf4-4045-9151-9bb9fbf92492
# ╟─a1fd525b-5d0e-4164-9d20-f8741053f35e
# ╟─95e4a0fb-da8a-4e3c-a0d0-214d559ad90e
# ╟─4534935a-001b-4b3f-8843-f9574f5b06aa
# ╟─0be51e3f-ed13-46c1-921a-ab20aa707595
# ╟─f0418f1f-3dab-4b1f-8a18-6d8ddcf07523
# ╟─bf202301-c645-4698-b931-6626758c569a
# ╟─5f8aab19-c664-4460-8737-0e9c6a758a4a
# ╟─64dafd98-afca-45b3-9aad-5697a4edc08e
# ╟─d53c7125-c433-452a-bbf6-06aa43b756f3
# ╟─eb54b362-4f84-405d-8414-ef35ede5d7de
# ╟─0b786728-2437-4d7f-aa68-b911c145699a
# ╟─ee7c93aa-73c9-4f46-8ac1-5898a3bf61bf
# ╟─a9aeee4c-c0d6-45cc-8b2d-03fcfdee8e37
# ╟─febed0ae-59eb-4820-b237-81612ca5ac19
# ╟─2cd45cb4-ba74-4a54-8f3e-8cdf2223c8e9
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
