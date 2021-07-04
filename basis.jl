### A Pluto.jl notebook ###
# v0.14.8

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
using PlutoUI, ImageView, Images, Conda, PyCall, SymPy, Plots, HTTP, JSON, Luxor

# ╔═╡ c4c79ab2-d6b7-11eb-09d0-e3cbf2c9d6e9
md"""
# Berekening profiel
$(html\"<mark>Algemene beschrijving</mark>\")
"""

# ╔═╡ 2a3d44ad-9ec2-4c21-8825-dbafb127f727
md"## Indeling
De krachtsafdracht is bepaald voor volgende indeling. In de lastendaling zijn de resulterende belasting begroot ter hoogte van de bovenzijde van de muren van het gelijkvloers. Op onderstaande figuur wordt een onderschijdt gemaakt tussen muren met een dragende functie en deze met een niet dragende functie."

# ╔═╡ 6a04789a-c42a-4ac9-8d05-ee20442ad60d
load("indeling.jpg")

# ╔═╡ 31851342-e653-45c2-8df6-223593a7f942
md"## Eenvoudig opgelegde ligger met uitkraging
Eenvoudig opgelegde ligger met een gedeeltelijke uitkraging en 3 verdeelde belastingen"

# ╔═╡ a81fbf3e-f5c7-41c7-a71e-68f8a9589b45
md"Naam van het profiel; $\text{naam}$ = $(@bind naam TextField(default=\"Profiel\"))"

# ╔═╡ 8f910bf3-5227-4113-9476-6136194a5e60
md"### Randvoorwaarden of *Boundary Conditions*
Definiëer de randvoorwaarden of *Boundary Conditions* $(\text{BC})$. Voor een **verdeelde belasting** geef je de parameters $a$, $b$, $L$ en $p$ in waarbij een *positieve* waarde van $p$ een neerwaartse belasting is. Voor een **puntbelasting** geef je de parameters $a$, $L$ en $p$ in. Ook de stijfheid $\text{EI}$."

# ╔═╡ 78a060bd-f930-4205-a956-abbb72797c1c
md"Voor de vervorming en hoekverdraaiing moet de stijfheid in acht genomen worden"

# ╔═╡ 3e479359-d1a8-4036-8e9c-04317efde55a
begin
	profielkeuze = @bind profiel Select(["HEB200", "HEA220"])
	md"Keuze profiel: $profielkeuze"
end

# ╔═╡ 5bacbd35-70eb-401d-bb62-23f6c17410b0
md"Haal informatie van het profiel op en bewaar het in `info`"

# ╔═╡ 97ba93ff-880a-4625-9bf8-da385db57568
 begin
	# Haal informatie van het profiel op via een API
	response = HTTP.get("https://nodered.eetietshekken.xyz/section/$profiel")
	text = String(response.body)
	info = JSON.parse(text)
end

# ╔═╡ 03e08a96-29c2-4921-b107-ded3f7dce079
EI_ = 210000 * info["Iy"] / 10^9 # kNm2

# ╔═╡ b5535266-c6a1-4770-be99-6d1fd79d8543
begin 
	field_x = @bind x NumberField(0:0.05:10, default=2)
	field_l = @bind l NumberField(0:0.05:10, default=5)
	md"""
	Coordinaat $x$: $field_x m
	
	Lengte $l$: $field_l m
	"""
end

# ╔═╡ 7ddacc3e-3877-4c7d-8127-b37a5e30b85a
md"### Resultaten
Haal de resultaten op en geef ze weer op een grafiek."

# ╔═╡ b70d1695-7e91-4903-a239-2a3adb4c3bd8
md"#### Reactiekrachten"

# ╔═╡ 03dfa81c-eaa3-4273-bfff-ab4c8159ee35
md"#### Dwarskracht en momenten
Oplossing neerschrijven van de dwarkracht en het buigend moment"

# ╔═╡ eaf76ba4-846a-4a49-a5b9-2a03745f2305
md"#### Hoekverdraaiing en doorbuiging
Oplossing neerschrijven van de hoekverdraaiing en de doorbuiging"

# ╔═╡ 2b4be6eb-8ad5-422a-99d8-a45a20e02c69
md"## *Dependencies* en hulpfuncties
Hieronder worden de *dependencies* geladen en de hulpfuncties gedefinieerd"

# ╔═╡ 91f347d9-e9b6-4e53-9093-20d1987f8ca8
md"Start de `plotly` backend"

# ╔═╡ 60615a85-81d3-4237-8ad4-e43e856b8902
plotly()

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
md"### Berekening
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
a, b, p, F, L, EI = symbols("a b p F L EI", real=true)

# ╔═╡ 5d5aeb91-0507-4cab-8151-8b19389bb720
deel1 = (
	a => 0,
	b => x,
	L => l,
	p => 20,
	EI => EI_
)

# ╔═╡ a34c804b-399a-4e40-a556-1e590757d048
deel2 = (
	a => x,
	b => l,
	L => l,
	p => 10,
	EI => EI_
)

# ╔═╡ e7ba9264-9bff-45dc-89f8-44d09cf3898f
md"""
### 1. Verdeelde belasting van $a$ tot $b$

**Eenvoudig** opgelegde ligger, opwaartse kracht = positief
"""

# ╔═╡ 81f8c16e-9863-42b3-a91c-df51323b091f
md"Moment in de steunpunten = $0$ $\rightarrow$ evenwicht er rond uitschrijven ter bepalen van de steunpuntsreacties"

# ╔═╡ fd639425-e97f-4eb0-928b-f1479b09cae6
R11 = (p * (b - a) * ((L - a) + (L - b)) / 2) / L

# ╔═╡ 04dafcd3-8568-426b-9c5f-b21fc09d5e88
R1 = R11(deel1...) + R11(deel2...)

# ╔═╡ 90ad790e-78a9-4a65-89ef-887d3ffcc54f
R12 = (p * (b - a) * (b + a) / 2) / L

# ╔═╡ dfd9aed7-9922-4a47-a0b9-20b0bae0ccbf
R2 = R12(deel1...) + R12(deel2...)

# ╔═╡ a824cc32-c7e4-471b-afa6-88facbea9eed
md"#### 1.1 Bepalen dwarskracht $V(t)$"

# ╔═╡ d7d3fb8b-ed92-44d5-92a2-2cd6144ef4f4
begin
	V11 = - R11  					# Van t: 0 -> a
	V12 = - R11 .+ p .* (t .- a) 	# Van t: a -> b
	V13 = + R12  					# Van t: b -> L
	V1 = V11 .* interval(t, -1e-10, a) .+ V12 .* interval(t, a, b) .+ V13 .* interval(t, b, L)
end

# ╔═╡ 842f1dbd-32b7-4adf-a0c8-6ca6a5fb323d
V = V1(deel1...) + V1(deel2...)

# ╔═╡ ff0dd91a-a69e-4314-8afc-abbb2d80a3ae
md"#### 1.2 Bepalen moment $M(t)$"

# ╔═╡ bf900b34-521f-4b81-914b-8ec88a7cea45
begin
	M11 = - R11 .* t 											# Van t: 0 -> a
	M12 = - R11 .* t .+ p .* (t .- a) .* (t .- (t .+ a) ./ 2) 	# Van t: a -> b
	M13 = - R12 .* (L .- t) 									# Van t: b -> L
	M1 = M11 .* interval(t, -1e-10, a) .+ M12 .* interval(t, a, b) .+ M13 .* interval(t, b, L)
end

# ╔═╡ 5ac2cbd5-0117-404c-a9e7-301269c7e700
M = M1(deel1...) + M1(deel2...)

# ╔═╡ 4e664ecf-c7b1-4f43-a17f-7b05a4fc1abd
md"#### 1.3 Bepalen hoekverdraaiing $\alpha(t)$"

# ╔═╡ b2668eda-4d7e-4e86-9862-86e0f81b07a7
C11, C12, C13 = symbols("C_1 C_2 C_3", real=true)

# ╔═╡ 0ce3368c-17ce-4187-9961-37a4cecefa34
begin
	α11 = - integrate(M11, t) + C11 	# Van t: 0 -> a
	α12 = - integrate(M12, t) + C12 	# Van t: a -> b
	α13 = - integrate(M13, t) + C13 	# Van t: b -> L
	α1_ = α11 .* interval(t, -1e-10, a) .+ α12 .* interval(t, a, b) .+ α13 .* interval(t, b, L)
end

# ╔═╡ c41fc340-b391-4b57-906a-942747f6deae
md"#### 1.4 Bepalen doorbuiging $v(t)$"

# ╔═╡ d1c08c6f-5e05-41d7-ad79-1b99f689d2cc
D11, D12, D13 = symbols("D_1 D_2 D_3", real=true)

# ╔═╡ 67d43f7e-7516-40aa-bfc4-76ac897aa125
begin
	v11 = integrate(α11, t) + D11 	# Van t: 0 -> a
	v12 = integrate(α12, t) + D12 	# Van t: a -> b
	v13 = integrate(α13, t) + D13 	# Van t: b -> L
	v1_ = v11 .* interval(t, -1e-10, a) .+ v12 .* interval(t, a, b) .+ v13 .* interval(t, b, L)
end

# ╔═╡ 5b6e5cbb-c629-468a-994d-144868734d87
md"#### 1.5 Kinematische randvoorwaarden
De ligger heeft een continue vervorming en ook de hoekverdraaiing verloopt continu."

# ╔═╡ 4454c124-23af-4c6b-8931-5fe697f05d4c
rvw1 = [
		# Vervormingen
		v11(t=>0), 
		v11(t=>a) - v12(t=>a), 
		v12(t=>b) - v13(t=>b), 
		v13(t=>L), 
		# Hoekverdraaiingen 
		α11(t=>a) - α12(t=>a), 
		α12(t=>b) - α13(t=>b)
	]

# ╔═╡ 9b4fefd7-94ff-434b-b484-776a0f799f40
opl1 = solve(rvw1, [C11, C12, C13, D11, D12, D13])

# ╔═╡ 04189ae1-9ae4-4bec-b70c-e1416319309a
EIα1 = α1_(opl1...)

# ╔═╡ 1dd87101-625f-4f80-8d0f-7a407728fb7a
α1 = EIα1 / EI # rad

# ╔═╡ de11febf-ec48-4f87-9215-0614910fcec2
EIv1 = v1_(opl1...)

# ╔═╡ d5e3126e-74fb-4f5c-a140-8cf033122adb
v1 = EIv1 / EI # volgens gekozen lengteenheid

# ╔═╡ 57aff837-27ed-460d-b8e6-61c7274d1ccf
md"""
### 2. Puntlast $F$ ter hoogte van abscis $a$

**Eenvoudig** opgelegde ligger, reactiekracht opwaarts = positief, aangrijpende kracht neerwaarts = positief 
"""

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
	M21 = - R21 .* t 					# Van t: 0 -> a
	M22 = - R21 .* t + F .* (t - a) 	# Van t: a -> L
	M2 = M21 .* interval(t, -1e-10, a) .+ M22 .* interval(t, a, L)
end

# ╔═╡ 626f22a6-e5b9-4406-99d5-8824cc06b9b3
md"#### 2.3 Bepalen hoekverdraaiing $\alpha(t)$"

# ╔═╡ 5d69109b-9099-4ee7-bf10-649e22067a19
C21, C22 = symbols("C_1 C_2", real=true)

# ╔═╡ bb6cef33-bb5a-4f59-a95b-0dd2ffc07fc5
begin
	α21 = - integrate(M21, t) + C21 	# Van t: 0 -> a
	α22 = - integrate(M22, t) + C22 	# Van t: a -> L
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

# ╔═╡ 20d3d42b-cb8c-4263-956a-8211292b81ba
α = α1(deel1...) + α2(deel1...)

# ╔═╡ d974e8c6-ecf2-42ed-b004-a6e9ff7936c8
EIv2 = v2_(opl2...)

# ╔═╡ 7b685a83-6541-4fd7-8d2f-502a07c252a7
v2 = EIv2 / EI

# ╔═╡ 3bbe41e1-b5ca-4b4b-a6e5-1f5449ab2178
v = v1(deel1...) + v2(deel1...)

# ╔═╡ e449b656-9f2b-4e34-b97f-12a9d75c7d22
grafiek = begin
	rng = 0:0.05:l
	plot1 = plot(rng, V, title="Dwarskracht", lw=2, c="lightsalmon", ylabel="kN")
	plot2 = plot(rng, M, title="Moment", lw=2, c="dodgerblue", ylabel="kNm")
	plot3 = plot(rng, α, title="Hoekverdraaiing", lw=2, c="grey", ylabel="rad")
	plot4 = plot(rng, v, title="Doorbuiging", lw=2, c="purple", ylabel="mm")
	plot(plot1, plot2, plot3, plot4, layout=(2,2), legend=false)
	# ylabel!("kracht [kNm]")
end

# ╔═╡ e5f707ce-54ad-466e-b6a6-29ad77168590
grafiek

# ╔═╡ 38db521f-f478-459e-83f7-6a7dbbd5568a
md"""
### 3. Voorbeelden
"""

# ╔═╡ 8a382890-6b33-478e-abd6-cc0aa079f8d2
begin
	value_p = @bind _p NumberField(0:50, default=2)
	md"""
	Waarde voor $p$: $value_p kN/m
	"""
end

# ╔═╡ b0cb9a50-a7e2-48ef-ae7d-431d04a7e055
BC1 = a => 1, b => 3, L => 5, p => _p, EI => EI_

# ╔═╡ 4c329718-55a7-415c-91e0-a2e0199169de
md"""
#### 3.1 Verdeelde belasting $p$

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
	value_F = @bind _F NumberField(0:200, default=50)
	value_a = @bind _a NumberField(0:0.01:5, default=2)
	md"""
	Waarde voor $a$: $value_a m
	
	Waarde voor $F$: $value_F kN
	"""
end

# ╔═╡ 2c9b754b-4632-460e-866e-54e1b6d8e0e7
begin
	BC2 = a => _a, L => 5, F => _F, EI => EI_
end

# ╔═╡ 741caaac-8f2b-4e64-a15d-d363382b6e3f
md"""
#### 3.2 Puntbelasting $F$

Puntbelasting volgens $BC2
"""

# ╔═╡ 5d6c0fb3-0dd1-427b-b732-b387640cb9f3
begin
	plot(0:0.1:5, V2(BC2...), label="Dwarskracht [kN]", legend=false)
	plot!(0:0.1:5, M2(BC2...), label="Moment [kNm]")
	plot!(0:0.1:5, α2(BC2...) .* 1000, line = (1, :dashdot), label="Hoekverdraaiing [mrad]")
	plot!(0:0.1:5, v2(BC2...) .* 1000, line = (1, :dashdot), label="Doorbuiging [mm]")
end

# ╔═╡ 0be51e3f-ed13-46c1-921a-ab20aa707595
md"""
#### 3.3 Samenstel krachten

Samenstel van krachten uit **3.1** en **3.2**
"""

# ╔═╡ f0418f1f-3dab-4b1f-8a18-6d8ddcf07523
begin
	plot(0:0.1:5, (V1 + V2)(BC1..., BC2...), label="Dwarskracht [kN]", legend=false)
	plot!(0:0.1:5, (M1 + M2)(BC1..., BC2...), label="Moment [kNm]")
	plot!(0:0.1:5, (α1 + α2)(BC1..., BC2...) .* 1000, line = (1, :dashdot), label="Hoekverdraaiing [mrad]")
	plot!(0:0.1:5, (v1 + v2)(BC1..., BC2...) .* 1000, line = (1, :dashdot), label="Doorbuiging [mm]")
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
md"""### Integralen en analogiëen van Mohr

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
### Stelling van Green

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

# ╔═╡ Cell order:
# ╟─c4c79ab2-d6b7-11eb-09d0-e3cbf2c9d6e9
# ╟─2a3d44ad-9ec2-4c21-8825-dbafb127f727
# ╟─6a04789a-c42a-4ac9-8d05-ee20442ad60d
# ╟─31851342-e653-45c2-8df6-223593a7f942
# ╟─a81fbf3e-f5c7-41c7-a71e-68f8a9589b45
# ╟─e5f707ce-54ad-466e-b6a6-29ad77168590
# ╟─8f910bf3-5227-4113-9476-6136194a5e60
# ╟─78a060bd-f930-4205-a956-abbb72797c1c
# ╟─3e479359-d1a8-4036-8e9c-04317efde55a
# ╟─5bacbd35-70eb-401d-bb62-23f6c17410b0
# ╟─97ba93ff-880a-4625-9bf8-da385db57568
# ╟─03e08a96-29c2-4921-b107-ded3f7dce079
# ╟─b5535266-c6a1-4770-be99-6d1fd79d8543
# ╠═5d5aeb91-0507-4cab-8151-8b19389bb720
# ╠═a34c804b-399a-4e40-a556-1e590757d048
# ╟─7ddacc3e-3877-4c7d-8127-b37a5e30b85a
# ╟─b70d1695-7e91-4903-a239-2a3adb4c3bd8
# ╠═04dafcd3-8568-426b-9c5f-b21fc09d5e88
# ╠═dfd9aed7-9922-4a47-a0b9-20b0bae0ccbf
# ╟─03dfa81c-eaa3-4273-bfff-ab4c8159ee35
# ╠═842f1dbd-32b7-4adf-a0c8-6ca6a5fb323d
# ╠═5ac2cbd5-0117-404c-a9e7-301269c7e700
# ╟─eaf76ba4-846a-4a49-a5b9-2a03745f2305
# ╠═20d3d42b-cb8c-4263-956a-8211292b81ba
# ╠═3bbe41e1-b5ca-4b4b-a6e5-1f5449ab2178
# ╟─e449b656-9f2b-4e34-b97f-12a9d75c7d22
# ╟─2b4be6eb-8ad5-422a-99d8-a45a20e02c69
# ╠═992f5882-98c6-47e4-810c-81293a396c75
# ╟─91f347d9-e9b6-4e53-9093-20d1987f8ca8
# ╠═60615a85-81d3-4237-8ad4-e43e856b8902
# ╟─a841663b-a218-445f-8249-a28a766cbde5
# ╠═8d67ceaf-7303-4fb2-9577-a7fd2db6d233
# ╟─048926fe-0fa3-44c4-8772-0e4adae576a4
# ╠═79cf1b35-6ec0-4950-9f47-e800dee0b44a
# ╠═265977b4-0fd8-4e38-aa46-6be5bcd00420
# ╟─6428b28d-7aa9-489d-b2b9-c08db5876342
# ╠═7683a362-ab86-4f19-964d-e71a61e86436
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
# ╟─81f8c16e-9863-42b3-a91c-df51323b091f
# ╟─fd639425-e97f-4eb0-928b-f1479b09cae6
# ╟─90ad790e-78a9-4a65-89ef-887d3ffcc54f
# ╟─a824cc32-c7e4-471b-afa6-88facbea9eed
# ╟─d7d3fb8b-ed92-44d5-92a2-2cd6144ef4f4
# ╟─ff0dd91a-a69e-4314-8afc-abbb2d80a3ae
# ╟─bf900b34-521f-4b81-914b-8ec88a7cea45
# ╟─4e664ecf-c7b1-4f43-a17f-7b05a4fc1abd
# ╟─b2668eda-4d7e-4e86-9862-86e0f81b07a7
# ╟─0ce3368c-17ce-4187-9961-37a4cecefa34
# ╟─04189ae1-9ae4-4bec-b70c-e1416319309a
# ╟─1dd87101-625f-4f80-8d0f-7a407728fb7a
# ╟─c41fc340-b391-4b57-906a-942747f6deae
# ╟─d1c08c6f-5e05-41d7-ad79-1b99f689d2cc
# ╟─67d43f7e-7516-40aa-bfc4-76ac897aa125
# ╟─de11febf-ec48-4f87-9215-0614910fcec2
# ╟─d5e3126e-74fb-4f5c-a140-8cf033122adb
# ╟─5b6e5cbb-c629-468a-994d-144868734d87
# ╠═4454c124-23af-4c6b-8931-5fe697f05d4c
# ╟─9b4fefd7-94ff-434b-b484-776a0f799f40
# ╟─57aff837-27ed-460d-b8e6-61c7274d1ccf
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
# ╠═8f4da1f8-3f3c-404d-bac0-79598f92c96f
# ╟─86a4e54c-4461-417b-8322-62bdc08ffab1
# ╟─38db521f-f478-459e-83f7-6a7dbbd5568a
# ╟─4c329718-55a7-415c-91e0-a2e0199169de
# ╟─8a382890-6b33-478e-abd6-cc0aa079f8d2
# ╠═b0cb9a50-a7e2-48ef-ae7d-431d04a7e055
# ╟─8a01cacf-e69a-48bb-ab25-cc0cd3f77071
# ╟─741caaac-8f2b-4e64-a15d-d363382b6e3f
# ╟─dbd3985e-0c0f-41f0-9361-859fd7f2ea6c
# ╟─2c9b754b-4632-460e-866e-54e1b6d8e0e7
# ╟─5d6c0fb3-0dd1-427b-b732-b387640cb9f3
# ╟─0be51e3f-ed13-46c1-921a-ab20aa707595
# ╟─f0418f1f-3dab-4b1f-8a18-6d8ddcf07523
# ╟─bf202301-c645-4698-b931-6626758c569a
# ╟─5f8aab19-c664-4460-8737-0e9c6a758a4a
# ╟─64dafd98-afca-45b3-9aad-5697a4edc08e
# ╟─d53c7125-c433-452a-bbf6-06aa43b756f3
# ╟─eb54b362-4f84-405d-8414-ef35ede5d7de
# ╟─0b786728-2437-4d7f-aa68-b911c145699a
# ╟─ee7c93aa-73c9-4f46-8ac1-5898a3bf61bf
