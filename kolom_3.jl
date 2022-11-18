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

# ╔═╡ 64702f65-43d1-4b00-bbed-d5a70d77fb8a
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    # instantiate, i.e. make sure that all packages are downloaded
    Pkg.instantiate()

    using  PlutoUI, ImageView, Images, Plots, SymPy, Luxor, SQLite, DataFrames, Underscores, Interpolations, PlutoTest, UUIDs
end

# ╔═╡ 5f090cf6-bf5d-4663-860c-d694b82ca64a
situatieschets = load("./assets/img/profiel_5.jpg")

# ╔═╡ 6fd93b12-b898-415c-93e1-5c3c6337bd9f
md"""
## Conclussie
Een controle van de draagkracht van de kolom is uitgevoerd, dit zowel in **GGT** als **UGT**. Onderstaande controles zijn uitgevoerd.

Controles in **GGT**

 $\longrightarrow$ Controle der vervormingen - zie de controles onder het hoofdstuk *Controle*

Controles in **UGT**

 $\longrightarrow$ Doorsnede- en stabiliteitscontrole - zie de controles onder het hoofdstuk *Controle*

Algemeen (conservatief):

- **Elastische toetsing** aan de hand van het vloeicriterium van *Maxwell–Huber–Hencky–von Mises*, met $\sigma_{x,Ed}$ de spanning in de lengterichting, $\sigma_{z,Ed}$ de spanning in de dwarsrichting en $\tau_{Ed}$ de schuifspanning in een punt, maar **controle op basis van weerstanden** en interactie tussen $N_{Rd}$, $V_{Rd}$ en $M_{Rd}$ geniet voorkeur.
$$\left(\dfrac{\sigma_{x,Ed}}{f_y/\gamma_{M0}}\right)^2 + \left(\dfrac{\sigma_{z,Ed}}{f_y/\gamma_{M0}}\right)^2 - \left(\dfrac{\sigma_{x,Ed}}{f_y/\gamma_{M0}}\right)\left(\dfrac{\sigma_{z,Ed}}{f_y/\gamma_{M0}}\right) + 3 \left(\dfrac{\tau_{Ed}}{f_y/\gamma_{M0}}\right) \leq 1$$

- **Conservatieve benadering** door het **lineair optellen** verhouding rekenwaarden belastingseffecten en hun weerstand kan ook. 
$$\dfrac{N_{Ed}}{N_{Rd}} + \dfrac{M_{y,Ed}}{M_{y,Rd}} + \dfrac{M_{z,Ed}}{M_{z,Rd}} <= 1$$

Een **controle op basis van weerstanden** en met interactie tussen $N_{Rd}$, $V_{Rd}$ en $M_{Rd}$ is beschouwd in onderhavige rekennota.
"""

# ╔═╡ a12b2f6b-0f6f-4891-8e49-e9c0456cb203
md"""
### Doorsnedecontrole `:UGT`
"""

# ╔═╡ fc3409d7-2873-4410-8e9d-299c4dbfd4ab
md"""
### Stabiliteitscontrole `:UGT`
"""

# ╔═╡ 99cfd8a5-362a-48a6-9c8f-aca67c63a616
md"""
### Vervormingen `:GGT`
"""

# ╔═╡ 479ce586-0709-42a1-aa7d-2e7d8e4c5b7b
md"""
## Geometrie en materiaal
De geometrie is af te lezen op de *situatieschets*.
"""

# ╔═╡ 2562daf7-66f5-4b9d-8b6e-9b50095d4dd3
geom = (
	L = 2.9, # m - verdiepingshoogte = 2.7m - 0.22 voor het profiel + 0.38cm uitgr.
)

# ╔═╡ 2f321431-5f92-453c-bfb2-ce3c6f7f81a2
md"""
Profieldoorsnede
"""

# ╔═╡ 81d77b92-3499-451d-b485-b8378cdbf611
kolom = (
	naam = "SHS 140/5",
	kwaliteit = "S235",
	beschrijving = "Kolom 3",
	knikkromme = :a
)

# ╔═╡ bf7ab900-ec7d-11eb-1a03-b5c7103e6e4c
md"""
# Berekening $(kolom[:beschrijving]) - $(kolom[:naam])
Berekening van **$(kolom[:beschrijving])**, de kolom die de liggers **Profiel 1**, **Profiel 2** en **Profiel 5** ondersteunt en staat voor de beglazing aan de achterijzde van de woning.
"""

# ╔═╡ 96b36181-5dd7-4b7f-b36c-b41c297aee4b
PlutoUI.TableOfContents(title=string("Berekening ",kolom[:beschrijving]), depth=4)

# ╔═╡ 83113699-96e8-4cce-9101-37f016855b49
md"""
Haal de **eigenschappen** op van het gekozen profiel
"""

# ╔═╡ 65052451-ac16-458e-911b-17226c5355d7
md"""
Nominale waarde volgen *NBN EN 1993-1-1 §3.2*
"""

# ╔═╡ 1e3f7495-7255-4319-8a0d-3c2a66305d06
f_yk = parse(Int64, kolom[:kwaliteit][2:end])

# ╔═╡ 0d602b85-8c97-47f6-bdcd-3a5738b94371
md"""
Rekenwaarden van materiaaleigenschappen volgens *NBN EN 1991-1-1 §3.2.6*
"""

# ╔═╡ 15c1009a-be15-4780-8054-d30271af920c
E = 210_000 # MPa

# ╔═╡ 0de5f479-0eef-48bc-8146-757b4ff3b27d
ν = 0.3 # Coëfficiënt van Poisson in het elastisch gebied

# ╔═╡ 5fbb513b-35fc-43cc-b81b-cb52dd572584
md"""
## Belastingen
Overzicht van de aangrijpende belastingen
"""

# ╔═╡ 6967230f-8e86-48d7-affb-8f537f50b053
gevallen = DataFrame([
	(naam="GGT_F", waarde=196.122, beschrijving="Afdracht profiel 5 - lasten GGT Frequent"),
	(naam="GGT_K", waarde=234.511, beschrijving="Afdracht profiel 5 - lasten GGT Karakteristiek"),
	(naam="UGT", waarde=328.105, beschrijving="Afdracht profiel 5 - lasten UGT"),

])

# ╔═╡ 1402febf-ba8c-475a-8f23-a916d8d9815b
replacer = (g = gevallen; Regex(join(g.naam, "|")) => s -> g.waarde[g.naam .== s] |> first)

# ╔═╡ 650a4e73-0ff4-4ab2-be22-70143654aa57
combinaties = select!(
	DataFrame([
		(check=:GGT, naam="F", formule="GGT_F"),
		(check=:GGT_K, naam="F", formule="GGT_K"),
		(check=:UGT, naam="F", formule="UGT")
	]), 
	:, 
	:formule => 
		ByRow(r -> replace(r, replacer) |> (eval ∘ Meta.parse)) => :uitkomst
) # Schrijft het resultaat naar de combinaties

# ╔═╡ 39feffd5-63b2-4f6d-8ffc-21e55ce0f31e
maatgevend = unstack(
	combine(
		groupby(combinaties, [:check, :naam]),
		:uitkomst => maximum => :waarde
	), 
	:check, 
	:naam, 
	:waarde
)

# ╔═╡ c3a0091f-31ee-46e2-bf21-94da754b6cac
md"""
## Berekening
Berekening van de aangrijpende krachtswerking

Controle toepasbaarheid *1ste orderberekening* waard $F_{cr}$ de elastiche kritieke (knik)belasting en $F_{Ed}$ de rekenwaarde van de belastingen

$$\alpha_{cr} = \dfrac{F_{cr}}{F_{Ed}} \geq 10 - \text{elastische berekening}$$
$$\alpha_{cr} = \dfrac{F_{cr}}{F_{Ed}} \geq 15 - \text{plastische berekening}$$
"""

# ╔═╡ 92615040-32a4-400d-818f-5deaef931d66
md"""
### Geometrische imperfectie kolom
Gemetrische imperfectie volgen *NBN EN 1993-1-1 §5.3.2* is afhankelijk van de knikkromme (bepaald volgens tabel 6.2)
"""

# ╔═╡ a6c1043b-70d7-4b42-a883-96e168f80045
figuur5_4 = load("./assets/img/NBN EN 1993-1-1 fig 5.4.png")

# ╔═╡ fe677e91-ab28-40e5-b270-163ac77a1dd1
md"""
Duiding van de scheefstand en vooruitbuiging en mogelijke **equivalente krachten** ter vervanging van de geometrische imperfecties
"""

# ╔═╡ 977c58d5-3bdb-4f34-baee-c5f3acc83155
md"""
#### Initiële scheefstand
Draagt bij tot bijkomende knikgevoeligheid
"""

# ╔═╡ 32c60448-66f4-4d55-8282-abd76c7672a8
md"""
met
"""

# ╔═╡ b5cb73da-c8e6-417f-94a8-0f0fa5ae8321
ϕ₀ = 1//200 # Basiswaarde van de scheefstand

# ╔═╡ b7b47867-f469-46d4-a7e7-0da9f59c4b8c
md"""
#### Initiële vooruitbuiging
Ter bepaling van de bijkomende buigingsknik - Bepaling van de verhouding $e_0 / L$ in functie van de knikkromme van de doorsnede, zie onderstaande tabel
"""

# ╔═╡ 5fc42b0d-0363-4087-acfe-962f3304fccf
tabel5_1 = DataFrame(
	knikkromme = [:a0, :a, :b, :c, :d],
	elastisch = [1//350, 1//300, 1//250, 1//200, 1//150], 	# Grens e₀/L
	plastisch = [1//300, 1//250, 1//200, 1//150, 1//100]	# Grens e₀/L
)

# ╔═╡ 3d0a7e42-8915-41b6-961c-ae45921b53e8
e₀ = tabel5_1.elastisch[tabel5_1.knikkromme .== kolom[:knikkromme]] |> first # e_0

# ╔═╡ db32e45a-ce7c-43b0-977c-c89b62db3b54
md"""
### Belastingschema
Samenstel van de belastingseffecten van enerzijdes de **initiële vervorming** en anderzijds de **intiële vooruitbuiging**
"""

# ╔═╡ 1c0069be-e284-46f3-8ebf-808029b0e8ce
md"""
### Interne krachtswerking
De interne krachtswerking heeft invloed op de bepaling van de doorsnede, alsook op de verdere stabiliteitscontrole (knik problematiek)
"""

# ╔═╡ 79deccb1-5aab-4bfd-857f-55b17250527c
md"""
#### Spanningsverdeling in de doorsnede
Voor een correcte inschatting van de classificatie van het profiel, moeten we de drukzone van de doorsnede kennen
"""

# ╔═╡ 49f763be-0741-4895-adcb-22efd0ad58e5
begin
	slider_tval = @bind tval Slider(0:0.01:geom[:L], show_value=true, default=1.05)
	select_grenstoestand = @bind grenstoestand Select(["UGT", "GGT"], default="GGT")
	md"""
	Kies een locatie voor $t$: $slider_tval
	
	Kies een grenstoestand: $select_grenstoestand
	"""
end

# ╔═╡ 565c0a79-02ab-4f09-838b-a8d5be5b328e
md"""
### Classificatie van de doorsnede
Classificatie volgens doorsnede in categoriën die aangeven hoezeer de **weerstand** en **rotatiecapaciteit** zijn beperkt door de **plooiweerstand**. Voor een **klasse 1** bijvoorbeeld mag er zich een *plastisch scharnier* vormen zonder weerstandsverlies.

**classificatie** = $f(\text{deel onder druk onder beschouwde belastingscombinatie})$
"""

# ╔═╡ da0eddc9-788d-4308-b458-54db04cd0fd2
md"""
Gebasseerd op het spanningsverloop langsheen de kolom (=$f(t)$) wordt de knikkromme bepaald via Tabel 5.2 in *NBN EN 1993-1-1*
"""

# ╔═╡ a16a6888-87b7-4c30-b254-4901630af21b
kolom

# ╔═╡ 5a7c92bf-a811-4cb8-8a37-9f2c4c4b1ad2
md"""
## Controle
Aftoetsen van de interne krachten en vervormingen

!!! warning "Controles"
	Maak gebruik van *enumerate* `Check`met waarde *false* of *true*
"""

# ╔═╡ 5ebe01be-f116-496e-8fd5-a687fc2dacd4
γ_M0, γ_M1, γ_M2 = 1.00, 1.00, 1.25

# ╔═╡ d1163bac-8c98-4aa9-bb79-b2f09e46392f
begin 
	slider_t_ = @bind t_ Slider(0:0.05:geom[:L], show_value=true)
	md"""
	### Uiterste grenstoestanden `:UGT`
	Selecteer de abscis $t$ = $(slider_t_)
	"""
end

# ╔═╡ 3097f9ac-fedd-49f6-853d-ef6b5eee2826
md"""
#### Doorsnede controle
"""

# ╔═╡ ca3f41bd-9491-46c7-bd6b-b078d01509ec
md"""
##### Axiale druk
Berekening volgens *NBN EN 1993-1-1 §6.2.4*
"""

# ╔═╡ a511719f-e67c-4e7f-8c02-06a1c4d67a8f
md"""
##### Buigend moment
Berekening volgens *NBN EN 1993-1-1 §6.2.5* mits in acht name van factor $\rho$ voor combinatie met *Dwarskracht* volgens *NBN EN 1993-1-1 §6.2.8*
"""

# ╔═╡ add548a9-0dd1-4041-9949-fc5a3181e973
md"""
Reductie $M_{Rd}$ bij aanwezigheid van een normaalkracht 
!!! danger "Toepasbaarheid"
	Onderstaande uiteenzetting geldt enkel voor profielen van **klasse 1 en 2**, zie *NBN EN 1993-1-1 §6.2.9.2-3* voor doorsneden van klasse 3 en 4. Ook is in onderstaande uitgegaan van één-assige buiging voor een kolom SHS (dus **stijfheid** in de **twee richting gelijk**)
"""

# ╔═╡ 264294d2-a757-4ce3-90d5-05960151fe6c
md"""
##### Dwarskracht (afschuiving)
Berekening volgens *NBN EN 1993-1-1 §6.2.6*
!!! danger "Toepasbaarheid"
	Onderstaande formule is enkel van toepassing voor **klasse 1 en 2**, voor de elastiche berekeningsmethode voor $V_{c,Rd}$ wordt voor het **kritiek punt** in de doorsnede de onderstaande vergelijking getest met $S$ het statisch moment rond het beschouwde punt en $t$ de dikte ervan.

	$$\dfrac{\tau_{Ed}}{f_y / \left(\sqrt(3)\gamma_{M0}\right)}\leq 1.0\text{  met  } \tau_{Ed} = \dfrac{V_{Ed}\ S}{I\ t}$$
"""

# ╔═╡ 5c064cef-b7c2-4fb6-9013-8afa0f11206c
md"""
##### Wringing (torsie)
Berekening volgens *NBN EN 1993-1-1 §6.2.7*
!!! info "Geen wringing"
	Geen wringing (torsie) grijpt aan. De eenheidscontrole (`UC`) voldoet
"""

# ╔═╡ a5075f8a-6268-4a79-9d86-62db775d2376
md"""
#### Stabiliteit controle
Controle van de knikstabiliteit volgens *NBN EN 1993-1-1 §6.3.1*
"""

# ╔═╡ 60388762-5cee-4ac4-ac92-31fb7fe795c4
md"""
##### Knikstabiliteit bij op druk belaste staven
Volgens *NBN EN 1993-1-1 §6.3.1.1*
!!! danger "Toepasbaarheid"
	Onderstaande uiteenzetting geldt enkel voor staven van **klasse 1, 2 en 3**
"""

# ╔═╡ 9a2bef32-f374-4c2f-93e7-9e1142101e2c
md"""
Bepalen *reductiefactor* voor **knik**
"""

# ╔═╡ e1b27c73-cd31-49c3-9495-b4ce3686a96a
md"""
De imperfectiefactor $\alpha$ is in overeenstemming met de knikkromme volgens Tabel 6.2 in *NBN EN 1993-1-1*. **Knikeffecten** kunnen worden **verwaarloost indien**

$$\bar{\lambda} \leq 0.2 \text{  of  } \dfrac{N_{Ed}}{N_{cr}} \leq 0.04$$
"""

# ╔═╡ 815bd927-24d0-4f02-97c0-d99d9b3ace01
imperfectie = DataFrame([
		(a0 = 0.13, a = 0.21, b = 0.34, c = 0.49, d = 0.76)
]) |> first

# ╔═╡ 4fe78740-be25-404f-8d6c-606f08e82510
α_ = getproperty(imperfectie, kolom[:knikkromme]) # imperfectiefactor

# ╔═╡ b8e307cb-784e-405a-a9a9-351f12ada6c6
md"""
##### Kipstabiliteit bij op buiging belaste staven
Volgens *NBN EN 1993-1-1 §6.3.2*
!!! danger "Toepasbaarheid"
	Onderstaande uiteenzetting geldt enkel voor staven van **klasse 1 en 2** waarbij voor het weerstandsmoment het plastische weerstandsmoment $W_{pl,y}$ mag gehanteerd worden.
"""

# ╔═╡ 3c273c59-cd0b-405b-835b-7ed1d910701d
md"""
Bepalen *reductiefactor* $\chi_{LT}$ voor **kip** waarbij $_{LT}$ staat voor *lateral torsional* buckling
"""

# ╔═╡ bbf8fd14-3176-4966-8060-7d9a2602728d
md"""
Eenvoudige benadering $\lambda_{LT}$ volgens *NBN EN 1993-1-1 ANB - Bijlage H*.
"""

# ╔═╡ 949aa8ef-33f9-455d-9471-de202e2a1fc6
α_LT = getproperty(imperfectie, :a) # imperfectiefactor

# ╔═╡ 9aa171b9-f90c-4951-903d-00862794d1f0
md"""
Berekening $M_{cr}$ volgens *NBN EN 1993-1-1 ANB - Bijlage E*.

Dubbelsymmetrische dwarsdoorsnede (§3 *Bijlage E*)

$$M_{cr}=C_{1}\dfrac{\pi^2EI_{z}}{\left(k_{z}L\right)^2}\left\{\sqrt{\left[\left(\dfrac{k_z}{k_{\omega}}\right)^2\dfrac{I_{\omega}}{I_z}+\dfrac{(k_zL)^2GI_T}{\pi^2EI_z}+(C_2z_g)^2\right]}-C_2z_g\right\}$$
"""

# ╔═╡ 6cb6f033-c5ef-4852-bb66-3b80c08501d1
md"""
!!! warning "Eenheden eigenschappen"
	Als brondbestand voor de liggers, werd een overzichtstabel van Areloc Mittal gehanteerd. Als bronbestand voor de kolommen, werd een lijst van [eurocodeapplied](www.eurocodeapplied.com) gehanteerd. Controleer of er geen vergroting van de parameters moet toegepast worden.
"""

# ╔═╡ b3128d17-e7a6-4cd1-b9a3-7c2e85e9c1ed
L_steun = geom[:L] # Lengte van de ligger tussen punten met zijdelingse steun

# ╔═╡ daa7b994-81a8-4ddd-93b3-65298c9f917a
# Effectieve lengtefactor k_z = betrekking tot einddraaiing in het vlak
#	- 0.5 volledig ingeklemd 
# 	- 0.7 één einde ingeklemd, één zijde vrije
#	- 1.0 volledig gebrek aan inklemming
k_z = 0.7 # Onderaan ingeklemd

# ╔═╡ 6cb6bdee-5fac-42b6-a55c-35172ce8c8eb
# Effectieve lengtefactor k_ω = betrekking tot welving van het uiteinde
#	- 0.5 volledig ingeklemd 
# 	- 0.7 één einde ingeklemd, één zijde vrije
#	- 1.0 volledig gebrek aan inklemming
k_ω = 1.0 # Kolom kan aan uiteindes niet welven door druk

# ╔═╡ 04316e68-424a-4ae3-8d09-f54a755693da
z_g = 0 # z_a - z_s = verschil belastingspunt tot het zwaartepunt

# ╔═╡ a17412e3-6377-426e-ae0c-c32ce2714aef
md"""
Berekening van de factoren $C_1$, $C_2$ en $C_3$ volgens de tabellen *Tabel E.1 ANB* en *Tabel E.2 ANB* 
"""

# ╔═╡ 4b404a8d-7e1f-4fa5-98b8-f86251b720b6
Ψ_f = 0 # Voor dubbelsymmetrische doorsneden

# ╔═╡ 914aa30b-7a6f-4ca7-a5d0-55dd57deb91e
# Indien k_z = 1.0, volledig gebrek aan inklemming
# Benaderde waarde van C_1 via onderstaande forumule
# C1 = min(1.77 - 1.04 * Ψ + 0.27 * Ψ^2, 2.60)

# ╔═╡ 1d397003-77d2-48eb-aa9a-f21c306a203e
md"""
Indien het momentverloop is ontstaan uit het **gecombineerd effect** van zowel belastingen door **eindmomenten** (inklemming) als door **lijn- en puntbelastingen**, dan worden de figuren *E.3 ANB* tot *E.10 ANB* gehanteerd.

$(load("./assets/img/NBN EN 1993-1-1 ANB fig E.2.png"))

Hierbij worden volgende parameters berekend, waarbij $$M$$ voor het maximale **eindmoment** staat:

$$\mu = \dfrac{q\ L^2}{8\ M} \text{(a)  of  } \dfrac{F\ L}{4\ M} \text{(b)}$$
"""

# ╔═╡ f1033e15-2736-40a9-8403-de14f9076c1a
md"""
In geval van de berekening van de kolommen, nemen we altijd een **positieve** waarde aan van $\mu$, gezien dit leidt tot de kleinste waardes voor de constantes $C_1$ tot $C_3$, immers zijn de buigende momenten afkomstig van geometrische imperfecties en kunnen die elkaars effecten versterken. 
"""

# ╔═╡ ebd5559c-ca01-436e-a6ac-c333349a376f
C_1 = 1.55 # Zie volgende figuur

# ╔═╡ a02a69c2-5250-476f-801b-f62443e42615
C_2 = 0.18 # Zie volgende figuur

# ╔═╡ e09a6e50-b887-489c-9118-a2817aa08513
md"""
De imperfectiefactor $\alpha_LT$ is in overeenstemming met de kipkromme volgens Tabel 6.3 in *NBN EN 1993-1-1*. **Kipeffecten** kunnen worden **verwaarloost indien**

$$\bar{\lambda}_{LT} \leq \bar{\lambda}_{LT,0} \text{  of  } \dfrac{M_{Ed}}{M_{cr}} \leq \bar{\lambda}_{LT,0}^2$$

Waarin $\bar{\lambda}_{LT,0}$ volgens *NBN EN 1993-1-1 §6.3.2.3* gelijk is aan $0.4$
"""

# ╔═╡ 860434ef-648c-4456-aa8c-63fb473f8682
imperfectie_LT = imperfectie[[:a, :b, :c, :d]]

# ╔═╡ e5d3d66d-3975-46ca-80f8-7f02953ff56a
md"""
##### Prismatische, op buiging en druk belaste staven
Volgens *NBN EN 1993-1-1 §6.3.3*
!!! danger "Toepasbaarheid"
	Onderstaande uiteenzetting geldt enkel voor staven van **klasse 1 en 2** waarbij voor het weerstandsmoment het plastische weerstandsmoment $W_{pl,y}$ mag gehanteerd worden.
Staven die aan gecombineerde buiging en druk zijn onderworpen behoren te voldoen aan:

$$\dfrac{N_{Ed}}{\dfrac{\chi_y\ N_{Rk}}{\gamma_{M1}}}+k_{yy}\ \dfrac{M_{y,Ed}+\Delta M_{y,Ed}}{\dfrac{\chi_{LT}\ M_{y,Rk}}{\gamma_{M1}}} \leq 1$$

Merk op dat bovenstaande vergelijking een vereenvoudiging is van formule 6.62 en 6.63 uit *NBN EN 1993-1-1* gezien voor een **SHS** profiel de sterkte in beide richtingen gelijk is. De parameter $k_{yy}$ is een interactiefactor, berekend volgens **bijlage A** (Alternatieve methode 1 normatief). De bijlage is herschreven en toegevoegd als **Bijlage D** in *NBN EN 1993-1-1 ANB*. De parameter $\Delta M_{y,Ed}$ voor een profiel van **klasse 1 tot 3** is gelijk aan $0$
"""

# ╔═╡ a1575d01-f628-492d-9a10-2bd9ad306bb7
md"""
###### Stap **1** - Onderscheid staven gevoelig of niet aan torsie
Volgens *NBN EN 1993-1-1 ANB Bijlage D*
"""

# ╔═╡ baec8eb3-f117-47fb-b05d-92308298f1a3
md"""
Is de staaf **torsie gevoelig**?
"""

# ╔═╡ 327c6862-7f36-49b8-89f0-ed7fcf36cc99
md"""
Berekening **kritieke elastische kracht** met betrekking tot de **torsieknikstabiliteit** $N_{cr,TF}$ en **Euleriaanse elastische knikkracht** $N_{cr,z}$ om de z-as volgens *NBN EN 1993-1-1 ANB Bijlage F*. Merk op, onderstaande berekening is enkel geldig voor een prismatische doorsnede waarbij het zwaartepunt van de doorsnede samenvalt met het torsiecentrum. In onderstaande berekening wordt voor gesloten kokerprofielen de welvingconstante gelijk gesteld aan $0$.
"""

# ╔═╡ 52172a41-72a2-4a8d-baed-b291d68adb3f
md"""
De relevante kniklengte $L_{cr}$ is gelijk aan **$2\times$ de lengte van de kolom** omdat deze onderaan als ingeklemd wordt beschouwd, en bovenaan als vrij. Dit is een conservatieve benadering.
"""

# ╔═╡ 2850392f-fab1-40fd-8487-91216a8fdd76
md"""
De factor $C_1$ hangt af van de **belasting** en de **randvoorwaarden** van de **oplegging** en is bepaald volgens *NBN EN 1993-1-1 ANB Bijlage E* 
"""

# ╔═╡ fba37538-ce55-48e4-979a-e3cf9a6be6cd
md"""
###### Stap **2.a** - Staaf niet gevoelig voor torsie
Volgens *NBN EN 1993-1-1 ANB Bijlage D*. 

We hernemen formules (6.61) en (6.62) uit *NBN EN 1993-1-1* en passen hier alle randvoorwaardes op toe. Prismatische dubbelsymmetrische koker met sterkte in beide assen gelijk.

$$\dfrac{N_{Ed}}{\dfrac{\chi_y\ N_{Rk}}{\gamma_{M1}}}+\mu_y\left[C_{my}\ \dfrac{M_{y,Ed}+\Delta M_{y,Ed}}{\left(1-\dfrac{N_{Ed}}{N_{cr,y}}\right)C_{yy}\dfrac{M_{y,Rk}}{\gamma_{M1}}}\right] \leq 1$$
"""

# ╔═╡ b644b63e-352e-4f55-9d03-03d6cb96ec3d
md"""
Bovenstaande wordt opgesplitst in de eenheidscontrole voor **enkel druk** en het aangrijpen van **enkel** een **buigend moment**, de overige waardes worden samengevoegd tot een **interactiefactor** $k_{yy}$ uit de **Alternatieve methode 2**, we verwijzen dan ook verder naar $k_{yy}$ als naam voor deze term.

$$\dfrac{N_{Ed}}{\dfrac{\chi_y\ N_{Rk}}{\gamma_{M1}}}+\dfrac{\mu_y\ C_{my}\ \chi_{LT}}{\left(1-\dfrac{N_{Ed}}{N_{cr,y}}\right)C_{yy}}\ \dfrac{M_{y,Ed}+\Delta M_{y,Ed}}{\dfrac{\chi_{LT}M_{y,Rk}}{\gamma_{M1}}} \leq 1$$
"""

# ╔═╡ 2430fca4-d88f-4a3e-9129-19f163e7d83a
md"""
De waarde voor de factor $C_{my}$ wordt afgeleid van *Tabel D.1 ANB*. Voor een staaf niet gevoelig voor torstie is $C_{my} = C_{my,0}$. 
"""

# ╔═╡ 906c97c1-136b-4df9-929d-7db6c289cd5b
md"""
Interactiefactor $C_{yy}$ die een maat is voor de hoeveelheid plasticiteit in de staafdoorsnede bij bezwijken.

$$C_{yy} = 1 + (w_y-1)\left[\left(2 - \dfrac{1.6}{w_y}C_{my}^2\bar\lambda_{max} - \dfrac{1.6}{w_y}C_{my}^2\bar\lambda_{max}^2\right)n_{pl}\right]\geq\dfrac{W_{el,y}}{W_{pl,y}}$$
"""

# ╔═╡ 83f412fa-7c1a-4484-9bbf-bc0287cbe5f7
md"""
###### Stap **2.b** - Staaf gevoelig voor torsie
Volgens *NBN EN 1993-1-1 ANB Bijlage D*

We hernemen formules (6.61) en (6.62) uit *NBN EN 1993-1-1* en passen hier alle randvoorwaardes op toe. Prismatische dubbelsymmetrische koker met sterkte in beide assen gelijk.

$$\dfrac{N_{Ed}}{\dfrac{\chi_y\ N_{Rk}}{\gamma_{M1}}}+\mu_y\left[\dfrac{C_{mLT}\ C_{my}}{\chi_{LT}}\ \dfrac{M_{y,Ed}+\Delta M_{y,Ed}}{\left(1-\dfrac{N_{Ed}}{N_{cr,y}}\right)C_{yy}\dfrac{M_{y,Rk}}{\gamma_{M1}}}\right] \leq 1$$
"""

# ╔═╡ 0265c5cf-f768-45c4-aad8-f399e23d3703
md"""
Bovenstaande wordt opgesplitst in de eenheidscontrole voor **enkel druk** en het aangrijpen van **enkel** een **buigend moment**, de overige waardes worden samengevoegd tot een **interactiefactor** $k_{yy}$ uit de **Alternatieve methode 2**, we verwijzen dan ook verder naar $k_{yy}$ als naam voor deze term.

$$\dfrac{N_{Ed}}{\dfrac{\chi_y\ N_{Rk}}{\gamma_{M1}}}+\dfrac{\mu_y\ C_{mLT}\ C_{my}}{\left(1-\dfrac{N_{Ed}}{N_{cr,y}}\right)C_{yy}}\ \dfrac{M_{y,Ed}+\Delta M_{y,Ed}}{\dfrac{\chi_{LT}M_{y,Rk}}{\gamma_{M1}}} \leq 1$$
"""

# ╔═╡ 63523b55-c791-42e5-b3b2-9d03b11e7e2c
md"""
Interactiefactor $C_{yy}$ die een maat is voor de hoeveelheid plasticiteit in de staafdoorsnede bij bezwijken.

$$C_{yy} = 1 + (w_y-1)\left[\left(2 - \dfrac{1.6}{w_y}C_{my}^2\bar\lambda_{max} - \dfrac{1.6}{w_y}C_{my}^2\bar\lambda_{max}^2\right)n_{pl}-b_{LT}\right]\geq\dfrac{W_{el,y}}{W_{pl,y}}$$
"""

# ╔═╡ 3944d762-8c63-4188-9aef-e26236474fca
b_LT = 0 # Maar buiging in 1 richting

# ╔═╡ 88259ae8-a88d-48f0-9660-96a4b00cde35
md"""
De factor $C_{mLT}$ dekt de invloed van de normaalkracht en van de doorsnedevorm op de kipweerstand.
"""

# ╔═╡ 832e20b0-2106-4c09-8a1c-cbf4faa9ea52
md"""
###### Unity check
Onderstaande vorm aangehouden omdat dit in overeenstemming is met *Alternatieve methode 2* opgenomen in *NBN EN 1993-1-1 Bijlage B*. De controle zelf is wel uitgevoerd volgens *Alternatieve methode 1* omdat deze normatief is in België.
"""

# ╔═╡ d59ea3e9-e374-4e80-aee6-3c4878745f0d
md"""
### Bruikbaarheidsgrenstoestanden `:GGT`
Selecteer de abscis $t$ = $(slider_t_)
"""

# ╔═╡ d8003147-45a6-4b8f-960e-70bc80f8cb69
md"""
#### Horizontale verplaatsing
Volgens *NBN EN 1993-1-1 §7.2.2* met verwijzing naar *NBN EN 1990 - bijlage A1.4*. In de natianale bijlage (*ANB*) wordt verwezen naar de norm *NBN B 03-003* die toegepast dient te worden in België. Grenswaarden van de vervorming wordt vastgelegd in tabel 3 onder §7.
"""

# ╔═╡ 695ecf3c-6a51-458d-b63f-8f323df46a8a
md"""
# Achterliggende berekeningen
Hieronder worden algemene controles uitgewerkt
"""

# ╔═╡ 1e5bd62b-5327-4abb-b4c0-9df3c2a92be9
md"""
## Dependencies en hulpfuncties
"""

# ╔═╡ 3c07526e-31f8-4857-bd62-e6fc71d50c5b
md"""
Laad de database in
"""

# ╔═╡ 5da33fcf-33d3-492b-af3a-c07623e87f61
db = SQLite.DB("assets/db/db.sqlite")

# ╔═╡ 6f2b93c1-df30-427a-a0f8-1a3cbc0890bb
DBInterface.execute(db, """
SELECT
	name, G, b, t, A, Av, I, Wel
FROM (
	SELECT
		s.*,
		ABS(s.I - (
				SELECT
					t.I FROM tubes AS t
				WHERE
					t.name = "$(kolom[:naam])")) AS afstand
	FROM
		tubes AS s
	ORDER BY
		afstand ASC
	LIMIT 10)
ORDER BY
	I ASC;	
""") |> DataFrame

# ╔═╡ 1eeb0c6d-523c-423f-897a-fe9aff327c3a
eig = DBInterface.execute(db, """
SELECT
	*
FROM
	tubes
WHERE
	name == "$(kolom[:naam])"
""") |> DataFrame |> first

# ╔═╡ 7f3a6986-dfab-4e82-8eda-1a0bd72b47bd
md"""
Start de `plotly` backend
"""

# ╔═╡ 17faebbf-9fbd-4860-80b9-c5551bc34390
plotly()

# ╔═╡ 43a30a97-42c3-446f-b57d-47af9b47565b
md"""
Eigen `Check` type met ook een eigen uitdraai
"""

# ╔═╡ d35dfa59-d3ba-4cd0-b229-2808e61e609c
@enum Check OK=true NOK=false

# ╔═╡ 01cc6e48-7e78-4c9c-968a-457857f37b00
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

# ╔═╡ 47f629ad-75cd-4400-a07e-ddd22c4f94e8
md"""
Definieer een nieuwe *type* getiteld *Unity Check* of `UC`
"""

# ╔═╡ d3b4ab06-11e2-4fd3-b994-60c6aabf5308
struct UC
	beschrijving::Markdown.MD
	waarde::Float64 # teller
	limiet::Float64 # noemer
end

# ╔═╡ b4205158-167f-4521-a9ef-6b0d39cc9238
struct Constant
	beschrijving::Markdown.MD
	waarde::Real
end

# ╔═╡ 6942d492-5d8b-4a0e-9824-e55318cd03c0
function Base.show(io::IO, mime::MIME"text/html", c::Constant)
	afronden = t -> (d -> round(d, digits=t))

	show(io, mime, Markdown.MD(
			Markdown.LaTeX(
				string( 
					first(c.beschrijving.content).formula,
					"=", 
					c.waarde |> afronden(3)
				)
			)
		)
	)
end

# ╔═╡ fee57389-2d06-447a-ad08-9866b7f72e4b
Base.copy(uc::UC) = UC(uc.beschrijving, uc.waarde, uc.limiet)

# ╔═╡ 0e483762-3725-418b-a67d-56c1815bc5ba
rvw = begin
	for (k, v) in pairs(geom)
		maatgevend[!, k] .= v
	end
	copy(maatgevend)
end

# ╔═╡ a835b337-5d25-47c2-a34c-b74beb4b62de
md"""
Algemene functies om somaties van `Markdown.MD` types mogelijk te maken, alsook de sommatie van de *custom* `UC` *struct*
"""

# ╔═╡ 4186bf7c-dada-447e-8e1c-7c5a695111a6
function Base.:+(md1::Markdown.MD, md2::Markdown.MD)::Markdown.MD
	pgs1, pgs2 = md1.content, md2.content
	if length(pgs1) == 1 && length(pgs2) == 1
		pg1, pg2 = (pgs1, pgs2) .|> first
		tp1, tp2 = (pg1, pg2) .|> typeof
		if all((tp1, tp2) .== Markdown.LaTeX)
			c1, c2 = getproperty.([pg1, pg2], :formula)
			return Markdown.MD(Markdown.LaTeX(string(c1,"+",c2)))
		elseif all((tp1, tp2) .== Markdown.Paragraph)
			c1, c2 = getproperty.([pg1, pg2], :content) .|> first
			return Markdown.MD(Markdown.Paragraph(string(c1," ",c2)))
		else
			return Markdown.MD(Markdown.Paragraph("..."))
		end
	end
end

# ╔═╡ 74a300ff-0972-42e5-996e-52c98a6999c2
function Base.:*(md1::Markdown.MD, md2::Markdown.MD)::Markdown.MD
	pgs1, pgs2 = md1.content, md2.content
	if length(pgs1) == 1 && length(pgs2) == 1
		pg1, pg2 = (pgs1, pgs2) .|> first
		tp1, tp2 = (pg1, pg2) .|> typeof
		if all((tp1, tp2) .== Markdown.LaTeX)
			c1, c2 = getproperty.([pg1, pg2], :formula)
			return Markdown.MD(Markdown.LaTeX(string(c1,raw"\cdot ",c2)))
		elseif all((tp1, tp2) .== Markdown.Paragraph)
			c1, c2 = getproperty.([pg1, pg2], :content) .|> first
			return Markdown.MD(Markdown.Paragraph(string(c1," ",c2)))
		else
			return Markdown.MD(Markdown.Paragraph("..."))
		end
	end
end

# ╔═╡ 1ff3a74b-1c54-4d47-b2fb-267130e4a773
function Base.:*(scalar::Real, uc::UC)::UC
	beschrijving = Markdown.MD(Markdown.LaTeX("$scalar"))  * uc.beschrijving
	waarde = scalar * uc.waarde
	return UC(beschrijving, waarde, uc.limiet)
end

# ╔═╡ 74796fc6-0b2c-4dc0-8af8-f3549986cd52
function Base.:*(c::Constant, uc::UC)::UC
	beschrijving = c.beschrijving  * uc.beschrijving
	waarde = c.waarde * uc.waarde
	return UC(beschrijving, waarde, uc.limiet)
end

# ╔═╡ 87057f63-1d4b-427a-bd1c-236568e7b3a2
L_cr = 2 * geom[:L] # m - Kniklengte, kolom onderaan vast, bovenaan vrij

# ╔═╡ 83f62f93-d0a0-4e94-841c-458ce2c1cd65
L_cr

# ╔═╡ 2d88f595-d4ae-427f-ac24-5fcef37dafb6
function Base.:+(uc1::UC, uc2::UC)::UC
	c1, c2 = getproperty.([uc1, uc2], :beschrijving)
	w1, w2 = getproperty.([uc1, uc2], :waarde)
	l1, l2 = getproperty.([uc1, uc2], :limiet)
	return UC(c1 + c2, w1 * l2 + w2 * l1, l1 * l2)
end

# ╔═╡ ab4ff3ac-6045-48b0-af4d-546a4af69ae7
αₘ = sqrt( 0.5 * (1 + 1 // (m = 1; m))) # Reductiefactor meerdere kolommen

# ╔═╡ cf0ad498-cbe7-404a-a265-6464460c6e5e
function Base.:/(scalar::Real, uc::UC)::UC
	beschrijving = Markdown.MD(Markdown.LaTeX(raw"\dfrac{1}{$scalar}"))  * uc.beschrijving
	limiet = scalar * uc.limiet
	return UC(beschrijving, uc.waarde, limiet)
end

# ╔═╡ 1565b3a9-bd3e-4cc6-9c3a-6cd9ff66c8bd
function Base.:/(c::Constant, uc::UC)::UC
	beschrijving = c.beschrijving  * uc.beschrijving
	limiet = c.waarde * uc.limiet
	return UC(beschrijving, uc.waarde, limiet)
end

# ╔═╡ bf5de147-27f7-4b05-8038-b7d3fe545466
G = E / (2 * (1 + ν)) # MPa

# ╔═╡ c6c90732-fe79-4e65-b456-9bd8ad95cb1b
z_max = +(eig.b / 1000) / 2 # m - Halve hoogte, van neutrale lijn tot uiterste vezel

# ╔═╡ 24374102-fcc8-42e6-b486-a8ba1ba71106
z_min = -(eig.b / 1000) / 2 # m - Halve hoogte, van neutrale lijn tot uiterste vezel

# ╔═╡ 6bc279ad-c26b-46e8-a738-32c5b43e6f96
αₕ = max(min(2 / sqrt(geom[:L]), 1), 2//3)  # Reductiefactor voor de hoogte h

# ╔═╡ 23304671-76f0-4d3f-957d-0f2ebbefe54e
ϕ = ϕ₀ * αₕ * αₘ |> rationalize 

# ╔═╡ 2cfe82e5-fac6-49f6-b3b7-cdbf9549113d
rvw_compleet = begin
	rvw_compleet = copy(rvw)
	rvw_compleet[!, :phi] 	.= ϕ
	rvw_compleet[!, :e_0] 	.= e₀
	rvw_compleet[!, :I]		.= eig.I * 10^-6 # m⁴
	rvw_compleet[!, :A]		.= eig.A * 10^-6 # m²
	rvw_compleet[!, :EI]	.= eig.I * E * 10^-3 # kNm²
	rvw_compleet
end

# ╔═╡ 77a710cf-318a-4fdf-b642-f1ec3ddd0e7f
function classificatie(σ; f_y=235)
	# Berekening α
	σ_pos, σ_neg = σ(z_max), σ(z_min)
	sigma = LinearInterpolation(
		sort([σ_pos, σ_neg]), [1, 0], extrapolation_bc=Line())
	α = max(min(sigma(0), 1), 0) # Bepaal α, de locatie waar de spanning = 0
	z_e = 1 - (σ_neg + 2 * σ_pos) / (σ_neg + σ_pos) * eig.b / 3 # zwaartepunt
	# Bepalen classificatie
	c = eig.b - 2 * (eig.t + eig.ri)
	ε = sqrt(235 / f_y)
	ψ = 1 - 1 / α
	bounds = 
		α > 0.5 ? 
		[ # α > 0.5
			0.0, 
			396 * ε / (13 * α - 1), 	# Max waarde klasse 1 - plastisch
			456 * ε / (13 * α - 1), 	# Max waarde klasse 2 - plastisch
			42 * ε / ( 0.67 + 0.33 * ψ) # Max waarde klasse 3 - elastisch
		] : 
		[
			0.0, 
			36 * ε / α,					# Max waarde klasse 1 - plastisch
			41.5 * ε / α,				# Max waarde klasse 2 - plastisch
			62 * ε * (1 - ψ) * sqrt(-ψ)	# Max waarde klasse 3 - elastisch
		]
	# Interpoleer waardes
	itp = LinearInterpolation(bounds, 1:4, extrapolation_bc=Line()) 
	return itp(c/eig.t)
end

# ╔═╡ 407a9aa2-3ac7-4f35-8b55-76a4ab1dcb62
N_cRd = eig.A * f_yk / γ_M0 / 1000 # kN

# ╔═╡ 338e1993-92cc-4a22-bed5-c2a027a4a46e
a_w = min((eig.A - 2 * eig.b * eig.t) / eig.A, 0.5) # Gewalst buisprofiel

# ╔═╡ 2e69fe82-5a8b-406b-95f9-eb7c82418733
a_f = min((eig.A - 2 * eig.b * eig.t) / eig.A, 0.5) # Gewalst buisprofiel h=b

# ╔═╡ 1a356a52-086f-46c6-a828-ac75d1b912c6
V_plRd = eig.Av * f_yk / γ_M0 / 1000 # kN

# ╔═╡ 23e3d7a4-6896-4249-84d9-5d9da80019f3
N_cr = π ^ 2 * ((try eig.Iz catch; eig.I end) * E * 10^-3) / L_cr ^2 # kN - Eulerknik

# ╔═╡ 745fb05d-67b2-499f-922d-54a325dcd648
λ_ = sqrt( eig.A * f_yk / N_cr / 1000 ) # rel. slankheid - klasse 1, 2 en 3 doorsneden

# ╔═╡ da7237ae-be7e-49ed-a281-c4fbdeb9dcd1
ϕ_ = 0.5 * (1 + α_ * (λ_ - 0.2) + λ_ ^ 2)

# ╔═╡ c9472a00-2a95-4a1c-9f2d-db539036002d
χ_ = min(1 / (ϕ_ + sqrt(ϕ_ ^ 2 - λ_ ^2)), 1) # reductiefactor knikvorm

# ╔═╡ 63acc98a-a2f9-441f-8b45-bfda5ebeec6c
N_bRd = χ_ * eig.A * f_yk / γ_M1 / 1000 # kN

# ╔═╡ 465ba3c5-4346-4d8e-8f0d-760096e5f628
λ_max = try max(λ_y, λ_z) catch; λ_ end

# ╔═╡ 9e22f1c7-451b-4d72-a844-c2be4da481d5
N_crz = N_cr

# ╔═╡ aea467d4-6f7c-46fa-a8c2-d26dbf063892
#M_cr = eig.Wpl * f_yk / 1000 # kNm - Kritisch moment; SHS niet kip gevoelig
M_cr = C_1 * (π ^ 2 * ((try eig.Iz catch; eig.I end) * E * 10^-3)) / (k_z * L_steun)^2 * ( sqrt((k_z / k_ω)^2 * (try eig.Iw * 10^3 catch; 0 end) / (try eig.Iz catch; eig.I end) + (k_z * L_steun) ^2 * G * eig.IT / (π^2 * E * (try eig.Iz catch; eig.I end) * 10^3) + (C_2 * z_g)^2) - C_2 * z_g)

# ╔═╡ b83c760f-4caf-4fd2-860b-837a10c2c3ff
λ_LT = sqrt( (eig.Wpl * f_yk) / M_cr / 1000 ) # relatieve slankheid

# ╔═╡ f5c651f5-de5f-4388-83b4-0b0b317b10a4
ϕ_LT = 0.5 * (1 + α_LT * (λ_LT - 0.2) + λ_LT ^ 2)

# ╔═╡ d98d815e-9fba-45e9-b0a2-6c89f233cc8d
χ_LT = min(1 / (ϕ_LT + sqrt( ϕ_LT ^ 2 - λ_LT ^ 2 )), 1.0) # Reductiefactor kip

# ╔═╡ ae2ff552-dd10-4ee0-bc2d-beaea1042dcc
M_bRd = χ_LT * eig.Wpl * 10^3 * f_yk / γ_M1 / 10^6 # kNm 

# ╔═╡ 5e620242-9ea3-4d4c-98ea-6712d4a10d60
M_cr0 = 1.03 * (π ^ 2 * ((try eig.Iz catch; eig.I end) * E * 10^-3)) / (k_z * L_steun)^2 * sqrt((k_z / k_ω)^2 * (try eig.Iw * 10^3 catch; 0 end) / (try eig.Iz catch; eig.I end) + (k_z * L_steun) ^2 * G * eig.IT / (π^2 * E * (try eig.Iz catch; eig.I end) * 10^3))

# ╔═╡ d51b0bf5-14c7-403b-a825-f0c883a6cacb
λ_LT0 = min(sqrt(eig.Wpl * f_yk / M_cr0 / 1000), 0.4) # §6.3.2.3 uit NBN EN 1993-1-1

# ╔═╡ 53295d8a-53a0-4586-94ea-91a459ed8039
r_0 = try sqrt((eig.Iy + eig.Iz) * 10^6 / eig.A) catch; sqrt((2 * eig.I) * 10^6 / eig.A) end

# ╔═╡ 87b3c60b-a677-4412-a239-4881a3a7bd61
N_crTF = 1 / (r_0 ^ 2) * (G * eig.IT * 10^3) / 1000 # kN

# ╔═╡ 7a14e675-594a-47b4-b9f4-b20ddc5ab515
w_y = min(eig.Wpl / eig.Wel, 1.5)

# ╔═╡ dd1f1b74-9bfa-47f7-a1f5-f1a56c03f787
a_LT = 1 - eig.IT  / ((try eig.Iy catch; eig.I end) * 1000)

# ╔═╡ efcf9a17-4b36-4c0d-88c4-e597b175e0eb
function Base.show(io::IO, mime::MIME"text/html", uc::UC)
	afronden = t -> (d -> round(d, digits=t))
	subs = Dict(
		"beschrijving" => uc.beschrijving.content[1].formula, 
		"waarde" => uc.waarde |> afronden(1),
		"limiet" => uc.limiet |> afronden(1),
		"uc" => (uc.waarde / uc.limiet) |> afronden(2)
	)
	format = raw"$\text{UC} = beschrijving = \dfrac{waarde}{limiet} = uc\rightarrow$"
	
	Base.write(io, """
		<div style="display: flex; align-items: center; justify-content: center;">				<div>
	""")
	show(io, mime, Markdown.parse(
			replace(format, r"beschrijving|waarde|limiet|uc" => s -> subs[s]))
	)
	Base.write(io, """
			</div>
			<div style="flex: 1; padding-left: 2px;">
	""")
	show(io, mime, Check(subs["uc"] <= 1))
	Base.write(io, """
			</div>
		</div>
	""")
end

# ╔═╡ 1d483436-9f48-41f7-b5b3-c49fb81a6824
md"""
Opsplitsing in kolommen
"""

# ╔═╡ e8773634-2240-4870-aa5c-8460459178b8
struct TwoColumn{L, R}
	left::L
	right::R
end

# ╔═╡ af04ceeb-5a97-4eee-bbd7-0aa324dc8704
function Base.show(io::IO, mime::MIME"text/html", tc::TwoColumn)
	Base.write(io, """
		<div style="display: flex; align-items: center; justify-content: center;">
			<div style="flex: 50%; overflow-x: scroll;">
	""")
	show(io, mime, tc.left)
	Base.write(io, """
			</div>
			<div style="flex: 50%;">
	""")
	show(io, mime, tc.right)
	Base.write(io, """
			</div>
		</div>
	""")
end

# ╔═╡ 1f9226f8-3878-4eb4-bb46-a3b6e4eedbfa
md"""
Maak een html `collapse` element
"""

# ╔═╡ e52b7ba4-6635-4df0-9b3e-8277cb3f4f5f
struct Foldable{C}
    title::String
    content::C
end

# ╔═╡ cd9b8bbf-f0cf-41d7-84e3-aa68052242a7
Foldable(
	"Table 6.2 in NBN EN 1993-1-1 §6.3.3", 
	md""" 
	 $(load("assets/img/NBN EN 1993-1-1 tab 6.2.jpg"))
	"""
)

# ╔═╡ d11df71d-7383-498c-9e69-22af54e9d809
Foldable(
	"Tabel E.1 volgens NBN EN 1993-1-1 ANB - Belasting door eindmomenten",
	md"""$(load("./assets/img/NBN EN 1993-1-1 ANB tab E.1.png"))"""
)

# ╔═╡ 055cb041-c79a-42a5-a6b6-801dd7135841
Foldable(
	"Tabel E.2 volgens NBN EN 1993-1-1 ANB - Belasting in dwarsrichting",
	md"""$(load("./assets/img/NBN EN 1993-1-1 ANB tab E.2.png"))"""
)

# ╔═╡ 4fc9d31c-83d7-463f-b64d-3c232ba71e9a
Foldable(
	"Figuur E.3 volgens NBN EN 1993-1-1 ANB - μ > 0",
	md"""$(load("./assets/img/NBN EN 1993-1-1 ANB fig E.3.png"))"""
)

# ╔═╡ 4329aa2d-f932-43e3-a6e5-c6c0bf09a0c9
Foldable(
	"Figuur E.5 volgens NBN EN 1993-1-1 ANB - μ > 0",
	md"""$(load("./assets/img/NBN EN 1993-1-1 ANB fig E.5.png"))"""
)

# ╔═╡ c68d5652-0220-47d5-b92d-06b1f8c25e2e
Foldable(
	"Tabel D.5 volgens NBN EN 1993-1-1 ANB",
	md"""$(load("./assets/img/NBN EN 1993-1-1 ANB tab D.1.png"))"""
)

# ╔═╡ 26f2f31b-7d6c-4422-ac9f-5f8d84c47b86
Foldable(
	"Afdruk NBN B 03-003 Tabel 3",
	md"""$(load("./assets/img/NBN B 03-003 tab 3.png"))"""
)

# ╔═╡ 512507a3-9238-441f-a5e4-b528e98ae49e
function Base.show(io::IO, mime::MIME"text/html", fld::Foldable)
	Base.write(io, """
		<details>
			<summary>
				$(fld.title)
			</summary>
			<p>
	""")
	show(io, mime, fld.content)
	Base.write(io, """
			</p>
		</summary>
	""")
end

# ╔═╡ 5f7b25aa-2fd6-44c6-95a2-94232a444061
md"""
Zet een NamedTuple om naar een Dict waarbij de *keys* geevalueerd zijn als *variables*
"""

# ╔═╡ 02284a59-bbc5-404a-b63c-6b058e4a1ac2
ToDict(r::NamedTuple) = Dict(keys(r) .|> eval .=> values(r))

# ╔═╡ 1b159512-beba-4227-9da1-c8bf34ce8de3
rnd(n) = round(n; digits=2)

# ╔═╡ 31935523-75d7-4f62-b27a-fc37edd2eec4
md"""
## Belastingsschema's
De belastingsschema's worden in het algemeen uitgewerkt en het **superpositie beginstel** wordt gehanteerd om de verschillende belastingseffecten samen te stellen
"""

# ╔═╡ 45c714f3-327c-4319-834f-f94bce39aa80
figuur5_4

# ╔═╡ abe1fdf5-995e-4965-95f6-6d9ee3d22a96
md"""
### Schema 1. Ingeklemde kolom die bovenaan *vast* gehouden wordt - *Initiële vervorming*
Door de *initiële vervorming* en *intitiële vooruitbuiging* worden er krachten opgewekt in de kolom. **Schema 1** begroot de interne krachtswerking onder een **initiële vervorming**. De hoekverdraaiing $\phi$ wordt vervangen door een **equivalente horizontale puntkracht** $\phi F$ die aangrijpt bovenaan de ligger.
"""

# ╔═╡ fbcdc48e-b700-4efe-b375-2c561fd30fdf
F, L, M_L, phi, A, EI, I, z, t = symbols(raw"F L M_L \phi A EI I z t", real=true)

# ╔═╡ aefe6d2f-5b87-4196-bdc8-1ab433fdd0f0
N = F

# ╔═╡ 76708068-72c9-4238-a138-89522b4b63b3
@drawsvg begin
	scaling = 40
	init = Point.([(0, 0), (0, -500)])
	final = Point.([(0, 0), ((scaling * ϕ) * 500, -500)])
	fontsize(20)
	Luxor.translate(0, 300)
	Luxor.label("phi F", :NW, final[2])
	Luxor.arrow(init[2] + (10, 0), final[2] - (10, 0))
	@layer ( # Originele vorm
		setdash("dash"),
		circle.(init, 4, :fill),
		poly(init, :stroke)
	)
	@layer ( # Nieuwe geometrie
		circle.(final, 4, :fill),
		move(final[1]),
		curve(final[1] - (0, 150), final[2] + (0, 150), final[2]),
		poly(first(pathtopoly()), :stroke)
	)
	@layer (
		Luxor.label("F", :E, init[2] - (0, 60)),
		Luxor.arrow(init[2] - (0, 60), init[2] - (0, 10))	
	)
end 800 800

# ╔═╡ befe0b07-ebde-4c43-b088-fdcfcdc237ce
R1H = phi * F

# ╔═╡ 12b86cfe-8b4e-4b9e-a12a-c8b1dbe17038
R1V = F

# ╔═╡ beca8144-d7fc-45cd-8119-6f413a9c3708
R1M = phi * F * L - M_L

# ╔═╡ 2d190e38-12d1-44f8-88d4-bf105282a5a0
md"""
#### Bepalen $N(t)$, $V(t)$ en $M(t)$
Bepalen van de interne krachtswerking
"""

# ╔═╡ 9197de8e-4b8b-426a-a1f7-5755de13046d
N1 = F # Onafhankelijk van t

# ╔═╡ e87466e2-4595-4b1f-ae53-871da933f208
V1 = - R1H # Onafhankelijk van t

# ╔═╡ 127bfc99-475c-44c8-a3b2-6e672d19e6f0
M1_ = - R1M + R1H * t # Onbekende M_L = moment die kolom recht houdt centraal

# ╔═╡ 7cdaf6ee-d669-4038-8d8d-391c336f5265
md"""
Spanning in de doorsnede
"""

# ╔═╡ be31b86e-309c-4f3d-8c50-e300df3e85b9
md"""
#### Bepalen $\alpha(t)$ en $v(t)$
Bepalen van de hoekverdraaiing $\alpha$ en de vervorming $v$
"""

# ╔═╡ 47091a29-a6f4-4fa3-86c7-73ee4f514e96
C1, D1 = symbols("C D", real=true)

# ╔═╡ 8dba5369-b5b0-4a0b-9c08-7db7d8754e9e
α1_ = integrate(M1_, t) + C1

# ╔═╡ 425bc939-5f25-46f0-b2dd-4bc923b1e3dd
v1_ = integrate(α1_, t) + D1

# ╔═╡ 308e442c-28da-4e21-b67a-13d7a52088a7
md"""
#### Toepassen kinematische randvoorwaarde
Opleggen van de hoekverdraaiing op $t=L$
"""

# ╔═╡ 35d4e904-1017-4c2d-b159-963034eb4e56
rvw1 = [
	v1_(t=>0),
	α1_(t=>0),
	α1_(t=>L)
]

# ╔═╡ 6b4f5532-c493-4afa-bcb2-769d9dc37200
opl1 = solve(rvw1, [C1, D1, M_L])

# ╔═╡ 47ee88d4-ff10-45a2-9905-27104410fd9a
M1 = M1_(opl1...)

# ╔═╡ 618014c3-ee47-465e-b63f-bbdb136c2217
σ1 = M1 * z / I + N1 / A

# ╔═╡ 78784064-422d-4888-940f-9b5c35e47aaa
α1 = α1_(opl1...) / EI

# ╔═╡ 7bc9eb16-a86c-469a-b881-f2eaadecbc79
v1 = v1_(opl1...) / EI

# ╔═╡ e666db94-c548-4cd7-8858-94277fc5c57d
md"""
### Schema 2. Ingeklemde kolom die bovenaan *vast* gehouden wordt - *Initiële vooruitbuiging*
Door de *initiële vervorming* en *intitiële vooruitbuiging* worden er krachten opgewekt in de kolom. **Schema 2** begroot de interne krachtswerking onder een **initiële vooruitbuiging**. De hoekverdraaiing $\phi$ wordt vervangen door een **equivalente horizontale lijnbelasting** $p$ met een grootte $8 F e_0 / L^2$ die aangrijpt over de gehele kolom. Onderaan en bovenaan worden compenserende krachten voorzien.
"""

# ╔═╡ de06b955-cb23-410b-a1c8-07fb7271488b
e_0 = symbols("e_0", real=true)

# ╔═╡ 86abd745-f01b-4b2b-99a0-71eeb992f8a1
R2H = 8 * F * e_0 / L^2 * L - 4 * F * e_0 / L # Onafhankelijk van t

# ╔═╡ e6d935a0-bf22-4394-a8c1-e782a9d22d0d
R2V = F # Onafhankelijk van t

# ╔═╡ 3c5011f6-9f59-47b6-a0b5-2c3946f06d53
R2M = 8 * F * e_0 / L^2 * L / 2 - M_L  # Afhankelijk van t

# ╔═╡ 6464d3bc-940e-49e1-99f5-c8073658658b
md"""
#### Bepalen $N(t)$, $V(t)$ en $M(t)$
Bepalen van de interne krachtswerking
"""

# ╔═╡ b5c615b0-babb-4a9f-8da6-993c09c484de
N2 = F # Onafhankelijk van t

# ╔═╡ 7c3df4d2-ef0d-4e32-822d-7d1c1b6cc650
V2 = - R2H + 8 * F * e_0 / L^2 * t # Afhankelijk van t

# ╔═╡ 6953ea5f-bbd1-4453-896e-ea825259a71a
V = V1 + V2

# ╔═╡ 51e153cd-77a5-4f59-91d7-d52a0e5f1555
M2_ = - R2M + R2H * t - 8 * F * e_0 / L^2 * t * t/2 # Afhankelijk van t

# ╔═╡ 6657e0c5-84e7-4721-951e-012df437c224
md"""
Spanning in de doorsnede
"""

# ╔═╡ d581d33f-5702-49d2-bac1-367bbb68fd78
md"""
#### Bepalen $\alpha(t)$ en $v(t)$
Bepalen van de hoekverdraaiing $\alpha$ en de vervorming $v$
"""

# ╔═╡ 45890c99-6860-4535-a50b-a0ec7a97ed7a
C2, D2 = symbols("C D", real=true)

# ╔═╡ 6e4d3a43-2531-4a04-a906-8670a2f2d768
α2_ = integrate(M2_, t) + C2

# ╔═╡ 7b75208f-e8e6-4653-9f22-a58148a20962
v2_ = integrate(α2_, t) + D2

# ╔═╡ 0be8effe-aa43-41ce-b5d0-36b2695a0bf8
md"""
#### Toepassen kinematische randvoorwaarde
Opleggen van de hoekverdraaiing op $t=L$
"""

# ╔═╡ d706f10b-ca96-487c-bc51-328ad4f1b6d7
rvw2 = [
	v2_(t => 0),
	α2_(t => 0),	# Geef hoekverdraaiing op t = 0
	α2_(t => L)		# Geef hoekverdraaiing op t = 0
]

# ╔═╡ 20273e50-d109-4576-b569-1bb8f5c401a2
opl2 = solve(rvw2, [C2, D2, M_L])

# ╔═╡ 654e8c85-205b-4e02-973a-096cd6874fcd
M2 = M2_(opl2...)

# ╔═╡ 9c703711-b54f-422d-a32e-80ab672996b8
M = M1 + M2

# ╔═╡ c6c80f4a-ac86-4795-b155-74dceb127084
σ = M * z / I + N / A

# ╔═╡ 04000cb7-943e-46d6-83f6-076790673932
σ2 = M2 * z / I + N2 / A

# ╔═╡ 814f040d-40f2-408a-b95a-774d6c2a54e2
α2 = α2_(opl2...) / EI

# ╔═╡ decd09d9-4960-4802-b53c-fcff982b0bf7
α = α1 + α2

# ╔═╡ 5b833881-d5b2-414e-87f0-ef6d48f416fc
v2 = α2_(opl2...) / EI

# ╔═╡ fdf02502-9c6b-4a27-a6af-271f2fdb58f1
v = v1 + v2

# ╔═╡ ba4505b4-c35b-4a25-a59e-88738d0aee05
opl = select(
	rvw_compleet,
	:check,
	AsTable(
		DataFrames.Not(:check)
	) => ByRow(
		r -> [N, V, M, α, v, σ] .|> 
		f -> lambdify(f(Dict(keys(r) .|> eval .=> values(r))...))
	) => [:N, :V, :M, :α, :v, :σ]
)

# ╔═╡ a012e4d2-d7db-44f0-95ff-800512b66fe0
@drawsvg begin
	schaal = 5
	fontsize(20)
	pnts = Point.([(0, 150),(0, -150)])
	σ_pos = first(opl.σ[opl.check .== Symbol(grenstoestand)])(tval, z_max) / 1000
	σ_neg = first(opl.σ[opl.check .== Symbol(grenstoestand)])(tval, z_min) / 1000
	pnt_pos = Point(schaal * σ_pos, -150)
	pnt_neg = Point(schaal * σ_neg, 150)
	s = poly([pnts..., pnt_pos, pnt_neg])
	pos, neg = polysplit(s, pnts...)
	lbl1, lbl2 = σ_pos < σ_neg ? ("σ_max", "σ_min") : ("σ_min", "σ_max") 
	@layer (
		sethue("red"),
		setopacity(0.5),
		poly(neg, :fill)
	)
	@layer (
		sethue("green"),
		setopacity(0.5),
		poly(pos, :fill)
	)
	@layer (
		sethue("black"),
		Luxor.arrow(pnts[1], pnt_neg),
		Luxor.label("$lbl1 = $(σ_pos |> rnd) MPa", :NE, pnt_pos),
		Luxor.arrow(pnts[2], pnt_pos),
		Luxor.label("$lbl2 = $(σ_neg |> rnd) MPa", :SE, pnt_neg)
	)
	@layer (
		Luxor.scale(1, 1.2),
		line(pnts..., :stroke)
	)
	Luxor.label("σ", :SE, pnts[1] + (0, 10), offset=15)
end 800 400

# ╔═╡ 0ec33b07-e4cb-470f-af63-86c2ad624f44
klasse = select(
	opl,
	:check,
	:σ => ByRow(σ -> 
		[classificatie(z -> σ(t, z)) for t in 0:0.05:geom[:L]] |> maximum
	) => :klasse
)

# ╔═╡ b976f9da-bfca-4d50-aa73-04f6eb1da4b7
md"""
De kolom **$(kolom[:beschrijving])** van het type **$(kolom[:naam])** in staalkwaliteit *$(kolom[:kwaliteit])* is van **klasse $(join(klasse.klasse .|> (Int ∘ floor), " en "))** in respectievelijk **$(join(klasse.check, " en "))**. 
"""

# ╔═╡ 8626a190-bf29-454c-94f2-09924de6429d
UGT = opl[opl.check .== :UGT, [:N, :V, :M, :v]] |> first

# ╔═╡ fee38bf5-df08-4f53-b8e3-b340ddb105b1
N_Ed = UGT.N() # kN

# ╔═╡ 9d370e4a-5ef2-44b1-86ea-89a8ce972eaa
UC_N = UC(md"$\dfrac{N_{Ed}}{N_{c,Rd}}$", N_Ed, N_cRd)

# ╔═╡ c829e349-2092-4bda-b448-6d3970a8d1af
TwoColumn(
	md"Axiale druk",
	UC_N
)

# ╔═╡ 0c044b93-5cd4-4ef9-a8e4-df729d7b8f87
n = N_Ed / N_cRd

# ╔═╡ 7c4f44c5-3060-4be4-9f46-16a20075e9d5
UC_Nstab = UC(md"$\dfrac{N_{Ed}}{N_{b,Rd}}$", N_Ed, N_bRd)

# ╔═╡ d5f61556-2204-4d3d-9981-9cbc60d601dd
TwoColumn(
	md"Knikstabiliteit (*Axiale druk*)",
	UC_Nstab
)

# ╔═╡ 73d41021-f9d3-4fa6-9b4f-9822ebf6e7a9
torsie_gevoelig = begin
	if eig.IT > eig.I * 1000
		false # Niet gevoelig voor vervorming door torsie
	else
		if λ_LT0 <= 0.2 * sqrt(C_1) * ((1 - N_Ed / N_crz) * (1 - N_Ed / N_crTF))^(1/4) 
			false # Niet gevoelig voor vervorming door torsie
		else
			true # Gevoelig voor vervorming door torsie
		end
	end
end

# ╔═╡ 39fb7d5c-529f-4e25-95cd-46394b84cb8c
μ_y = (1 - N_Ed / N_cr ) / (1 - χ_ * N_Ed / N_cr )

# ╔═╡ ff42c12d-3a2d-4e62-9481-1415f7a88647
n_pl = N_Ed / N_cRd / γ_M1

# ╔═╡ 81060926-426e-4155-9c27-e833902d29bb
M_Ed = abs(UGT.M(t_)) # kNm

# ╔═╡ 1ce7661e-1e86-4b0e-82a2-4fa7041d43d4
UC_Mstab = UC(md"$\dfrac{M_{Ed}}{M_{b,Rd}}$", M_Ed, M_bRd)

# ╔═╡ ab2f3ce2-9169-4306-9779-bae0714f0783
TwoColumn(
	md"Kipstabiliteit (*Buigend moment*)",
	UC_Mstab
)

# ╔═╡ c0270e0b-0f65-43b5-b2d0-e7a5483fa699
ε_y = M_Ed / N_Ed * eig.A / eig.Wel # Voor klasse 1, 2 of 3

# ╔═╡ 5456715c-bf21-40c9-b955-d300988fa569
V_Ed = abs(UGT.V(t_)) # kN

# ╔═╡ b2e9dbbf-9bee-4907-895c-aa9f886aba46
UC_V = UC(md"$\dfrac{V_{Ed}}{V_{c,Rd}}$", V_Ed, V_plRd)

# ╔═╡ 29369fad-e93e-48e0-b102-00672944936f
TwoColumn(
	md"Dwarskracht",
	UC_V
)

# ╔═╡ 85e2a31f-eccf-444a-8d93-15b30011676b
TwoColumn(
	md"Wringing",
	UC_V
)

# ╔═╡ 453c07c4-5392-470a-a573-fe062e0cd8ff
ρ = V_Ed / V_plRd < 0.5 ? 0 : ((2 * V_Ed) / V_plRd - 1)^2

# ╔═╡ 51f51bda-c22a-48c6-9d4b-555a24cf8475
M_cRd = eig.Wpl * 10^3 * (1 - ρ) * f_yk / γ_M0 / 10^6 # kNm

# ╔═╡ cfd18de2-082d-414d-891e-131f2d0fe9d2
M_NyRd = min(M_cRd * (1 - n) / (1 - 0.5 * a_w), M_cRd) # kNm - y-richting

# ╔═╡ c8a9b302-34ff-4a1e-9dc3-dd98485c1bd2
M_NzRd = min(M_cRd * (1 - n) / (1 - 0.5 * a_f), M_cRd) # kNm - z-richting

# ╔═╡ f7b3e85f-f637-408a-a271-a314e6865960
M_NRd = min(M_NyRd, M_NzRd) # Weerstand in de zwakke richting

# ╔═╡ f7b2f221-e492-4931-a5c3-65b5b31e51f3
UC_M = UC(md"$\dfrac{M_{Ed}}{M_{N,Rd}}$", M_Ed, M_NRd)

# ╔═╡ f1ca61bb-7667-479f-85b1-3d40e43ab437
TwoColumn(
	md"Buigend moment",
	UC_M
)

# ╔═╡ eeaba5bd-917d-45a6-8f3e-e3a4750e7d1d
UC_T = UC_N + UC_M + UC_V

# ╔═╡ afbafbc3-7112-4b2e-afed-7f71756f2061
begin
	UGT_M = UGT.M.(0:0.05:geom[:L])
	UGT_Mmax, UGT_M1, UGT_M2 = maximum(UGT_M), UGT_M[1], UGT_M[end]
	# Ψ is de verhouding tussen de eindmomenten, M is het max eindmoment
	Ψ = abs(UGT_M1) > abs(UGT_M2) ? UGT_M2 / UGT_M1 : UGT_M1 / UGT_M2
	plot(0:0.05:geom[:L], UGT_M, title="Buigend moment [kNm]", legend=false)
end

# ╔═╡ 6305983e-e603-448a-9777-5c0f52333d48
md"""
De verhouding tussen de eindmomenten $\psi$ is gelijk aan $(round(Ψ, digits=3)).

Lees de waardes van $C_1$, $C_2$ en $C_3$ af op onderstaande grafieken indien afkomstig uit zuiver **eindmomenten** of **krachten** (lijn-/puntbelasting) in de dwarsrichting.  
"""

# ╔═╡ 121ee9d6-912a-4860-a0e3-a403ee21bb23
μ = (UGT_M[div(end,2)] - (UGT_M1 + UGT_M2) / 2) / maximum(abs.([UGT_M1, UGT_M2]))

# ╔═╡ e20f3246-17d9-48e3-b812-31c43ea00ae6
md"""
!!! danger "Herevalueer parameters"
	Bij een wijziging van de belastingen dienen de parameters $C_1$ en $C_2$ opnieuw geëvalueerd worden
Bepaal de coëfficiënten voor $\mu$ = $(round(μ, digits=3)) en $$\psi$$ = $(round(Ψ, digits=3))
"""

# ╔═╡ ad1824f7-a52d-4eae-a6fc-c7c04ccb00b0
C_my0 = 1 + ( π ^ 2 * E * (try eig.Iy catch; eig.I end) * 10^(-3) * maximum(UGT.v.(0:0.05:geom[:L])) / (geom[:L]^2 * UGT_Mmax) - 1 ) * N_Ed / N_cr

# ╔═╡ 4df4ef08-ba83-48f0-b410-1bff7ed471ad
C_yy0 = max(1 + (w_y - 1) * ((2 - (1.6 / w_y * C_my0 ^ 2) * (λ_max + λ_max ^ 2)) * n_pl), eig.Wel / eig.Wpl)

# ╔═╡ d60661ba-1c1b-4daf-8ae6-df1ebb666f35
k_yy_a = Constant(
	md"$\dfrac{\mu_y\ C_{my}\ \chi_{LT}}{\left(1-\dfrac{N_{Ed}}{N_{cr,y}}\right)C_{yy}}$",
	(μ_y * C_my0 * χ_LT) / ((1 - N_Ed / N_cr) * C_yy0)
) 

# ╔═╡ 79ff10e9-0573-44c4-8141-560e84e5978c
C_my = C_my0 + (1 - C_my0) * (sqrt(ε_y) * a_LT) / (1 + sqrt(ε_y) * a_LT)

# ╔═╡ dbdb09f8-80ce-48c0-8c06-57e0d70bf0fa
C_yy = max(1 + (w_y - 1) * ((2 - (1.6 / w_y * C_my ^ 2) * (λ_max + λ_max ^ 2)) * n_pl - b_LT), eig.Wel / eig.Wpl)

# ╔═╡ cd088296-e6e4-445e-8600-5ebcb5ec6b88
C_mLT = C_my ^ 2 * a_LT / sqrt((1 - N_Ed / N_cr) * (1 - N_Ed / N_crTF))

# ╔═╡ fb473e24-e6ee-4835-871d-e33210829d5e
k_yy_b = Constant(
	md"$\dfrac{\mu_y\ C_{mLT}\ C_{my}}{\left(1-\dfrac{N_{Ed}}{N_{cr,y}}\right)C_{yy}}$",
	(μ_y * C_mLT * C_my) / ((1 - N_Ed / N_cr) * C_yy)
) 

# ╔═╡ f38ffad8-65ca-41ef-afc2-ae292e2a71ce
UC_MNstab = torsie_gevoelig ? UC_Nstab + k_yy_b * UC_Mstab : UC_Nstab + k_yy_a * UC_Mstab 

# ╔═╡ 9f609a14-5cc4-475c-bad9-c817d528e9dd
TwoColumn(
	md"Gecombineerd effect",
	UC_MNstab
)

# ╔═╡ 4520f2ba-89a1-4416-841e-e39d11b74d85
GGT_F = opl[opl.check .== :GGT,:] |> first

# ╔═╡ 66ac48f0-6da8-4e55-884b-7ec0f17b7f51
plot(0:0.05:geom[:L], GGT_F.v, title="Horizontale Vervorming - GGT Frequent [mm]", legend=false)

# ╔═╡ 596b1a51-d779-4369-bf1c-c8737ce1ed11
GGT_F_vmax = maximum(extrema(GGT_F.v.(0:0.05:geom[:L])) .|> abs)

# ╔═╡ 4db0305a-bae5-4880-9305-011c61493499
UC_v = UC(md"$\dfrac{v_{max}}{h_{1}\ /\ 250}$", GGT_F_vmax * 1000, geom[:L]/250 * 1000)

# ╔═╡ 762b9a97-61fc-4f92-9006-9a98b26a45bf
TwoColumn(
	md"Uitzicht (9)",
	UC_v
)

# ╔═╡ bddb2fa9-d572-428e-8c12-ef955309b293
GGT_K = opl[opl.check .== :GGT_K,:] |> first

# ╔═╡ bb9c8ee1-df0e-4945-98d1-9579b930f9a8
GGT_K_vmax = maximum(extrema(GGT_K.v.(0:0.05:geom[:L])) .|> abs)

# ╔═╡ f5a91bff-cfda-4ede-9a43-546152fb56d6
plot(0:0.05:geom[:L], GGT_K.v, title="Horizontale Vervorming - GGT Karakteristiek [mm]", legend=false)

# ╔═╡ Cell order:
# ╠═64702f65-43d1-4b00-bbed-d5a70d77fb8a
# ╟─bf7ab900-ec7d-11eb-1a03-b5c7103e6e4c
# ╟─5f090cf6-bf5d-4663-860c-d694b82ca64a
# ╟─96b36181-5dd7-4b7f-b36c-b41c297aee4b
# ╟─6fd93b12-b898-415c-93e1-5c3c6337bd9f
# ╟─a12b2f6b-0f6f-4891-8e49-e9c0456cb203
# ╟─c829e349-2092-4bda-b448-6d3970a8d1af
# ╟─f1ca61bb-7667-479f-85b1-3d40e43ab437
# ╟─29369fad-e93e-48e0-b102-00672944936f
# ╟─85e2a31f-eccf-444a-8d93-15b30011676b
# ╟─fc3409d7-2873-4410-8e9d-299c4dbfd4ab
# ╟─d5f61556-2204-4d3d-9981-9cbc60d601dd
# ╟─ab2f3ce2-9169-4306-9779-bae0714f0783
# ╟─9f609a14-5cc4-475c-bad9-c817d528e9dd
# ╟─99cfd8a5-362a-48a6-9c8f-aca67c63a616
# ╟─762b9a97-61fc-4f92-9006-9a98b26a45bf
# ╟─479ce586-0709-42a1-aa7d-2e7d8e4c5b7b
# ╠═2562daf7-66f5-4b9d-8b6e-9b50095d4dd3
# ╟─2f321431-5f92-453c-bfb2-ce3c6f7f81a2
# ╠═81d77b92-3499-451d-b485-b8378cdbf611
# ╟─6f2b93c1-df30-427a-a0f8-1a3cbc0890bb
# ╟─83113699-96e8-4cce-9101-37f016855b49
# ╟─1eeb0c6d-523c-423f-897a-fe9aff327c3a
# ╟─65052451-ac16-458e-911b-17226c5355d7
# ╠═1e3f7495-7255-4319-8a0d-3c2a66305d06
# ╟─0d602b85-8c97-47f6-bdcd-3a5738b94371
# ╠═15c1009a-be15-4780-8054-d30271af920c
# ╠═bf5de147-27f7-4b05-8038-b7d3fe545466
# ╠═0de5f479-0eef-48bc-8146-757b4ff3b27d
# ╠═c6c90732-fe79-4e65-b456-9bd8ad95cb1b
# ╠═24374102-fcc8-42e6-b486-a8ba1ba71106
# ╟─5fbb513b-35fc-43cc-b81b-cb52dd572584
# ╟─6967230f-8e86-48d7-affb-8f537f50b053
# ╟─650a4e73-0ff4-4ab2-be22-70143654aa57
# ╟─1402febf-ba8c-475a-8f23-a916d8d9815b
# ╟─39feffd5-63b2-4f6d-8ffc-21e55ce0f31e
# ╟─0e483762-3725-418b-a67d-56c1815bc5ba
# ╟─c3a0091f-31ee-46e2-bf21-94da754b6cac
# ╟─92615040-32a4-400d-818f-5deaef931d66
# ╟─a6c1043b-70d7-4b42-a883-96e168f80045
# ╟─fe677e91-ab28-40e5-b270-163ac77a1dd1
# ╟─977c58d5-3bdb-4f34-baee-c5f3acc83155
# ╠═23304671-76f0-4d3f-957d-0f2ebbefe54e
# ╟─32c60448-66f4-4d55-8282-abd76c7672a8
# ╠═b5cb73da-c8e6-417f-94a8-0f0fa5ae8321
# ╠═6bc279ad-c26b-46e8-a738-32c5b43e6f96
# ╠═ab4ff3ac-6045-48b0-af4d-546a4af69ae7
# ╟─b7b47867-f469-46d4-a7e7-0da9f59c4b8c
# ╟─5fc42b0d-0363-4087-acfe-962f3304fccf
# ╠═3d0a7e42-8915-41b6-961c-ae45921b53e8
# ╟─db32e45a-ce7c-43b0-977c-c89b62db3b54
# ╠═aefe6d2f-5b87-4196-bdc8-1ab433fdd0f0
# ╠═6953ea5f-bbd1-4453-896e-ea825259a71a
# ╠═9c703711-b54f-422d-a32e-80ab672996b8
# ╠═decd09d9-4960-4802-b53c-fcff982b0bf7
# ╠═fdf02502-9c6b-4a27-a6af-271f2fdb58f1
# ╠═c6c80f4a-ac86-4795-b155-74dceb127084
# ╟─1c0069be-e284-46f3-8ebf-808029b0e8ce
# ╠═2cfe82e5-fac6-49f6-b3b7-cdbf9549113d
# ╟─ba4505b4-c35b-4a25-a59e-88738d0aee05
# ╟─79deccb1-5aab-4bfd-857f-55b17250527c
# ╟─49f763be-0741-4895-adcb-22efd0ad58e5
# ╟─a012e4d2-d7db-44f0-95ff-800512b66fe0
# ╟─565c0a79-02ab-4f09-838b-a8d5be5b328e
# ╟─da0eddc9-788d-4308-b458-54db04cd0fd2
# ╠═77a710cf-318a-4fdf-b642-f1ec3ddd0e7f
# ╟─0ec33b07-e4cb-470f-af63-86c2ad624f44
# ╟─b976f9da-bfca-4d50-aa73-04f6eb1da4b7
# ╠═a16a6888-87b7-4c30-b254-4901630af21b
# ╟─5a7c92bf-a811-4cb8-8a37-9f2c4c4b1ad2
# ╠═5ebe01be-f116-496e-8fd5-a687fc2dacd4
# ╟─d1163bac-8c98-4aa9-bb79-b2f09e46392f
# ╟─3097f9ac-fedd-49f6-853d-ef6b5eee2826
# ╠═8626a190-bf29-454c-94f2-09924de6429d
# ╟─ca3f41bd-9491-46c7-bd6b-b078d01509ec
# ╠═fee38bf5-df08-4f53-b8e3-b340ddb105b1
# ╠═407a9aa2-3ac7-4f35-8b55-76a4ab1dcb62
# ╠═9d370e4a-5ef2-44b1-86ea-89a8ce972eaa
# ╟─a511719f-e67c-4e7f-8c02-06a1c4d67a8f
# ╠═81060926-426e-4155-9c27-e833902d29bb
# ╠═51f51bda-c22a-48c6-9d4b-555a24cf8475
# ╠═f7b2f221-e492-4931-a5c3-65b5b31e51f3
# ╟─add548a9-0dd1-4041-9949-fc5a3181e973
# ╠═cfd18de2-082d-414d-891e-131f2d0fe9d2
# ╠═c8a9b302-34ff-4a1e-9dc3-dd98485c1bd2
# ╠═f7b3e85f-f637-408a-a271-a314e6865960
# ╠═338e1993-92cc-4a22-bed5-c2a027a4a46e
# ╠═2e69fe82-5a8b-406b-95f9-eb7c82418733
# ╠═0c044b93-5cd4-4ef9-a8e4-df729d7b8f87
# ╟─264294d2-a757-4ce3-90d5-05960151fe6c
# ╠═5456715c-bf21-40c9-b955-d300988fa569
# ╠═1a356a52-086f-46c6-a828-ac75d1b912c6
# ╠═b2e9dbbf-9bee-4907-895c-aa9f886aba46
# ╠═453c07c4-5392-470a-a573-fe062e0cd8ff
# ╟─5c064cef-b7c2-4fb6-9013-8afa0f11206c
# ╠═eeaba5bd-917d-45a6-8f3e-e3a4750e7d1d
# ╟─a5075f8a-6268-4a79-9d86-62db775d2376
# ╟─60388762-5cee-4ac4-ac92-31fb7fe795c4
# ╠═63acc98a-a2f9-441f-8b45-bfda5ebeec6c
# ╟─9a2bef32-f374-4c2f-93e7-9e1142101e2c
# ╠═c9472a00-2a95-4a1c-9f2d-db539036002d
# ╠═da7237ae-be7e-49ed-a281-c4fbdeb9dcd1
# ╠═745fb05d-67b2-499f-922d-54a325dcd648
# ╠═4fe78740-be25-404f-8d6c-606f08e82510
# ╠═23e3d7a4-6896-4249-84d9-5d9da80019f3
# ╠═87057f63-1d4b-427a-bd1c-236568e7b3a2
# ╟─e1b27c73-cd31-49c3-9495-b4ce3686a96a
# ╟─815bd927-24d0-4f02-97c0-d99d9b3ace01
# ╟─cd9b8bbf-f0cf-41d7-84e3-aa68052242a7
# ╟─7c4f44c5-3060-4be4-9f46-16a20075e9d5
# ╟─b8e307cb-784e-405a-a9a9-351f12ada6c6
# ╠═ae2ff552-dd10-4ee0-bc2d-beaea1042dcc
# ╟─3c273c59-cd0b-405b-835b-7ed1d910701d
# ╠═d98d815e-9fba-45e9-b0a2-6c89f233cc8d
# ╠═f5c651f5-de5f-4388-83b4-0b0b317b10a4
# ╟─bbf8fd14-3176-4966-8060-7d9a2602728d
# ╠═b83c760f-4caf-4fd2-860b-837a10c2c3ff
# ╠═949aa8ef-33f9-455d-9471-de202e2a1fc6
# ╟─9aa171b9-f90c-4951-903d-00862794d1f0
# ╟─6cb6f033-c5ef-4852-bb66-3b80c08501d1
# ╠═aea467d4-6f7c-46fa-a8c2-d26dbf063892
# ╠═b3128d17-e7a6-4cd1-b9a3-7c2e85e9c1ed
# ╠═daa7b994-81a8-4ddd-93b3-65298c9f917a
# ╠═6cb6bdee-5fac-42b6-a55c-35172ce8c8eb
# ╠═04316e68-424a-4ae3-8d09-f54a755693da
# ╟─a17412e3-6377-426e-ae0c-c32ce2714aef
# ╠═afbafbc3-7112-4b2e-afed-7f71756f2061
# ╠═4b404a8d-7e1f-4fa5-98b8-f86251b720b6
# ╟─6305983e-e603-448a-9777-5c0f52333d48
# ╠═914aa30b-7a6f-4ca7-a5d0-55dd57deb91e
# ╟─d11df71d-7383-498c-9e69-22af54e9d809
# ╟─055cb041-c79a-42a5-a6b6-801dd7135841
# ╟─1d397003-77d2-48eb-aa9a-f21c306a203e
# ╠═121ee9d6-912a-4860-a0e3-a403ee21bb23
# ╟─f1033e15-2736-40a9-8403-de14f9076c1a
# ╟─e20f3246-17d9-48e3-b812-31c43ea00ae6
# ╠═ebd5559c-ca01-436e-a6ac-c333349a376f
# ╟─4fc9d31c-83d7-463f-b64d-3c232ba71e9a
# ╠═a02a69c2-5250-476f-801b-f62443e42615
# ╟─4329aa2d-f932-43e3-a6e5-c6c0bf09a0c9
# ╟─e09a6e50-b887-489c-9118-a2817aa08513
# ╟─860434ef-648c-4456-aa8c-63fb473f8682
# ╟─1ce7661e-1e86-4b0e-82a2-4fa7041d43d4
# ╟─e5d3d66d-3975-46ca-80f8-7f02953ff56a
# ╟─a1575d01-f628-492d-9a10-2bd9ad306bb7
# ╟─baec8eb3-f117-47fb-b05d-92308298f1a3
# ╠═73d41021-f9d3-4fa6-9b4f-9822ebf6e7a9
# ╠═d51b0bf5-14c7-403b-a825-f0c883a6cacb
# ╠═5e620242-9ea3-4d4c-98ea-6712d4a10d60
# ╟─327c6862-7f36-49b8-89f0-ed7fcf36cc99
# ╠═87b3c60b-a677-4412-a239-4881a3a7bd61
# ╠═53295d8a-53a0-4586-94ea-91a459ed8039
# ╟─52172a41-72a2-4a8d-baed-b291d68adb3f
# ╠═83f62f93-d0a0-4e94-841c-458ce2c1cd65
# ╠═9e22f1c7-451b-4d72-a844-c2be4da481d5
# ╟─2850392f-fab1-40fd-8487-91216a8fdd76
# ╟─fba37538-ce55-48e4-979a-e3cf9a6be6cd
# ╟─b644b63e-352e-4f55-9d03-03d6cb96ec3d
# ╠═39fb7d5c-529f-4e25-95cd-46394b84cb8c
# ╟─2430fca4-d88f-4a3e-9129-19f163e7d83a
# ╟─c68d5652-0220-47d5-b92d-06b1f8c25e2e
# ╠═ad1824f7-a52d-4eae-a6fc-c7c04ccb00b0
# ╟─906c97c1-136b-4df9-929d-7db6c289cd5b
# ╠═4df4ef08-ba83-48f0-b410-1bff7ed471ad
# ╠═7a14e675-594a-47b4-b9f4-b20ddc5ab515
# ╠═465ba3c5-4346-4d8e-8f0d-760096e5f628
# ╠═ff42c12d-3a2d-4e62-9481-1415f7a88647
# ╟─d60661ba-1c1b-4daf-8ae6-df1ebb666f35
# ╟─83f412fa-7c1a-4484-9bbf-bc0287cbe5f7
# ╟─0265c5cf-f768-45c4-aad8-f399e23d3703
# ╠═79ff10e9-0573-44c4-8141-560e84e5978c
# ╠═c0270e0b-0f65-43b5-b2d0-e7a5483fa699
# ╠═dd1f1b74-9bfa-47f7-a1f5-f1a56c03f787
# ╟─63523b55-c791-42e5-b3b2-9d03b11e7e2c
# ╠═dbdb09f8-80ce-48c0-8c06-57e0d70bf0fa
# ╠═3944d762-8c63-4188-9aef-e26236474fca
# ╟─88259ae8-a88d-48f0-9660-96a4b00cde35
# ╠═cd088296-e6e4-445e-8600-5ebcb5ec6b88
# ╟─fb473e24-e6ee-4835-871d-e33210829d5e
# ╟─832e20b0-2106-4c09-8a1c-cbf4faa9ea52
# ╠═f38ffad8-65ca-41ef-afc2-ae292e2a71ce
# ╟─d59ea3e9-e374-4e80-aee6-3c4878745f0d
# ╟─d8003147-45a6-4b8f-960e-70bc80f8cb69
# ╠═4520f2ba-89a1-4416-841e-e39d11b74d85
# ╟─66ac48f0-6da8-4e55-884b-7ec0f17b7f51
# ╠═bb9c8ee1-df0e-4945-98d1-9579b930f9a8
# ╠═bddb2fa9-d572-428e-8c12-ef955309b293
# ╟─f5a91bff-cfda-4ede-9a43-546152fb56d6
# ╠═596b1a51-d779-4369-bf1c-c8737ce1ed11
# ╟─26f2f31b-7d6c-4422-ac9f-5f8d84c47b86
# ╟─4db0305a-bae5-4880-9305-011c61493499
# ╟─695ecf3c-6a51-458d-b63f-8f323df46a8a
# ╟─1e5bd62b-5327-4abb-b4c0-9df3c2a92be9
# ╟─3c07526e-31f8-4857-bd62-e6fc71d50c5b
# ╠═5da33fcf-33d3-492b-af3a-c07623e87f61
# ╟─7f3a6986-dfab-4e82-8eda-1a0bd72b47bd
# ╠═17faebbf-9fbd-4860-80b9-c5551bc34390
# ╟─43a30a97-42c3-446f-b57d-47af9b47565b
# ╠═d35dfa59-d3ba-4cd0-b229-2808e61e609c
# ╠═01cc6e48-7e78-4c9c-968a-457857f37b00
# ╟─47f629ad-75cd-4400-a07e-ddd22c4f94e8
# ╠═d3b4ab06-11e2-4fd3-b994-60c6aabf5308
# ╠═b4205158-167f-4521-a9ef-6b0d39cc9238
# ╠═efcf9a17-4b36-4c0d-88c4-e597b175e0eb
# ╠═6942d492-5d8b-4a0e-9824-e55318cd03c0
# ╠═fee57389-2d06-447a-ad08-9866b7f72e4b
# ╟─a835b337-5d25-47c2-a34c-b74beb4b62de
# ╠═2d88f595-d4ae-427f-ac24-5fcef37dafb6
# ╠═4186bf7c-dada-447e-8e1c-7c5a695111a6
# ╠═74a300ff-0972-42e5-996e-52c98a6999c2
# ╠═1ff3a74b-1c54-4d47-b2fb-267130e4a773
# ╠═cf0ad498-cbe7-404a-a265-6464460c6e5e
# ╠═74796fc6-0b2c-4dc0-8af8-f3549986cd52
# ╠═1565b3a9-bd3e-4cc6-9c3a-6cd9ff66c8bd
# ╟─1d483436-9f48-41f7-b5b3-c49fb81a6824
# ╠═e8773634-2240-4870-aa5c-8460459178b8
# ╠═af04ceeb-5a97-4eee-bbd7-0aa324dc8704
# ╟─1f9226f8-3878-4eb4-bb46-a3b6e4eedbfa
# ╠═e52b7ba4-6635-4df0-9b3e-8277cb3f4f5f
# ╠═512507a3-9238-441f-a5e4-b528e98ae49e
# ╟─5f7b25aa-2fd6-44c6-95a2-94232a444061
# ╠═02284a59-bbc5-404a-b63c-6b058e4a1ac2
# ╠═1b159512-beba-4227-9da1-c8bf34ce8de3
# ╟─31935523-75d7-4f62-b27a-fc37edd2eec4
# ╠═45c714f3-327c-4319-834f-f94bce39aa80
# ╟─abe1fdf5-995e-4965-95f6-6d9ee3d22a96
# ╠═fbcdc48e-b700-4efe-b375-2c561fd30fdf
# ╟─76708068-72c9-4238-a138-89522b4b63b3
# ╟─befe0b07-ebde-4c43-b088-fdcfcdc237ce
# ╟─12b86cfe-8b4e-4b9e-a12a-c8b1dbe17038
# ╟─beca8144-d7fc-45cd-8119-6f413a9c3708
# ╟─2d190e38-12d1-44f8-88d4-bf105282a5a0
# ╠═9197de8e-4b8b-426a-a1f7-5755de13046d
# ╠═e87466e2-4595-4b1f-ae53-871da933f208
# ╠═127bfc99-475c-44c8-a3b2-6e672d19e6f0
# ╟─47ee88d4-ff10-45a2-9905-27104410fd9a
# ╟─7cdaf6ee-d669-4038-8d8d-391c336f5265
# ╠═618014c3-ee47-465e-b63f-bbdb136c2217
# ╟─be31b86e-309c-4f3d-8c50-e300df3e85b9
# ╟─47091a29-a6f4-4fa3-86c7-73ee4f514e96
# ╠═8dba5369-b5b0-4a0b-9c08-7db7d8754e9e
# ╟─78784064-422d-4888-940f-9b5c35e47aaa
# ╠═425bc939-5f25-46f0-b2dd-4bc923b1e3dd
# ╟─7bc9eb16-a86c-469a-b881-f2eaadecbc79
# ╟─308e442c-28da-4e21-b67a-13d7a52088a7
# ╠═35d4e904-1017-4c2d-b159-963034eb4e56
# ╟─6b4f5532-c493-4afa-bcb2-769d9dc37200
# ╟─e666db94-c548-4cd7-8858-94277fc5c57d
# ╠═de06b955-cb23-410b-a1c8-07fb7271488b
# ╠═86abd745-f01b-4b2b-99a0-71eeb992f8a1
# ╠═e6d935a0-bf22-4394-a8c1-e782a9d22d0d
# ╟─3c5011f6-9f59-47b6-a0b5-2c3946f06d53
# ╟─6464d3bc-940e-49e1-99f5-c8073658658b
# ╠═b5c615b0-babb-4a9f-8da6-993c09c484de
# ╠═7c3df4d2-ef0d-4e32-822d-7d1c1b6cc650
# ╠═51e153cd-77a5-4f59-91d7-d52a0e5f1555
# ╠═654e8c85-205b-4e02-973a-096cd6874fcd
# ╟─6657e0c5-84e7-4721-951e-012df437c224
# ╠═04000cb7-943e-46d6-83f6-076790673932
# ╟─d581d33f-5702-49d2-bac1-367bbb68fd78
# ╟─45890c99-6860-4535-a50b-a0ec7a97ed7a
# ╠═6e4d3a43-2531-4a04-a906-8670a2f2d768
# ╠═814f040d-40f2-408a-b95a-774d6c2a54e2
# ╠═7b75208f-e8e6-4653-9f22-a58148a20962
# ╠═5b833881-d5b2-414e-87f0-ef6d48f416fc
# ╟─0be8effe-aa43-41ce-b5d0-36b2695a0bf8
# ╠═d706f10b-ca96-487c-bc51-328ad4f1b6d7
# ╠═20273e50-d109-4576-b569-1bb8f5c401a2
