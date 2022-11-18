### A Pluto.jl notebook ###
# v0.19.15

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 00bea115-49be-4e2b-b5ad-acf73fb914c2
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    # instantiate, i.e. make sure that all packages are downloaded
    Pkg.instantiate()

    using PlutoUI, ImageView, Images, Conda, PyCall, SymPy, Roots, Plots, HTTP, JSON, Luxor, DotEnv, SQLite, DataFrames, UUIDs, Underscores
end

# ╔═╡ d46d3ca7-d893-46c1-9ee7-1c88c9219a9e
situatieschets = load("./assets/img/profiel_2.jpg")

# ╔═╡ 2a3d44ad-9ec2-4c21-8825-dbafb127f727
md"## Indeling
De krachtsafdracht is bepaald voor volgende indeling. In de lastendaling zijn de resulterende belasting begroot ter hoogte van de bovenzijde van de muren van het gelijkvloers. Op onderstaande figuur wordt een onderschijdt gemaakt tussen muren met een **dragende functie** (**rood**)  en deze met een **niet dragende functie** (**geel**)."

# ╔═╡ c6f5a862-cae1-4e9c-a905-72a4122c11a7
md"""
!!! danger "Controleer de lastendaling"
	Alvorens het rekenblad verder aan te vullen, is het belangrijk dat met de correcte uitgangspunten gewerkt wordt. Controleer aldus je resulterende krachten. Bekijk in de lastendaling of de **nuttige last** van $2 kN/m^2$ werd meegenomen, alsook de sneeuwlast en in welke situatie (*oud* of *nieuw*) de lasten zijn doorgerekend.
"""

# ╔═╡ 6a04789a-c42a-4ac9-8d05-ee20442ad60d
load("./assets/img/indeling.jpg")

# ╔═╡ 31851342-e653-45c2-8df6-223593a7f942
md"## Probleemstelling: Isostatische ligger met een uitkragend gedeelte
Isostatische ligger met 1 tussensteunpunt, een **uitkragend gedeelte** en 3 variabele belastingen."

# ╔═╡ 6f60b828-1815-4849-a6c9-4f5949fcc74f
md"""
!!! info "Uitkragend gedeelte + vervorming Profiel 1 vs 2"
	Het uitkragend gedeelte zal een positieve invloed hebben op de vervormingen van de doorsnede. De **vervormingen** dienen in lijn te liggen met deze van **profiel 1**. Dit om scheurvorming te vermijden tussen profiel 1 en 2. Eventueel kunnen de twee profielen verbonden worden met elkaar zodoende de vervorming gelijk blijft en krachten herverdeeld worden tussen de profielen.
"""

# ╔═╡ 883ced2c-2403-4c81-8d80-8f99536ffbe8
naam = "Profiel 2"

# ╔═╡ 7232ab53-f2df-45e5-bf9b-f3997de5d3f2
PlutoUI.TableOfContents(title=string("Berekening ", naam), depth=4)

# ╔═╡ a81fbf3e-f5c7-41c7-a71e-68f8a9589b45
md"Naam van het profiel; $\text{naam}$ = $naam"

# ╔═╡ 7578c2d4-1115-4463-b74e-9330d1ecd96c
ligger = (
	naam = "HE 220 B",
	kwaliteit = "S235"
)

# ╔═╡ 542f69ac-77c5-47d7-be6c-94ba82a50ef7
md"""
!!! danger "Opmerking"
	Bij de controle in **UGT** wordt de momentweerstand niet verminderd in functie van de dwarskracht. Er wordt op toegezien dat de `Check 4` de waarde van $0.50$ niet overschrijdt. Indien de *Unity Check* groter is, dan grijpen we terug naar NBN EN 1993 om een aangepaste controle uit te voeren.
"""

# ╔═╡ d54678e5-8651-499c-bc0e-d1c05ffba208
md"""
Resulterende krachten ter hoogte van de steunpunten voor afdracht naar het profiel 5
"""

# ╔═╡ 8f910bf3-5227-4113-9476-6136194a5e60
md"### Beschrijving belastingsschema
Definiëer de randvoorwaarden of *Boundary Conditions* $(\text{BC})$. Voor een **verdeelde belasting** geef je de parameters $a$, $b$, $L$ en $p$ in waarbij een *positieve* waarde van $p$ een neerwaartse belasting is. Voor een **puntbelasting** geef je de parameters $a$, $L$ en $p$ in. Ook de stijfheid $\text{EI}$."

# ╔═╡ c4df4b92-a3c6-43bd-a594-9d1f8c76015f
md"In het desbetreffende geval waarbij er **drie verdeelde belastingen** aangrijpen naast elkaar, herleidt het aantal paramaters zich tot $a$, $b$, $x_{steun}$, $L$, $p_1$, $p_2$ en $p_3$. 

In vergelijking met voorgaande problemen moeten de kinematische randvoorwaarden geherdefinieerd worden. De vervorming ter hoogte van $x_{steun}$ moet immers $0\ \text{mm}$ bedragen."

# ╔═╡ ddeaf6b6-5e91-46fa-adf8-026bf6933dee
schets = @drawsvg begin
	sethue("black")
	endpnts = (-225, 0), (225, 0)
	pnt_a = Point(0, 0)
	pnt_b = Point(120, 0)
	pnt_x = Point(90, 0)
	pnts = Point.(endpnts) |> collect
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
		poly([pnts[1], pnt_a], :stroke);
		Luxor.label("p₁", :N, midpoint(pnts[1], pnt_a), offset=15);
	)
	@layer (
		# Verdeelde last 2
		fontsize(16);
		Luxor.translate(0, -30);
		len_2 = distance(pnt_a, pnt_b);
		for i = 0:fld(len_2, 15)
			Luxor.arrow(pnt_a + (15 * i, 0), pnt_a + (15 * i, 25));
		end;
		poly([pnt_a, pnt_b], :stroke);
		Luxor.label("p₂", :N, midpoint(pnt_a, pnt_b), offset=15);
	)
	@layer (
		# Verdeelde last 3
		fontsize(16);
		Luxor.translate(0, -40);
		len_3 = distance(pnt_b, pnts[2]);
		for i = 0:fld(len_3, 15)
			Luxor.arrow(pnt_b + (15 * i, 0), pnt_b + (15 * i, 35));
		end;
		poly([pnt_b, pnts[2]], :stroke);
		Luxor.label("p₃", :N, midpoint(pnt_b, pnts[2]), offset=15);
	)
	@layer (
		# Tussensteunpunt
		fontsize(16);
		Luxor.translate(0, 62);
		Luxor.arrow(pnt_x, pnt_x - (0, 60)); 
		Luxor.label("R₂", :SW, pnt_x, offset=5);
	)
	@layer (
		fontsize(16);
		Luxor.translate(0, 10);
		Luxor.arrow(pnts...);
		Luxor.label("L", :SW, pnts[2], offset=15);
		Luxor.translate(0, 10);
		Luxor.arrow(pnts[1], pnt_b);
		Luxor.label("b", :SW, pnt_b, offset=15);
		Luxor.translate(0, 10);
		Luxor.arrow(pnts[1], pnt_x);
		Luxor.label("x_steun", :SW, pnt_x, offset=15);
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

# ╔═╡ 1e0d9ae7-c4a4-4a19-ba8c-37ee29e1ac0d
schema = (
	a = 2.50, # [m] - Tot aan de verbreding van de schouw (muurdeel 4)
	b = 2.50 + 1.80, # [m] - tot aan de deuropening (muurdeel 6)
	x_steun = 4.03, # [m] - Halverwege oplegging tot centerlijn steun 
	L = 5.30 # [m] - Tot halverwege oplegging 0.20
)

# ╔═╡ 17d9db0f-b12f-40ee-b553-e62cd3325624
geom = (
	l1 = (@_ schema |> __[:a]),
	l2 = (@_ schema |> __[:b] - __[:a]),
	l3 = (@_ schema |> __[:L] - __[:b]),
	L = schema[:L]
)

# ╔═╡ 73513686-5ef4-46b6-8459-6d7f1dccb88b
verh_m7_3 = 0.5 # Verhouding deel 1 t.o.v deel 1 + 2

# ╔═╡ 901d9ca8-d25d-4e61-92e4-782db7fd1701
md"Definieer in onderstaande tabel de verschillende combinaties. Voor **GGT** wordt gerekend met het $\psi_1$ gelijk aan $0.5$ voor de **nuttige overlast** in de *frequente* combinatie, dit volgens Categorie A volgens NBN EN 1990."

# ╔═╡ 9369fece-8b5e-4817-aee3-3476d43e1c2c
combinaties = DataFrame([
	(check=:GGT, naam="p1", formule="g1 + gp + 0.5 * q1_vloer"),
	(check=:GGT_K, naam="p1", formule="g1 + gp + q1_vloer + 0.5 * q1_sneeuw"),
	(check=:UGT, naam="p1", formule="1.35 * (g1 + gp) + 1.5 * (q1_vloer + 0.5 * q1_sneeuw)"),
	(check=:GGT, naam="p2", formule="g2 + gp + 0.5 * q2_vloer"),
	(check=:GGT_K, naam="p2", formule="g2 + gp + q2_vloer + 0.5 * q2_sneeuw"),
	(check=:UGT, naam="p2", formule="1.35 * (g2 + gp) + 1.5 * (q2_vloer + 0.5 * q2_sneeuw)"), 
	(check=:GGT, naam="p3", formule="g3 + gp + 0.5 * q3_vloer"),
	(check=:GGT_K, naam="p3", formule="g3 + gp + q3_vloer + 0.5 * q3_sneeuw"),
	(check=:UGT, naam="p3", formule="1.35 * (g3 + gp) + 1.5 * (q3_vloer + 0.5 * q3_sneeuw)"),
])

# ╔═╡ 8d2a4c22-579c-4e92-a36d-4f5a763a9395
md"Twee hulpvariabelen voor later..."

# ╔═╡ 78a060bd-f930-4205-a956-abbb72797c1c
md"Voor de vervorming en hoekverdraaiing moet de stijfheid in acht genomen worden"

# ╔═╡ 2cc84de4-ddf3-4913-9110-121778c9d255
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

# ╔═╡ b66c98c7-fcbc-4d04-a1dc-9452cae611a9
md"""
### Oplossing belastingsschema
De ligger heeft een atypische configuratie van de steunpunten, isostatisch opgelegd met **uitkragend gedeelte**. Het superpositiebeginsel wordt **niet** gehanteerd. De rechstreekse oplossing wordt berekend door reeds in acht nemen van een bepaalde configuratie. Zo valt $x_{steun}$ binnen **deel 2** van de configuratie.
"""

# ╔═╡ 921b3dbc-4f44-4903-a85e-880949daa3b6
md"""
!!! info "Configuratie"
	Het steunpunt $x_{steun}$ ligt in **deel 2** van de configuratie
"""

# ╔═╡ 29f6d141-6d8a-4b49-858c-bc5b010bb7bc
schets

# ╔═╡ 7badb26d-2b53-422e-889a-1c17e009a933
p1, p2, p3, x_steun = symbols("p_1 p_2 p_3 x_{steun}", real=true)

# ╔═╡ b70d1695-7e91-4903-a239-2a3adb4c3bd8
md"#### Reactiekrachten"

# ╔═╡ 03dfa81c-eaa3-4273-bfff-ab4c8159ee35
md"#### Dwarskracht en momenten
Oplossing neerschrijven van de dwarkracht en het buigend moment"

# ╔═╡ 3b7bb014-8a99-415a-8814-2402384d0e99
md"##### Bepalen dwarskracht $V(t)$"

# ╔═╡ ed7433a4-9cb2-4934-9226-6d4652fef2c2
md"##### Bepalen moment $M(t)$"

# ╔═╡ eaf76ba4-846a-4a49-a5b9-2a03745f2305
md"#### Hoekverdraaiing en doorbuiging
Oplossing neerschrijven van de hoekverdraaiing en de doorbuiging"

# ╔═╡ cacf15e0-7c7a-44aa-89d6-58d52837de0e
md"##### Bepalen hoekverdraaiing $\alpha(t)$"

# ╔═╡ 13a396ed-932b-4d73-8cae-9abbd55afd6b
C1, C2, C3, C4 = symbols("C_1 C_2 C_3 C_4")

# ╔═╡ 7615ec7e-7fdc-4ef3-aac1-f4bb2a7be3f7
md"##### Bepalen doorbuiging $v(t)$"

# ╔═╡ 4baaf378-533f-486d-ac41-46c452e3afde
D1, D2, D3, D4 = symbols("D_1 D_2 D_3 D_4")

# ╔═╡ 5b563a63-5a7d-4cc7-a9b6-06cd1182923d
md"##### Kinematische randvoorwaarden"

# ╔═╡ 72062ccd-540a-4bc4-9588-d5f6539a59ea
md"#### Maximale interne krachten
Maximale interne krachten en hun voorkomen ($x$ abscis)"

# ╔═╡ 7ddacc3e-3877-4c7d-8127-b37a5e30b85a
md"""
!!! tip "lambdify"
	`lambdify` wordt gebruikt om de formules om te zetten van hun `SymPy` vorm naar een pure `Julia` vorm
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

# ╔═╡ 0918d502-5ca4-48ee-8b53-fdb3b36f267b
function minmax(pair::Pair)
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

# ╔═╡ e449b656-9f2b-4e34-b97f-12a9d75c7d22
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
	select_profiel = @bind __profiel Select(sections[!, "name"], default=ligger[:naam])
	select_staalkwaliteit = @bind __staalkwaliteit Select(["S235", "S355"], default=ligger[:kwaliteit])
	md"""
	Lijst met beschikbare profielen: $select_profiel in kwaliteiten $select_staalkwaliteit
	"""
end

# ╔═╡ fe346e35-b9c5-4a66-a0f3-0ffcef7ef2a7
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
Bereking van **$naam**, een eenvoudig opgelegde ligger **onder muur 4, 6 en 7**. Het profiel draagt de vloer van **kamer 3**, gezien deze afdraagt van muur 4, 6 en 7 enerzijds en naar muur 9 anderzijds. **Muur 6** maakt onderdeel uit van een schouw. Een deel van het **profiel kraagt uit** en wordt niet ondersteund op zijn kopse zijde.

Lasten zijn afkomstig van het dak tot het eerste verdiep. Er wordt gerekend met een **nuttige belasting** van $200 kN/m^2$ en een krachtsafdracht van de vloeroppervlaktes tussen de draagmuren (dus **krachtsafdracht** in **1 richting**), tenzij hier uitdrukkelijk van afgeweken wordt.
"""

# ╔═╡ 7e9d76e1-ee9f-4b3c-bf5f-9b6901f192e6
belastingsgevallen = DataFrame([
	(naam="g1", waarde=15.964, beschrijving="Perm. last - lastendaling"),
	(naam="g2", waarde=47.778, beschrijving="Perm. last - lastendaling"),
	(naam="g3", waarde=27.341 * verh_m7_3, beschrijving="Perm. last - lastendaling"),
	(naam="gp", waarde=profiel[1, "G"] * 0.01, beschrijving="Perm. last - profiel"),
	(naam="q1_vloer", waarde=10.400, beschrijving="Var. last - nuttige overlast"),
	(naam="q2_vloer", waarde=19.034, beschrijving="Var. last - nuttige overlast"),
	(naam="q3_vloer", waarde=19.515 * verh_m7_3, beschrijving="Var. last - nuttige overlast"),
	(naam="q1_sneeuw", waarde=0, beschrijving="Var. last - sneeuwlast"),
	(naam="q2_sneeuw", waarde=6.233, beschrijving="Var. last - sneeuwlast"),
	(naam="q3_sneeuw", waarde=1.268 * verh_m7_3, beschrijving="Var. last - sneeuwlast")
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
	maatgevend[!, "a"] .= schema[:a]
	maatgevend[!, "b"] .= schema[:b]
	maatgevend[!, "x_steun"] .= schema[:x_steun]
	maatgevend[!, "L"] .= schema[:L]
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
		v_lim = schema[:x_steun] / 500 * 1000 # mm
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

# ╔═╡ dfd9aed7-9922-4a47-a0b9-20b0bae0ccbf
R2 = (p1 * a * a / 2 + p2 * (b - a) * (b + a) / 2 + p3 * (L - b) * (L + b) / 2) / x_steun

# ╔═╡ 04dafcd3-8568-426b-9c5f-b21fc09d5e88
R1 = p1 * a + p2 * (b - a) + p3 * (L - b) - R2

# ╔═╡ 3fb7c2b8-633c-4a3e-8f58-467c01d43262
select(rvw, :,
	AsTable(DataFrames.Not(:check)) => 
		ByRow(r -> [R1, R2] .|> f -> f(Dict(keys(r) .|> eval .=> values(r))...) |> rnd) => [:R1, :R2]
)

# ╔═╡ 842f1dbd-32b7-4adf-a0c8-6ca6a5fb323d
begin
	V1_ = - R1 + p1 .* t 					# van t: 0 → a
	V2_ = - R1 + p1 * a + p2 .* (t - a) 		# van t: a → x_steun
	V3_ = - R1 + p1 * a + p2 .* (t - a) - R2 # van t: x_steun → b
	V4_ = - p3 .* (L .- t)					# van t: b → L
	V = V1_ .* interval(t, -1e-10, a) .+ V2_ .* interval(t, a, x_steun) .+ V3_ .* interval(t, x_steun, b) .+ V4_ .* interval(t, b, L)
end

# ╔═╡ 5ac2cbd5-0117-404c-a9e7-301269c7e700
begin
	M1_ = R1 .* t - p1 * t .* t / 2 # van t: 0 → a
	M2_ = R1 .* t - p1 * a .* (2 * t - a) / 2 - p2 .* (t - a) .* (t - a) / 2 # van t: a → x_steun
	M3_ = R1 .* t - p1 * a .* (2 * t - a) / 2 - p2 .* (t - a) .* (t - a) / 2 + R2 .* (t - x_steun) # van t: x_steun → b
	M4_ = - p3 .* (L .- t) .* (L .- t) / 2	# van t: b → L
	M = M1_ .* interval(t, -1e-10, a) .+ M2_ .* interval(t, a, x_steun) .+ M3_ .* interval(t, x_steun, b) .+ M4_ .* interval(t, b, L)
end

# ╔═╡ 20d3d42b-cb8c-4263-956a-8211292b81ba
begin
	α1__ = integrate(M1_, t) + C1 # van t: 0 → a
	α2__ = integrate(M2_, t) + C2 # van t: a → x_steun
	α3__ = integrate(M3_, t) + C3 # van t: x_steun → b
	α4__ = integrate(M4_, t) + C4 # van t: b → L
	α_ = α1__ .* interval(t, -1e-10, a) .+ α2__ .* interval(t, a, x_steun) .+ α3__ .* interval(t, x_steun, b) .+ α4__ .* interval(t, b, L)
end

# ╔═╡ a06a6306-caea-4077-93a1-1b26366d652e
begin
	v1__ = integrate(α1__, t) + D1 # van t: 0 → a
	v2__ = integrate(α2__, t) + D2 # van t: a → x_steun
	v3__ = integrate(α3__, t) + D3 # van t: x_steun → b
	v4__ = integrate(α4__, t) + D4 # van t: b → L
	v_ = v1__ .* interval(t, -1e-10, a) .+ v2__ .* interval(t, a, x_steun) .+ v3__ .* interval(t, x_steun, b) .+ v4__ .* interval(t, b, L)
end

# ╔═╡ 4d5796c6-ebbe-4473-b8fd-250a562e1ad8
rvw_ = [
		# Vervormingen
		v1__(t=>0), 
		v1__(t=>a) - v2__(t=>a),
		v2__(t=>x_steun),
		v3__(t=>x_steun),
		v3__(t=>b) - v4__(t=>b),
		# Hoekverdraaiingen 
		α1__(t=>a) - α2__(t=>a),
		α2__(t=>x_steun) - α3__(t=>x_steun),
		α3__(t=>b) - α4__(t=>b)
	]

# ╔═╡ 3bbe41e1-b5ca-4b4b-a6e5-1f5449ab2178
opl_ = solve(rvw_, [C1, C2, C3, C4, D1, D2, D3, D4])

# ╔═╡ bd28b79a-58d9-4d15-8a9e-58c84f8b2f00
EIα = α_(opl_...)

# ╔═╡ c641f1f9-5f1c-4fcf-9225-c491af2610de
α = EIα / EI

# ╔═╡ 0a0b2faf-0667-48af-8210-d1e13221f1de
EIv = v_(opl_...)

# ╔═╡ 925053f3-77e6-4aa7-acc3-7315d95ad1ef
v = EIv / EI

# ╔═╡ 84f36442-a43b-4488-b700-8cd399c20e4f
#fn = r -> (i -> lambdify(i(mapping(r)...)))
function fn(r)
	sol = Dict(keys(r) .|> eval .=> values(r))
	return i -> lambdify(i(
			sol...,
			EI => buigstijfheid
	))
end

# ╔═╡ b91ad51c-f9f7-4236-8040-1959533f1793
opl = select(rvw, :, AsTable(DataFrames.Not(:check)) => 
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

# ╔═╡ 78518947-84c1-4dd1-a0cf-6ae57db251ee
grafieken = select(opl,
	AsTable(:) => ByRow(r -> grafiek(r)) => [:V, :M, :α, :v]
)

# ╔═╡ e5f707ce-54ad-466e-b6a6-29ad77168590
grafieken

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
	pnts1 = Point.(endpnts1) |> collect
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
		poly([pnt_a1, pnt_b1], :stroke);
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
	pnts2 = Point.(endpnts1) |> collect
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
	supports3 = (-200, 0), (120, 0)
	pnt_a3 = Point(-100, 0)
	pnt_b3 = Point(50, 0)
	pnts3 = Point.(endpnts3) |> collect
	spprt3 = Point.(supports3) |> collect
	@layer (
		fontsize(20);
		poly(pnts3, :stroke);
		circle.(spprt3, 4, :fill);
		for i = 0:10
			Luxor.arrow(Point(-100 + 15 * i, -45 - 2 * i), Point(-100 + 15 * i, -5));
		end;
		Luxor.label.(["1", "2"], [:NW, :NE], spprt3, offset=15)
	)
	@layer (
		fontsize(16);
		Luxor.translate(0, -45);
		poly([pnt_a3, pnt_b3 - (0, 20)], :stroke);
		Luxor.label("p_a", :NW, pnt_a3, offset=15);
		Luxor.label("p_b", :NE, pnt_b3, offset=15);
	)
	@layer (
		fontsize(16);
		Luxor.translate(0, 10);
		Luxor.arrow(pnts3...);
		Luxor.label("L", :SW, pnts3[2], offset=15);
		Luxor.translate(0, 10);
		Luxor.arrow(spprt3...);
		Luxor.label("x_steun", :S, spprt3[2], offset=10);
		Luxor.translate(0, 10);
		Luxor.arrow(pnts3[1], pnt_b3);
		Luxor.label("b", :SW, pnt_b3, offset=15);
		Luxor.translate(0, 10);
		Luxor.arrow(pnts3[1], pnt_a3);
		Luxor.label("a", :SW, pnt_a3, offset=15);
	)
end (800) (150)

# ╔═╡ e0f01459-d164-4cac-a5eb-a65aa3f466d9
md"Moment in de steunpunten = $0$ $\rightarrow$ evenwicht er rond uitschrijven ter bepalen van de steunpuntsreacties - evenwicht uitschrijven rond het **punt $1$** en het **punt $2$**"

# ╔═╡ 6472775b-5fc7-493c-a71c-7aed44657e4c
R32 = (p_a * (b - a) * (a + b) / 2 + (p_b - p_a) * (b - a) * (a + 2 * b) / 3) / L

# ╔═╡ 90ad790e-78a9-4a65-89ef-887d3ffcc54f
R12 = SymPy.simplify(R32(BC31...))

# ╔═╡ 2dc0930e-6807-4ca6-8b49-fb5fafb41d52
R31 = (p_a + p_b) / 2 * (b - a) - R32

# ╔═╡ fd639425-e97f-4eb0-928b-f1479b09cae6
R11 = SymPy.simplify(R31(BC31...))

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

# ╔═╡ b782e7c4-2c58-4a54-9f32-ed4ec4ac491c
md"#### 3.2 Bepalen moment $M(t)$"

# ╔═╡ 6b6bc466-64b9-4c3a-9e30-ffea398c51aa
begin
	M31 = R31 .* t 			# Van t: 0 -> a
	M32 = R31 .* t - (2 * p_a + p_t) / 6 .* (t .- a) .^ 2  # Van t: a -> b
	M33 = R32 .* (L .- t) 	# Van t: b -> L
	M3 = M31 .* interval(t, -1e-10, a) .+ M32 .* interval(t, a, b) .+ M33 .* interval(t, b, L)
end

# ╔═╡ bf900b34-521f-4b81-914b-8ec88a7cea45
M1 = SymPy.simplify(M3(BC31...))

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

# ╔═╡ 28c28e03-76a9-48fd-b68f-121be0d1b74f
EIv3 = v3_(opl3...)

# ╔═╡ 34ff7b5b-77a9-4793-8a21-baf3a23c2b95
v3 = EIv3 / EI # volgens gekozen lengteenheid

# ╔═╡ d5e3126e-74fb-4f5c-a140-8cf033122adb
v1 = SymPy.simplify(v3(BC31...)) # volgens gekozen lengteenheid

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

# ╔═╡ Cell order:
# ╠═00bea115-49be-4e2b-b5ad-acf73fb914c2
# ╟─c4c79ab2-d6b7-11eb-09d0-e3cbf2c9d6e9
# ╟─d46d3ca7-d893-46c1-9ee7-1c88c9219a9e
# ╟─7232ab53-f2df-45e5-bf9b-f3997de5d3f2
# ╟─2a3d44ad-9ec2-4c21-8825-dbafb127f727
# ╟─c6f5a862-cae1-4e9c-a905-72a4122c11a7
# ╟─6a04789a-c42a-4ac9-8d05-ee20442ad60d
# ╟─31851342-e653-45c2-8df6-223593a7f942
# ╟─6f60b828-1815-4849-a6c9-4f5949fcc74f
# ╠═883ced2c-2403-4c81-8d80-8f99536ffbe8
# ╟─a81fbf3e-f5c7-41c7-a71e-68f8a9589b45
# ╟─3e479359-d1a8-4036-8e9c-04317efde55a
# ╟─fe346e35-b9c5-4a66-a0f3-0ffcef7ef2a7
# ╠═7578c2d4-1115-4463-b74e-9330d1ecd96c
# ╟─882a3f47-b9f0-4a92-98b2-881f8ce84f6d
# ╟─e5f707ce-54ad-466e-b6a6-29ad77168590
# ╟─8703a7d1-2838-4c98-8b93-1d4af8cf2b21
# ╟─542f69ac-77c5-47d7-be6c-94ba82a50ef7
# ╟─d54678e5-8651-499c-bc0e-d1c05ffba208
# ╟─3fb7c2b8-633c-4a3e-8f58-467c01d43262
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
# ╠═1e0d9ae7-c4a4-4a19-ba8c-37ee29e1ac0d
# ╠═17d9db0f-b12f-40ee-b553-e62cd3325624
# ╠═73513686-5ef4-46b6-8459-6d7f1dccb88b
# ╟─7e9d76e1-ee9f-4b3c-bf5f-9b6901f192e6
# ╟─901d9ca8-d25d-4e61-92e4-782db7fd1701
# ╟─9369fece-8b5e-4817-aee3-3476d43e1c2c
# ╟─8c7359a5-4daf-4c6e-b92a-75b96636b26c
# ╟─1383f2c6-12fa-4a36-8462-391131d1aaee
# ╠═4b9528fc-554f-49df-8fb8-49613f892e36
# ╟─8d2a4c22-579c-4e92-a36d-4f5a763a9395
# ╟─020b1acb-0966-4563-ab52-79a565ed2252
# ╟─8e5c04fd-d83c-49e8-b6b1-5a6a101c56c9
# ╟─78a060bd-f930-4205-a956-abbb72797c1c
# ╟─2cc84de4-ddf3-4913-9110-121778c9d255
# ╟─5bacbd35-70eb-401d-bb62-23f6c17410b0
# ╟─43453fa0-512b-4960-a0bb-fb44e538b6a6
# ╠═03e08a96-29c2-4921-b107-ded3f7dce079
# ╟─7828d5a1-0a0a-45e5-acf1-a287638eb582
# ╠═54a849f3-51ee-43e3-a90c-672046d3afa8
# ╠═a1b7232f-4c34-4bd7-814a-2bacc4cb1fb4
# ╠═5c4d049a-a2c4-48dc-a0dd-8199153c831a
# ╟─b66c98c7-fcbc-4d04-a1dc-9452cae611a9
# ╟─921b3dbc-4f44-4903-a85e-880949daa3b6
# ╟─29f6d141-6d8a-4b49-858c-bc5b010bb7bc
# ╠═7badb26d-2b53-422e-889a-1c17e009a933
# ╟─b70d1695-7e91-4903-a239-2a3adb4c3bd8
# ╠═04dafcd3-8568-426b-9c5f-b21fc09d5e88
# ╠═dfd9aed7-9922-4a47-a0b9-20b0bae0ccbf
# ╟─03dfa81c-eaa3-4273-bfff-ab4c8159ee35
# ╟─3b7bb014-8a99-415a-8814-2402384d0e99
# ╟─842f1dbd-32b7-4adf-a0c8-6ca6a5fb323d
# ╟─ed7433a4-9cb2-4934-9226-6d4652fef2c2
# ╠═5ac2cbd5-0117-404c-a9e7-301269c7e700
# ╟─eaf76ba4-846a-4a49-a5b9-2a03745f2305
# ╟─cacf15e0-7c7a-44aa-89d6-58d52837de0e
# ╟─13a396ed-932b-4d73-8cae-9abbd55afd6b
# ╟─20d3d42b-cb8c-4263-956a-8211292b81ba
# ╟─bd28b79a-58d9-4d15-8a9e-58c84f8b2f00
# ╟─c641f1f9-5f1c-4fcf-9225-c491af2610de
# ╟─7615ec7e-7fdc-4ef3-aac1-f4bb2a7be3f7
# ╟─4baaf378-533f-486d-ac41-46c452e3afde
# ╟─a06a6306-caea-4077-93a1-1b26366d652e
# ╟─0a0b2faf-0667-48af-8210-d1e13221f1de
# ╟─925053f3-77e6-4aa7-acc3-7315d95ad1ef
# ╟─5b563a63-5a7d-4cc7-a9b6-06cd1182923d
# ╟─4d5796c6-ebbe-4473-b8fd-250a562e1ad8
# ╟─3bbe41e1-b5ca-4b4b-a6e5-1f5449ab2178
# ╟─72062ccd-540a-4bc4-9588-d5f6539a59ea
# ╟─7ddacc3e-3877-4c7d-8127-b37a5e30b85a
# ╠═84f36442-a43b-4488-b700-8cd399c20e4f
# ╟─45618fab-0dc4-43c3-ab0f-d24490e88695
# ╟─5fc33aba-e51e-4968-9f27-95e8d77cf9f1
# ╟─b91ad51c-f9f7-4236-8040-1959533f1793
# ╟─0823262b-1e9d-4288-abd4-48c6f0894457
# ╟─40fe2709-43b6-419c-9acb-2b2763345811
# ╟─d99644ec-8b84-47a7-81a7-f87657cf3820
# ╟─0918d502-5ca4-48ee-8b53-fdb3b36f267b
# ╟─78518947-84c1-4dd1-a0cf-6ae57db251ee
# ╟─e449b656-9f2b-4e34-b97f-12a9d75c7d22
# ╟─454abf3b-b2a0-4d58-acfc-d3ff4a9e0255
# ╠═24bb7ff8-ab30-4f14-9f32-f80fa703ff1c
# ╟─e4e895b7-19f4-4eb5-9536-c1a729fd8fcf
# ╟─86a64b87-1085-41e0-a0b4-e846bae2ffba
# ╟─2b4be6eb-8ad5-422a-99d8-a45a20e02c69
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
