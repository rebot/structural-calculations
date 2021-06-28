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
using PlutoUI, ImageView, Images, Conda, PyCall, SymPy, Plots, HTTP, JSON

# ╔═╡ c4c79ab2-d6b7-11eb-09d0-e3cbf2c9d6e9
md"# Berekening profiel 3
Profiel die de muur tussen de gang en de badkamer ondersteunt, maar dus ook een deel van de vloerplaat van de eerste verdieping"

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

# ╔═╡ 04b77a81-2e9c-4af9-80a4-088c3b52ca81
md"Gebruik `@syms` om *SymPy symbols* te definiëren of gebruik de functie `symbols`. De laatste optie heeft het voordeel dat je nadien je invoergegevens nog kan wijzigen. Bij het gebruik van `@syms` kan je dit niet langer. Ook heb je flexibiliteit over de naam bij het gebruik van `symbols`"

# ╔═╡ 5ecfe3ff-1d27-40dd-8e13-79e48a6f7bdb
t, p1, p2, p3, L1, L2, L3, x_steun = symbols("t p_1 p_2 p_3 L_1 L_2 L_3 x_steun", positive=true, real=true)

# ╔═╡ 8f910bf3-5227-4113-9476-6136194a5e60
md"### Randvoorwaarden of *Boundary Conditions*
Definiëer de randvoorwaarden of *Boundary Conditions* $(\text{BC})$, deze sluiten aan bij de hierboven gedefinieerde variabelen. Alle hieronder vermelde stelsel vertrekken vanuit de symbolische benadering. De $\text{BC}$'s worden pas later gesubstitueerd."

# ╔═╡ a1eb360d-4c1b-4e80-b8aa-93cecad1d497
BC = L1 => 2.473, L2 => 1.80, L3 => 0.997, p1 => 19.07, p2 => 55.12, p3 => 32.51, x_steun => 3.995

# ╔═╡ add58b5c-26e9-44e9-916f-13960b7e085c
md"Heaviside van $\text{L}$ kan niet worden berekend, daarom trekken we er $1e-10$ van af"

# ╔═╡ 9281e85f-dd2b-4410-b41d-e233ce5674e9
L = N((L1 + L2 + L3)(BC...) - 1e-10)

# ╔═╡ 08b607c1-a4d7-4633-9344-88d858020d0b
md"In wat volgt wordt als van bepaalde aannames uitgegaan. Het systeem bestaat feitelijk uit een *piecewise* functie waarvan de intervallen bepaald zijn uit de relatie tussen $L_1$, $L_2$, $L_3$ en $x_steun$. Indien $x_steun$ niet langer binnen de derde verdeelde belasting valt, dan zijn **onderstaande formules niet langer geldig**. **Controleer** dus zeker altijd **je randvoorwaarden!**"

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
EI = 210000 * info["Iy"] / 10^9 # kNm2

# ╔═╡ 43ff70cc-235f-44e4-9a32-beabd9de7abb
md"### Steunpunten
Bepaal de krachten in de steunpunten door het momentenevenwicht uit te schrijven in de steunpunten. Het moment ter hoogte van de steunpunten is $0$, dus uit dit gegeven bereken je eenvoudig de krachten ter hoogte van de steunpunten. Bij een **statisch** bepaalde constructie bepaal je dus in 1 tijd je reactiekrachten.

> Hyperstatische constructie?

Een **hyperstatische** constructie kun je oplossen door het *snijden* in de krachten en het te vervangen door onbekende krachten. Je gaat door met *snijden* tot je een statisch bepaalde constructie bekomt. Bij de oplossing leg je nadien bijkomende beperkingen op. Ter hoogte van het steunpunt zal bijvoorbeeld de vervorming er gelijk moeten zijn aan $0$ of de rotatie $0$ indien je *gesneden* hebt in een momentvaste verbinding"

# ╔═╡ 55883ecc-2d5d-4d51-be13-1163ee70b29f
R2 = (p1 * L1 ^ 2 / 2 + p2 * L2 * (L1 + L2/2) + p3 * L3 * (L1 + L2 + L3/2)) / x_steun

# ╔═╡ 38521108-210f-4306-86e4-e1ac29de93ca
R1 = (p1 * L1 + p2 * L2 + p3 * L3) - R2 

# ╔═╡ 99e49c7b-b2dd-49dc-bee1-336d4d1334b1
md"### Berekening
Bepaal de dwarskrachten $V(t)$ en momenten $M(t)$ voor een eenvoudig opgelegde ligger met twee verdeelde belastingen. Nadien bepalen we ook de hoekverdraaiing $\alpha(t)$ en de doorbuiging $v(t)$."

# ╔═╡ 9c08891c-1269-43f8-8095-28eee34bbb3a
md"#### Dwarskracht $V$ en buigend moment $M$
Berekening van de interne krachten. BIj een **statisch** bepaalde constructie zijn deze niet afhankelijk van de *stijfheid*, bij een **hyperstatische** constructie wel en volgt het dwarskrachtverloop pas uit het oplossen van een stelsel"

# ╔═╡ db19bc67-2894-4bd7-a03c-6d28dfedd4d2
md"#### Hoekverdraaiing $\alpha$ en doorbuiging $v$
Deze worden berekend uit de kromming $\chi$."

# ╔═╡ 67c992cd-2237-400c-93be-d65048e3b2ad
md"We wensen de **vervormingen** $v(t)$ te kennen van de ligger, hiervoor grijpen we terug naar de volgende theorie. De kromming $\chi$ is gelijk aan de verhouding tussen het moment en de buigstijfheid.

$$\chi = \dfrac{\text{M}}{\text{EI}} = \dfrac{d\alpha}{dt} = \dfrac{d^2v}{dt^2}$$

Merk op dat we hier $t$ hanteren als indicatie voor de positie op de ligger."

# ╔═╡ 9061dd78-2ab0-4fd4-973d-8687ddcd32c8
md"De ligger wordt opgeknipt in een aantal delen, een *piecewise* functie. Elk deel wordt geintegreerd. Constantes komen op de proppen die nadien via een stelsel bepaald dienen te worden. Voor elk deel wordt een **unieke** constante gedefinieerd."

# ╔═╡ 9339102e-af71-4a56-94a5-f3157dd78740
C1, D1, C2, D2, C3, D3, C4, D4 = symbols("C_1 D_1 C_2 D_2 C_3 D_3 C_4 D_4", real=true)

# ╔═╡ bf8af7b8-1f5f-4024-8399-8bf24bcc8bf6
md"Bereken de hoekverdraaiing, hierbij hebben we even voor het gemak de *buigstijfheid* $\text{EI}$ **niet meegenomen in de berekening**. Dus onderstaande moet je feitelijk allemaal delen door $\text{EI}$ wat we ook later gaan doen"

# ╔═╡ 96134cde-f7e4-4bd5-b3c0-2fa05708f7f4
md"### Kinematische randvoorwaarden
Leg de kinematische randvoorwaarden op om de constantes te gaan bepalen. Deze voorwaarden bestaan onderander uit $v(t=>0) = 0$ en $v(t=>(L1 + L2)) = 0$. De ligger heeft een continue vervorming en ook de hoekverdraaiing verloopt continu. 

> Hyperstatische constructie?

Bij een **hyperstatische** constructie worden extra randvoorwaarden opgelegd. Zo zal bijvoorbeeld naar de verticale kracht van een steunpunt *gesneden* zijn en dien nu opgelegd te worden dat de vervorming er gelijk is aan $0$."

# ╔═╡ 42008bf2-1584-4dc5-bfb4-20f1f672a4b7
md"### Invoeren oplossing
Voer de oplossing in die bepaald is uit de kinematische randvoorwaardes"

# ╔═╡ 7ddacc3e-3877-4c7d-8127-b37a5e30b85a
md"### Resultaten
Haal de resultaten op en geef ze weer op een grafiek."

# ╔═╡ b70d1695-7e91-4903-a239-2a3adb4c3bd8
md"#### Reactiekrachten"

# ╔═╡ 59ce2926-09ea-4e9e-9ace-af33127c3984
md"Waarde van $\text{R1}$ = $(round(R1(BC...), digits=2)) kN"

# ╔═╡ 939b3526-6be6-4e92-9243-68809c9daf80
md"Waarde van $\text{R2}$ = $(round(R2(BC...), digits=2)) kN"

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
	0.5 * (sign(t) + 1)
end

# ╔═╡ 048926fe-0fa3-44c4-8772-0e4adae576a4
md"Ook `SymPy` heeft een methode Heaviside - functie te gebruiken via `PyCall`"

# ╔═╡ 79cf1b35-6ec0-4950-9f47-e800dee0b44a
# Bij deze definitie is de waarde bij t=0 gelijk aan 'onbestaande'
heaviside = sympy.functions.special.delta_functions.Heaviside

# ╔═╡ 265977b4-0fd8-4e38-aa46-6be5bcd00420
function interval(t, a, b)
	# Bij t=b wordt een waarde van 0.5 geretourneerd (limitatie)
	heaviside(t-a) - heaviside(t-b) 
end

# ╔═╡ 6a449992-2801-4a0d-a5dd-df0a2a381b9b
begin
	# Opsplitsen per deel variabele belasting
	V1 = R1 - p1 * t
	V2 = R1 - p1 * L1 - p2 * (t - L1)
	V3 = R1 - p1 * L1 - p2 * (t - L1) + R2  
	V4 = p3 * ((L1 + L2 + L3) - t)
	V = V1 .* interval(t, 0, L1) + V2 .* interval(t, L1, x_steun) + V3 .* interval(t, x_steun, L1 + L2) + V4 .* interval(t, L1 + L2, L1 + L2 + L3)
end

# ╔═╡ 5e787e9a-6e07-4917-8327-843d5063115f
dwarskracht = V(BC...)

# ╔═╡ e1064739-cae5-48b7-ac59-f45a0e8fc64a
begin
	# Opsplitsen per deel variabele belasting
	M1 = R1 * t - p1 * t ^ 2 / 2
	M2 = R1 * t - p1 * L1 * (t - L1/2) - p2 * (t - L1) ^ 2 / 2
	M3 = R1 * t - p1 * L1 * (t - L1/2) - p2 * (t - L1) ^ 2 / 2 + R2 * (t - x_steun)
	M4 = - p3 * ((L1 + L2 + L3) - t) ^ 2 / 2 
	M = M1 .* interval(t, 0, L1) + M2 .* interval(t, L1, x_steun) + M3 .* interval(t, x_steun, L1 + L2) + M4 .* interval(t, L1 + L2, L1 + L2 + L3)
end

# ╔═╡ 7c3aaf49-ea8d-46e2-b34a-51dfc727b1c7
moment = M(BC...)

# ╔═╡ 927401a6-e4bc-46e2-a65e-8436a7ea5278
begin
	# Opsplitsen per deel variabele belasting
	α1 = integrate(M1, t) + C1
	α2 = integrate(M2, t) + C2
	α3 = integrate(M3, t) + C3
	α4 = integrate(M4, t) + C4
	α = α1 .* interval(t, 0, L1) + α2 .* interval(t, L1, x_steun) + α3 .* interval(t, x_steun, L1 + L2) + α4 .* interval(t, L1 + L2, L1 + L2 + L3)
end

# ╔═╡ 6cf507be-7328-47e3-8312-dcac4c29cdd9
begin
	# Opsplitsen per deel variabele belasting
	v1 = integrate(α1, t) + D1
	v2 = integrate(α2, t) + D2
	v3 = integrate(α3, t) + D3
	v4 = integrate(α4, t) + D4
	v = v1 .* interval(t, 0, L1) + v2 .* interval(t, L1, x_steun) + v3 .* interval(t, x_steun, L1 + L2) + v4 .* interval(t, L1 + L2, L1 + L2 + L3)
end

# ╔═╡ 833e2a1d-5264-4b02-a891-b6ee063fe60d
d = solve([v1(t=>0), v1(t=>L1) - v2(t=>L1), v2(t=>x_steun) - v3(t=>x_steun), v2(t=>x_steun), v3(t=>(L1 + L2)) - v4(t=>(L1 + L2)), α1(t=>L1) - α2(t=>L1), α2(t=>x_steun) - α3(t=>x_steun), α3(t=>(L1 + L2)) - α4(t=>(L1 + L2))], [C1, C2, C3, C4, D1, D2, D3, D4])

# ╔═╡ b49f62de-505f-4447-81a8-9eace4283329
EIα = α.subs(d)

# ╔═╡ 2d46f88c-d157-4754-a8e8-e023432625b4
hoekverdraaiing = EIα(BC...) / EI # rad

# ╔═╡ 33b7355d-38fc-472c-aa62-e0273c3c0c55
EIv = v.subs(d)

# ╔═╡ be75289e-1429-4b0d-9a58-92dfb915f8e8
doorbuiging = EIv(BC...) / EI * 1000 # mm

# ╔═╡ e449b656-9f2b-4e34-b97f-12a9d75c7d22
begin
	_x = 0:0.05:L
	_m = map(moment, _x)
	_v = map(dwarskracht, _x)
	_h = map(hoekverdraaiing, _x)
	_d = map(doorbuiging, _x)
	# Verschillende opties http://docs.juliaplots.org/latest/tutorial/#tutorial
	plot1 = plot(_x, _v, title="Dwarskracht", lw=2, c="lightsalmon", ylabel="kN")
	plot2 = plot(_x, _m, title="Moment", lw=2, c="dodgerblue", ylabel="kNm")
	plot3 = plot(_x, _h, title="Hoekverdraaiing", lw=2, c="grey", ylabel="rad")
	plot4 = plot(_x, _d, title="Doorbuiging", lw=2, c="purple", ylabel="mm")
	plot(plot1, plot2, plot3, plot4, layout=(2,2), legend=false)
	# ylabel!("kracht [kNm]")
end

# ╔═╡ 6428b28d-7aa9-489d-b2b9-c08db5876342
md"Naast `Heaviside` is er ook een methode `Piecewise` via `PyCall` aan te roepen. Helaas ondersteunen deze functie wel geen Array calls, dus moet je de `map` functie in *Julia* gaan gebruiken om bijvoorbeeld te gaan plotten"

# ╔═╡ 7683a362-ab86-4f19-964d-e71a61e86436
# Functie roep je aan met f(t) = piecewise((5, t < 2), (10, t <= 4))
piecewise = sympy.functions.elementary.piecewise.Piecewise

# ╔═╡ Cell order:
# ╟─c4c79ab2-d6b7-11eb-09d0-e3cbf2c9d6e9
# ╟─2a3d44ad-9ec2-4c21-8825-dbafb127f727
# ╟─6a04789a-c42a-4ac9-8d05-ee20442ad60d
# ╟─31851342-e653-45c2-8df6-223593a7f942
# ╟─a81fbf3e-f5c7-41c7-a71e-68f8a9589b45
# ╟─04b77a81-2e9c-4af9-80a4-088c3b52ca81
# ╠═5ecfe3ff-1d27-40dd-8e13-79e48a6f7bdb
# ╟─8f910bf3-5227-4113-9476-6136194a5e60
# ╠═a1eb360d-4c1b-4e80-b8aa-93cecad1d497
# ╟─add58b5c-26e9-44e9-916f-13960b7e085c
# ╠═9281e85f-dd2b-4410-b41d-e233ce5674e9
# ╟─08b607c1-a4d7-4633-9344-88d858020d0b
# ╟─78a060bd-f930-4205-a956-abbb72797c1c
# ╟─3e479359-d1a8-4036-8e9c-04317efde55a
# ╟─5bacbd35-70eb-401d-bb62-23f6c17410b0
# ╠═97ba93ff-880a-4625-9bf8-da385db57568
# ╠═03e08a96-29c2-4921-b107-ded3f7dce079
# ╟─43ff70cc-235f-44e4-9a32-beabd9de7abb
# ╠═38521108-210f-4306-86e4-e1ac29de93ca
# ╠═55883ecc-2d5d-4d51-be13-1163ee70b29f
# ╟─99e49c7b-b2dd-49dc-bee1-336d4d1334b1
# ╟─9c08891c-1269-43f8-8095-28eee34bbb3a
# ╠═6a449992-2801-4a0d-a5dd-df0a2a381b9b
# ╠═e1064739-cae5-48b7-ac59-f45a0e8fc64a
# ╟─db19bc67-2894-4bd7-a03c-6d28dfedd4d2
# ╟─67c992cd-2237-400c-93be-d65048e3b2ad
# ╟─9061dd78-2ab0-4fd4-973d-8687ddcd32c8
# ╠═9339102e-af71-4a56-94a5-f3157dd78740
# ╟─bf8af7b8-1f5f-4024-8399-8bf24bcc8bf6
# ╠═927401a6-e4bc-46e2-a65e-8436a7ea5278
# ╠═6cf507be-7328-47e3-8312-dcac4c29cdd9
# ╟─96134cde-f7e4-4bd5-b3c0-2fa05708f7f4
# ╠═833e2a1d-5264-4b02-a891-b6ee063fe60d
# ╟─42008bf2-1584-4dc5-bfb4-20f1f672a4b7
# ╠═b49f62de-505f-4447-81a8-9eace4283329
# ╠═33b7355d-38fc-472c-aa62-e0273c3c0c55
# ╟─7ddacc3e-3877-4c7d-8127-b37a5e30b85a
# ╟─b70d1695-7e91-4903-a239-2a3adb4c3bd8
# ╟─59ce2926-09ea-4e9e-9ace-af33127c3984
# ╟─939b3526-6be6-4e92-9243-68809c9daf80
# ╟─03dfa81c-eaa3-4273-bfff-ab4c8159ee35
# ╠═5e787e9a-6e07-4917-8327-843d5063115f
# ╠═7c3aaf49-ea8d-46e2-b34a-51dfc727b1c7
# ╟─eaf76ba4-846a-4a49-a5b9-2a03745f2305
# ╠═2d46f88c-d157-4754-a8e8-e023432625b4
# ╠═be75289e-1429-4b0d-9a58-92dfb915f8e8
# ╠═e449b656-9f2b-4e34-b97f-12a9d75c7d22
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
