### A Pluto.jl notebook ###
# v0.19.15

using Markdown
using InteractiveUtils

# ╔═╡ 9ab6fd45-9359-4799-bb48-81606ffb67f1
begin
    import Pkg
    # activate the shared project environment
    Pkg.activate(Base.current_project())
    # instantiate, i.e. make sure that all packages are downloaded
    Pkg.instantiate()

    using PlutoUI, Images, Luxor, SQLite, DataFrames
end

# ╔═╡ a04e9cd2-f76c-11eb-28c7-47acab963b51
md"""
# Berekening boutverbinding
Berekening van de boutverbinden volgens *NBN EN 1993-1-8* en haar nationale bijlage *NBN EN 1993-1-8 ANB*. Berekening van 3 kolomvoeten, 1 éénzijdig liggerliggerverbinding, en dan nog enkele kolomliggerverbindingen.

$(load("./assets/img/NBN EN 1993-1-8 fig 1.2.png"))
"""

# ╔═╡ 1e6e4c56-e446-4ca5-917d-5f1d4de37416
db = SQLite.DB("./assets/db/db.sqlite")

# ╔═╡ d9c4de22-32ea-4786-b9e6-353dffa02e27
begin
	struct Foldable{C}
		title::String
		content::C
	end
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
end

# ╔═╡ 355fceab-ace8-447f-b050-179738c97728
PlutoUI.TableOfContents(title="Berekening boutverbindingen", depth=4)

# ╔═╡ 1fe5a4c5-3645-4b10-92b7-06fec8436a58
md"""
## Uitgangspunten
Algemene uitgangspunten gebruikt bij de berekening
"""

# ╔═╡ 092683d5-f60b-4ff3-9b18-ab041f199101
# Weerstand van elementen en doorsneden --> γ_M0, γ_M1 en γ_M2
# Weerstand bouten/lassen/.... --> γ_M2
γ_M0, γ_M1, γ_M2, γ_M3 = 1.0, 1.0, 1.25, 1.25

# ╔═╡ a9c884d4-1931-42a7-ba45-ac3312165aab
md"""
### Aangrijpende krachten en momenten
Krachten en momenten bepaald volgens *NBN EN 1993-1-1*, deze volgen uit de afzonderlijke berekeningen van de profielen en kolommen. **Excentriciteit** ter plaatse van de snijpunten van schemalijnen geven aanleidingen tot **bijkomende momenten en krachten**, dit dient meegenomen worden inde berekening. Zie beschrijving *NBN EN 1993-1-8 §2.7*
"""

# ╔═╡ ae145099-ef28-4e28-82bc-1083c8b28cbe
md"""
### Weerstand van verbindingen
Bepaald op basis van weerstand basiscomponenten, lineair-elastische controle of elasto-plastische berekenigsmethode. 
"""

# ╔═╡ 107cc6cd-a39b-4073-8f1b-8c54be1886d2
f_yb(k::Real) = *((split(string(k), ".") .|> Meta.parse)...) * 10 # N/mm²

# ╔═╡ 87c79e47-81f7-41bf-bbf2-c02817af97eb
f_ub(k::Real) = (split(string(k), ".") .|> Meta.parse)[1] * 100 # N/mm²

# ╔═╡ 1033c8e9-1c5b-4280-ac95-8294db7c73b1
md"""
### Verbinding met bouten
#### Categorieën van boutverbindingen
Op **Afschuiving** belast:
- Categorie **A**: op stuik belast
- Categorie **B**: glijvast in bruikbaarheidsgrenstoestand `:GGT`
- Categorie **C**: glijvast in uiterste grenstoestand `:UGT`
Op **Trek** belast:
- Categorie **D**: **niet**-voorgespannen - bouten klasse ’4.6 tot en met 10.9
- Categorie **E**: voorgespannen - bouten klasse 8.8 en 10.9
"""

# ╔═╡ 2b66807c-10f3-4ef6-9807-70a2fcf5715f
Foldable("NBN EN 1993-1-8 Tabel 3.2", md"""$(load("./assets/img/NBN EN 1993-1-8 tab 3.2.png"))""")

# ╔═╡ 12254917-ac52-4ed0-8ac7-afb862d7da42
md"""
Overzicht van de mogelijke bouten - Eigenschappen van de bouten, zoals bijvoorbeeld de **nominale gatafstand** d₀, zijn afgeleid uit *NBN EN 1090-2*
"""

# ╔═╡ 76c613a4-efb9-4973-ab48-50be1705461a
bouten = DBInterface.execute(db, "SELECT * FROM bolts") |> DataFrame

# ╔═╡ f6359ac4-0b86-4ee0-b179-56a95dc35aa1
bout(naam) = bouten[bouten.name .== naam, :] |> first

# ╔═╡ 18713d83-ea36-4968-aed2-c601b84599b6
md"""
#### Positionering van gaten voor bouten
Volgens voorwaarden opgenomen in *NBN EN 1993-1-8 §3.5*
"""

# ╔═╡ d1bb4c3f-8012-4c8f-9d6c-66f1e9c519d9
md"""
#### Rekenwaarden weerstanden van individuele verbindingsmiddelen
Volgens *NBN EN 1993-1-8 §3.6*. Rekenwaardes voor bouten met nominale gatspeling.
"""

# ╔═╡ b9ada3a1-6d55-4409-9673-302287bfc686
test = DataFrame([
	(klasse=4.6,),
	(klasse=8.8,)
])

# ╔═╡ ddc56172-268f-4bc2-a7f5-455f7552c019
select(
	test,
	:,
	:klasse => ByRow(f_yb) => :f_yb,
	:klasse => ByRow(f_ub) => :f_ub
)

# ╔═╡ 1ea47049-b132-4198-9c18-9f5b27040be7
Foldable(
	"NBN EN 1993-1-8 Tabel 3.4: Rekenwaarde van de weerstand voor individuele verbindingsmiddelen, die zijn onderworpen aan afschuiving en/of trek",
	md"""$(load("./assets/img/NBN EN 1993-1-8 tab 3.4.png"))"""
)

# ╔═╡ 54d78156-4779-4c9d-bcd3-4e7ee64f0df9
md"""
##### Knoop 1
Verbinding tussen kolom 1 en profiel 1
"""

# ╔═╡ d797ea1b-239f-440c-8416-be5c5dc68767
k1_configuratie = (
	bout = "M12",
	klasse = 8.8,
	configuratie = [1 1; 1 1] 
)	

# ╔═╡ 2fb58b1f-4bab-438e-96c5-fd7e6eb65b6d
k1_krachten = DataFrame([
	(geval=:GGT, waarde=50)
	(geval=:UGT, waarde=100)	
])

# ╔═╡ 0095a0d5-c798-4b10-995a-b99f4aa97291
begin
	k1_krachten[!, :bout] .= k1_configuratie.bout
	k1_krachten[!, :klasse] .= k1_configuratie.klasse
	# Aanname enkel bouten bovenste rij nemen dwarskracht op
	k1_krachten[!, :aantal] .= sum(k1_configuratie.configuratie[1,:])
	# Bereken de aangrijpende kracht
	select!(
		k1_krachten, :, [:waarde, :aantal] => ByRow(/) => :F_vEd
	)
	# Bereken de weerstandbiedende kracht
	α_v(klasse) = klasse in [4.6, 5.6, 8.8] ? 0.6 : 0.5
	select!(
		k1_krachten, :, AsTable([:bout, :klasse]) => ByRow(
			r -> α_v(r.klasse) * f_ub(r.klasse) * bout(r.bout).As / γ_M2 / 1000	
		) => :F_vRd # kN
	)
end

# ╔═╡ 23bfa758-13ba-465e-873f-ce9200abd334
md"""
##### Knoop 2
Verbinding tussen kolom 1 en profiel 2
"""

# ╔═╡ 6b60b1b4-6e6e-45df-b732-f286b4b104fe
md"""
##### Knoop 3
Verbinding tussen kolom 1 / profiel 1 en profiel 3
"""

# ╔═╡ Cell order:
# ╠═9ab6fd45-9359-4799-bb48-81606ffb67f1
# ╟─a04e9cd2-f76c-11eb-28c7-47acab963b51
# ╟─1e6e4c56-e446-4ca5-917d-5f1d4de37416
# ╟─d9c4de22-32ea-4786-b9e6-353dffa02e27
# ╟─355fceab-ace8-447f-b050-179738c97728
# ╟─1fe5a4c5-3645-4b10-92b7-06fec8436a58
# ╠═092683d5-f60b-4ff3-9b18-ab041f199101
# ╟─a9c884d4-1931-42a7-ba45-ac3312165aab
# ╟─ae145099-ef28-4e28-82bc-1083c8b28cbe
# ╠═107cc6cd-a39b-4073-8f1b-8c54be1886d2
# ╠═87c79e47-81f7-41bf-bbf2-c02817af97eb
# ╟─1033c8e9-1c5b-4280-ac95-8294db7c73b1
# ╟─2b66807c-10f3-4ef6-9807-70a2fcf5715f
# ╟─12254917-ac52-4ed0-8ac7-afb862d7da42
# ╟─76c613a4-efb9-4973-ab48-50be1705461a
# ╠═f6359ac4-0b86-4ee0-b179-56a95dc35aa1
# ╟─18713d83-ea36-4968-aed2-c601b84599b6
# ╟─d1bb4c3f-8012-4c8f-9d6c-66f1e9c519d9
# ╠═b9ada3a1-6d55-4409-9673-302287bfc686
# ╠═ddc56172-268f-4bc2-a7f5-455f7552c019
# ╟─1ea47049-b132-4198-9c18-9f5b27040be7
# ╟─54d78156-4779-4c9d-bcd3-4e7ee64f0df9
# ╠═d797ea1b-239f-440c-8416-be5c5dc68767
# ╠═2fb58b1f-4bab-438e-96c5-fd7e6eb65b6d
# ╟─0095a0d5-c798-4b10-995a-b99f4aa97291
# ╟─23bfa758-13ba-465e-873f-ce9200abd334
# ╟─6b60b1b4-6e6e-45df-b732-f286b4b104fe
