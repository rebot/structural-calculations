### A Pluto.jl notebook ###
# v0.16.0

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

# ╔═╡ e8bc8487-8e7e-4e5f-a06e-193669f4cce9
using PlutoUI, ImageView, Images, Plots, SymPy, Luxor, SQLite, DataFrames, Underscores, Interpolations, PlutoTest

# ╔═╡ adad2d93-4973-4631-8255-f855d12a2848
using UUIDs

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

# ╔═╡ bf5de147-27f7-4b05-8038-b7d3fe545466
G = E / (2 * (1 + ν)) # MPa

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

# ╔═╡ 0e483762-3725-418b-a67d-56c1815bc5ba
rvw = begin
	for (k, v) in pairs(geom)
		maatgevend[!, k] .= v
	end
	copy(maatgevend)
end

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

# ╔═╡ 6bc279ad-c26b-46e8-a738-32c5b43e6f96
αₕ = max(min(2 / sqrt(geom[:L]), 1), 2//3)  # Reductiefactor voor de hoogte h

# ╔═╡ ab4ff3ac-6045-48b0-af4d-546a4af69ae7
αₘ = sqrt( 0.5 * (1 + 1 // (m = 1; m))) # Reductiefactor meerdere kolommen

# ╔═╡ 23304671-76f0-4d3f-957d-0f2ebbefe54e
ϕ = ϕ₀ * αₕ * αₘ |> rationalize 

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

# ╔═╡ 87057f63-1d4b-427a-bd1c-236568e7b3a2
L_cr = 2 * geom[:L] # m - Kniklengte, kolom onderaan vast, bovenaan vrij

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

# ╔═╡ 83f62f93-d0a0-4e94-841c-458ce2c1cd65
L_cr

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

# ╔═╡ c6c90732-fe79-4e65-b456-9bd8ad95cb1b
z_max = +(eig.b / 1000) / 2 # m - Halve hoogte, van neutrale lijn tot uiterste vezel

# ╔═╡ 24374102-fcc8-42e6-b486-a8ba1ba71106
z_min = -(eig.b / 1000) / 2 # m - Halve hoogte, van neutrale lijn tot uiterste vezel

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

# ╔═╡ a835b337-5d25-47c2-a34c-b74beb4b62de
md"""
Algemene functies om somaties van `Markdown.MD` types mogelijk te maken, alsook de sommatie van de *custom* `UC` *struct*
"""

# ╔═╡ 2d88f595-d4ae-427f-ac24-5fcef37dafb6
function Base.:+(uc1::UC, uc2::UC)::UC
	c1, c2 = getproperty.([uc1, uc2], :beschrijving)
	w1, w2 = getproperty.([uc1, uc2], :waarde)
	l1, l2 = getproperty.([uc1, uc2], :limiet)
	return UC(c1 + c2, w1 * l2 + w2 * l1, l1 * l2)
end

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

# ╔═╡ cf0ad498-cbe7-404a-a265-6464460c6e5e
function Base.:/(scalar::Real, uc::UC)::UC
	beschrijving = Markdown.MD(Markdown.LaTeX(raw"\dfrac{1}{$scalar}"))  * uc.beschrijving
	limiet = scalar * uc.limiet
	return UC(beschrijving, uc.waarde, limiet)
end

# ╔═╡ 74796fc6-0b2c-4dc0-8af8-f3549986cd52
function Base.:*(c::Constant, uc::UC)::UC
	beschrijving = c.beschrijving  * uc.beschrijving
	waarde = c.waarde * uc.waarde
	return UC(beschrijving, waarde, uc.limiet)
end

# ╔═╡ 1565b3a9-bd3e-4cc6-9c3a-6cd9ff66c8bd
function Base.:/(c::Constant, uc::UC)::UC
	beschrijving = c.beschrijving  * uc.beschrijving
	limiet = c.waarde * uc.limiet
	return UC(beschrijving, uc.waarde, limiet)
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

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
ImageView = "86fae568-95e7-573e-a6b2-d8a6b900c9ef"
Images = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
Interpolations = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
Luxor = "ae8d54c2-7ccd-5906-9d76-62fc9837b5bc"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoTest = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
SQLite = "0aa819cd-b072-5ff4-a722-6bc24af294d9"
SymPy = "24249f21-da20-56a4-8eb1-6a02cf4ae2e6"
UUIDs = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
Underscores = "d9a01c3f-67ce-4d8c-9b55-35f6e4050bb1"

[compat]
DataFrames = "~1.2.1"
ImageView = "~0.10.13"
Images = "~0.23.3"
Interpolations = "~0.13.3"
Luxor = "~2.14.0"
Plots = "~1.15.2"
PlutoTest = "~0.1.0"
PlutoUI = "~0.7.9"
SQLite = "~1.1.4"
SymPy = "~1.0.50"
Underscores = "~2.0.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ATK_jll]]
deps = ["Artifacts", "Glib_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "58c36d8a1beeb12d63921bcfaa674baf30a1140e"
uuid = "7b86fcea-f67b-53e1-809c-8f1719c154e8"
version = "2.36.1+0"

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
git-tree-sha1 = "655d9e28a75f88eea3fb81a12f62da9bade89fb5"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "3.1.19"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "a4d07a1c313392a77042855df46c5f534076fab9"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.0"

[[AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "d127d5e4d86c7680b20c35d40b503c74b9a39b5e"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.4"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BinaryProvider]]
deps = ["Libdl", "Logging", "SHA"]
git-tree-sha1 = "ecdec412a9abc8db54c0efc5548c64dfce072058"
uuid = "b99e7846-7c00-51b0-8f62-c81ae34c0232"
version = "0.5.10"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "d0b3f8b4ad16cb0a2988c6788646a5e6a17b6b1b"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.0.5"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f2202b55d816427cd385a9a4f3ffb226bee80f99"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+0"

[[CatIndices]]
deps = ["CustomUnitRanges", "OffsetArrays"]
git-tree-sha1 = "a0f80a09780eed9b1d106a1bf62041c2efc995bc"
uuid = "aafaddc9-749c-510e-ac4f-586e18779b91"
version = "0.2.2"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "f53ca8d41e4753c41cdafa6ec5f7ce914b34be54"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "0.10.13"

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
git-tree-sha1 = "344f143fa0ec67e47917848795ab19c6a455f32c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.32.0"

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
git-tree-sha1 = "a19645616f37a2c2c3077a44bc0d3e73e13441d7"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.2.1"

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
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

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
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[GR]]
deps = ["Base64", "DelimitedFiles", "HTTP", "JSON", "LinearAlgebra", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "cd0f34bd097d4d5eb6bbe01778cf8a7ed35f29d9"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.52.0"

[[GTK3_jll]]
deps = ["ATK_jll", "Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Libepoxy_jll", "Pango_jll", "Pkg", "Wayland_jll", "Xorg_libX11_jll", "Xorg_libXcomposite_jll", "Xorg_libXcursor_jll", "Xorg_libXdamage_jll", "Xorg_libXext_jll", "Xorg_libXfixes_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "Xorg_libXrender_jll", "at_spi2_atk_jll", "gdk_pixbuf_jll", "iso_codes_jll", "xkbcommon_jll"]
git-tree-sha1 = "f2922cb0105ba076b560e3922910f8e3749aa91a"
uuid = "77ec8976-b24b-556a-a1bf-49a033a670a6"
version = "3.24.30+0"

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
git-tree-sha1 = "74ef6288d071f58033d54fd6708d4bc23a8b8972"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+1"

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
git-tree-sha1 = "d679fc90e75984e7b8eb25702eff7cf4718a9c10"
uuid = "4c0ca9eb-093a-5379-98c5-f87ac0bbbf44"
version = "1.1.9"

[[GtkReactive]]
deps = ["Cairo", "Colors", "Dates", "FixedPointNumbers", "Graphics", "Gtk", "IntervalSets", "Reactive", "Reexport", "RoundingIntegers"]
git-tree-sha1 = "2a82c9204afbd8bfb39c0d6735bface4a3df9917"
uuid = "27996c0f-39cd-5cc1-a27a-05f136f946b6"
version = "1.0.5"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "MbedTLS", "Sockets"]
git-tree-sha1 = "c7ec02c4c6a039a98a15f955462cd7aea5df4508"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.8.19"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[HypertextLiteral]]
git-tree-sha1 = "1e3ccdc7a6f7b577623028e0095479f4727d8ec1"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.8.0"

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

[[Libcroco_jll]]
deps = ["Artifacts", "Glib_jll", "JLLWrappers", "Libdl", "Pkg", "XML2_jll"]
git-tree-sha1 = "a8e3b1b67458c8933992b95db9c4b37865906e3f"
uuid = "57eb2189-7eb1-52c8-ac0e-99495f550b14"
version = "0.6.13+2"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libepoxy_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "ae76616c0e0cbcbedc68d0121fe409598efc0b05"
uuid = "42c93a91-0102-5b3f-8f9d-e41de60ac950"
version = "1.5.8+0"

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

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
git-tree-sha1 = "67d44e433fc66e4ee584c7e06dc30bf1d7226aab"
uuid = "ae8d54c2-7ccd-5906-9d76-62fc9837b5bc"
version = "2.14.0"

[[MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "5455aef09b40e5020e1520f551fa3135040d4ed0"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+2"

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
git-tree-sha1 = "4f825c6da64aebaa22cc058ecfceed1ab9af1c7e"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.3"

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
git-tree-sha1 = "9bc1871464b12ed19297fbc56c4fb4ba84988b0d"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.47.0+0"

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
git-tree-sha1 = "f3a57a5acc16a69c03539b3684354cbbbb72c9ad"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.15.2"

[[PlutoTest]]
deps = ["HypertextLiteral", "InteractiveUtils", "Markdown", "Test"]
git-tree-sha1 = "3479836b31a31c29a7bac1f09d95f9c843ce1ade"
uuid = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
version = "0.1.0"

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
git-tree-sha1 = "508822dca004bf62e210609148511ad03ce8f1d8"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.6.0"

[[StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[Static]]
deps = ["IfElse"]
git-tree-sha1 = "62701892d172a2fa41a1f829f66d2b0db94a9a63"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.3.0"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "885838778bb6f0136f8317757d7803e0d81201e4"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.9"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "fed1ec1e65749c4d96fc20dd13bea72b55457e62"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.9"

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
git-tree-sha1 = "8f0cd4e2cb847346de37a8980bc2c8ea635ec3f0"
uuid = "24249f21-da20-56a4-8eb1-6a02cf4ae2e6"
version = "1.0.50"

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
git-tree-sha1 = "0facfc4bfd873c21b83a053bbf182b9ef19c69d8"
uuid = "da03df04-f53b-5353-a52f-6a8b0620ced0"
version = "2.42.6+0"

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
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

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
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
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
# ╠═e8bc8487-8e7e-4e5f-a06e-193669f4cce9
# ╟─3c07526e-31f8-4857-bd62-e6fc71d50c5b
# ╠═5da33fcf-33d3-492b-af3a-c07623e87f61
# ╟─7f3a6986-dfab-4e82-8eda-1a0bd72b47bd
# ╠═17faebbf-9fbd-4860-80b9-c5551bc34390
# ╟─43a30a97-42c3-446f-b57d-47af9b47565b
# ╠═adad2d93-4973-4631-8255-f855d12a2848
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
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
