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
using PlutoUI

# ╔═╡ 5efe93a9-ac3c-461c-84f5-c712cfabd64e
using Conda

# ╔═╡ c8a4fe15-a02f-4793-b4a7-618cad214524
using PyCall

# ╔═╡ e4e4732f-e3b7-4b29-8a84-e6b1da74289a
using SymPy

# ╔═╡ 2e054eb8-529b-49f4-8e0c-2dec5d0e1499
using Plots

# ╔═╡ c4c79ab2-d6b7-11eb-09d0-e3cbf2c9d6e9
md"# Symbolic computation"

# ╔═╡ 4057befe-af07-426c-93d5-3b1b06ac70d2
md"This notebook is meant to explore the symbolic computation in Julia"

# ╔═╡ a841663b-a218-445f-8249-a28a766cbde5
md"First we tried `Symbolics.jl`, however, it doesn't supports symbolic integration and was kind of useless in our situation. Therefor, we tried an approach using the python package `SymPy`. To get started, install the package:

One approach is to use `PyCall` to add Sympy to Julia
```julia
import Pkg; Pkg.add(\"Conda\")
import Pkg; Pkg.add(\"PyCall\")
# Install SymPy using Conda
Conda.add(\"sympy\")
# PyCall uses the python interpreter included in the Conda.jl package
sympy = pyimport(\"sympy\")
```

A better approach is to use the `SymPy` package to get a more *Julia* syntax
```julia
import Pkg; Pkg.add(\"SymPy\")
```
"

# ╔═╡ 36539448-dc98-404e-b30c-a872091e8f3c
md"## Piecewise function
Use the heaviside function to create piecewise function"

# ╔═╡ 8d67ceaf-7303-4fb2-9577-a7fd2db6d233
function _heaviside(t)
	0.5 * (sign(t) + 1)
end

# ╔═╡ 048926fe-0fa3-44c4-8772-0e4adae576a4
md"Ook `SymPy` heeft een methode Heaviside - functie te gebruiken via `PyCall`"

# ╔═╡ 79cf1b35-6ec0-4950-9f47-e800dee0b44a
heaviside = sympy.functions.special.delta_functions.Heaviside

# ╔═╡ 265977b4-0fd8-4e38-aa46-6be5bcd00420
function interval(t, a, b)
	heaviside(t-a) - heaviside(t-b) 
end

# ╔═╡ 6428b28d-7aa9-489d-b2b9-c08db5876342
md"Naast `Heaviside` is er ook een methode `Piecewise` via `PyCall` aan te roepen. Helaas ondersteunen deze functie wel geen Array calls, dus moet je de `map` functie in *Julia* gaan gebruiken om bijvoorbeeld te gaan plotten"

# ╔═╡ 7683a362-ab86-4f19-964d-e71a61e86436
piecewise = sympy.functions.elementary.piecewise.Piecewise

# ╔═╡ 142a1d34-2efe-4665-8e50-1345e256c505
test(t) = piecewise((10, t < 5), (12, t < 8))

# ╔═╡ a4a02c26-8a86-441c-b2be-1a67f07338e5
md"Dus om de `piecewise` functie te plotten, moet je de $x$-waardes mappen op de functie"

# ╔═╡ cb29f50a-b89c-41fb-ba03-b0bc6427e6eb
begin
	x_ = range(0, 12, length=40)
	y_ = map(test, x_)
end

# ╔═╡ 697bb211-af08-4d0d-a69e-60e8cace2996
plot(x_, y_)

# ╔═╡ 31851342-e653-45c2-8df6-223593a7f942
md"## Eenvoudig opgelegde balk
Eenvoudig opgelegde balk met twee verdeelde belastingen"

# ╔═╡ a81fbf3e-f5c7-41c7-a71e-68f8a9589b45
md"value $x$ = $(@bind x NumberField(0:10; default=5))"

# ╔═╡ 04b77a81-2e9c-4af9-80a4-088c3b52ca81
md"Gebruik `@syms` om *SymPy symbols* te definiëren"

# ╔═╡ 5ecfe3ff-1d27-40dd-8e13-79e48a6f7bdb
@syms t::positive p1 p2 L1::positive L2::positive

# ╔═╡ 43ff70cc-235f-44e4-9a32-beabd9de7abb
md"### Steunpunten
Bepaal de krachten in de steunpunten door het momentenevenwicht uit te schrijven in de steunpunten. Het moment ter hoogte van de steunpunten is $0$, dus uit dit gegeven bereken je eenvoudig de krachten ter hoogte van de steunpunten"

# ╔═╡ 38521108-210f-4306-86e4-e1ac29de93ca
R1 = (p1 * L1 * (L1/2 + L2) + p2 * L2 ^ 2/2)/(L1 + L2) 

# ╔═╡ 55883ecc-2d5d-4d51-be13-1163ee70b29f
R2 = (p1 * L1 + p2 * L2) - R1

# ╔═╡ 99e49c7b-b2dd-49dc-bee1-336d4d1334b1
md"### Interne krachtswerking
Bepaal de dwarskrachten $V(t)$ en momenten $M(t)$ voor een eenvoudig opgelegde ligger met twee verdeelde belastingen"

# ╔═╡ 6a449992-2801-4a0d-a5dd-df0a2a381b9b
begin
	# Opsplitsen per deel variabele belasting
	V1 = R1 - p1 * t
	V2 = R1 - p1 * L1 - p2 * (t - L1)
	V = V1 .* interval(t, 0, L1) + V2 .* interval(t, L1, L1 + L2) 
end

# ╔═╡ e1064739-cae5-48b7-ac59-f45a0e8fc64a
begin
	# Opsplitsen per deel variabele belasting
	M1 = R1 * t - p1 * t ^ 2 / 2
	M2 = R1 * t - p1 * L1 * (t - L1/2) - p2 * (t - L1) ^ 2 / 2
	M = M1 .* interval(t, 0, L1) + M2 .* interval(t, L1, (L1 + L2)) 
end

# ╔═╡ 11cbeac1-8042-476f-8ed3-c8943133ac52
md"Substitueren via de `call` methode die is *overloaded*, handig!"

# ╔═╡ 85ca8e3d-69d8-4ed5-9155-162a3e47a19d
V(t=>0, p1=>30, p2=>x, L1=>2, L2=>3)

# ╔═╡ 67c992cd-2237-400c-93be-d65048e3b2ad
md"We wensen de **vervormingen** $v(t)$ te kennen van de ligger, hiervoor grijpen we terug naar de volgende theorie. De kromming $\chi$ is gelijk aan de verhouding tussen het moment en de buigstijfheid.

$$\chi = \dfrac{\text{M}}{\text{EI}} = \dfrac{d\alpha}{dt} = \dfrac{d^2v}{dt^2}$$

Merk op dat we hier $t$ hanteren als indicatie voor de positie op de ligger."

# ╔═╡ 9339102e-af71-4a56-94a5-f3157dd78740
@syms C1::real D1::real C2::real D2::real

# ╔═╡ bf8af7b8-1f5f-4024-8399-8bf24bcc8bf6
md"Bereken de hoekverdraaiing, hierbij hebben we even voor het gemak de *buigstijfheid* $EI$ niet meegenomen in de berekening"

# ╔═╡ 927401a6-e4bc-46e2-a65e-8436a7ea5278
begin
	# Opsplitsen per deel variabele belasting
	α1 = integrate(M1, t) + C1
	α2 = integrate(M2, t) + C2
	α = α1 .* interval(t, 0, L1) + α2 .* interval(t, L1, L1 + L2)
end

# ╔═╡ 6cf507be-7328-47e3-8312-dcac4c29cdd9
begin
	# Opsplitsen per deel variabele belasting
	v1 = integrate(α1, t) + D1
	v2 = integrate(α2, t) + D2
	v = v1 .* interval(t, 0, L1) + v2 .* interval(t, L1, L1 + L2)
end

# ╔═╡ 96134cde-f7e4-4bd5-b3c0-2fa05708f7f4
md"### Kinematische randvoorwaarden
Leg de kinematische randvoorwaarden op om de constantes te gaan bepalen. Deze voorwaarden bestaan onderander uit $v(t=>0) = 0$ en $v(t=>(L1 + L2)) = 0$"

# ╔═╡ 833e2a1d-5264-4b02-a891-b6ee063fe60d
d = solve([v1(t=>L1) - v2(t=>L1), v1(t=>0), v2(t=>(L1 + L2)), α1(t=>L1) - α2(t=>L1)], [C1, C2, D1, D2])

# ╔═╡ 42008bf2-1584-4dc5-bfb4-20f1f672a4b7
md"### Invoeren oplossing
Voer de oplossing in die bepaald is uit de kinematische randvoorwaardes"

# ╔═╡ b49f62de-505f-4447-81a8-9eace4283329
α_opl = α.subs(d)

# ╔═╡ 33b7355d-38fc-472c-aa62-e0273c3c0c55
v_opl = v.subs(d)

# ╔═╡ 9c087fd6-4a2a-44c4-8e6a-34418fc97cd4
plotly()

# ╔═╡ 8f910bf3-5227-4113-9476-6136194a5e60
md"### Boundary Conditions
Definiëer de randvoorwaarden of *Boundary Conditions* $(\text{BC})$"

# ╔═╡ a1eb360d-4c1b-4e80-b8aa-93cecad1d497
BC = L1 => 2.47, L2 => 1.52, p1 => 66.99, p2 => 40.48

# ╔═╡ b70d1695-7e91-4903-a239-2a3adb4c3bd8
md"#### Krachten ter hoogte van de steunpunten"

# ╔═╡ 59ce2926-09ea-4e9e-9ace-af33127c3984
md"Waarde van $\text{R1}$ = $(round(R1(BC...), digits=2)) kN"

# ╔═╡ 939b3526-6be6-4e92-9243-68809c9daf80
md"Waarde van $\text{R2}$ = $(round(R2(BC...), digits=2)) kN"

# ╔═╡ 03dfa81c-eaa3-4273-bfff-ab4c8159ee35
md"#### Dwarskracht en momenten"

# ╔═╡ 5e787e9a-6e07-4917-8327-843d5063115f
dwarskracht = V(BC...)

# ╔═╡ 7c3aaf49-ea8d-46e2-b34a-51dfc727b1c7
moment = M(BC...)

# ╔═╡ add58b5c-26e9-44e9-916f-13960b7e085c
md"Heaviside van $\text{L}$ kan niet worden berekend, daarom trekken we er $1e-10$ van af"

# ╔═╡ 9281e85f-dd2b-4410-b41d-e233ce5674e9
L = N((L1 + L2)(BC...) - 1e-10)

# ╔═╡ 78a060bd-f930-4205-a956-abbb72797c1c
md"Voor de vervorming en hoekverdraaiing moet de stijfheid in acht genomen worden"

# ╔═╡ 03e08a96-29c2-4921-b107-ded3f7dce079
EI = 210000 * 5.7E7 / 10^9 # kNm2

# ╔═╡ 2d46f88c-d157-4754-a8e8-e023432625b4
hoekverdraaiing = α_opl(BC...) / EI # rad

# ╔═╡ be75289e-1429-4b0d-9a58-92dfb915f8e8
doorbuiging = v_opl(BC...) / EI * 1000 # mm

# ╔═╡ e449b656-9f2b-4e34-b97f-12a9d75c7d22
begin
	_x = 0:0.1:L
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

# ╔═╡ Cell order:
# ╟─c4c79ab2-d6b7-11eb-09d0-e3cbf2c9d6e9
# ╟─4057befe-af07-426c-93d5-3b1b06ac70d2
# ╠═992f5882-98c6-47e4-810c-81293a396c75
# ╟─a841663b-a218-445f-8249-a28a766cbde5
# ╠═5efe93a9-ac3c-461c-84f5-c712cfabd64e
# ╠═c8a4fe15-a02f-4793-b4a7-618cad214524
# ╠═e4e4732f-e3b7-4b29-8a84-e6b1da74289a
# ╟─36539448-dc98-404e-b30c-a872091e8f3c
# ╠═8d67ceaf-7303-4fb2-9577-a7fd2db6d233
# ╟─048926fe-0fa3-44c4-8772-0e4adae576a4
# ╠═79cf1b35-6ec0-4950-9f47-e800dee0b44a
# ╠═265977b4-0fd8-4e38-aa46-6be5bcd00420
# ╟─6428b28d-7aa9-489d-b2b9-c08db5876342
# ╠═7683a362-ab86-4f19-964d-e71a61e86436
# ╠═142a1d34-2efe-4665-8e50-1345e256c505
# ╟─a4a02c26-8a86-441c-b2be-1a67f07338e5
# ╠═cb29f50a-b89c-41fb-ba03-b0bc6427e6eb
# ╠═697bb211-af08-4d0d-a69e-60e8cace2996
# ╟─31851342-e653-45c2-8df6-223593a7f942
# ╟─a81fbf3e-f5c7-41c7-a71e-68f8a9589b45
# ╟─04b77a81-2e9c-4af9-80a4-088c3b52ca81
# ╠═5ecfe3ff-1d27-40dd-8e13-79e48a6f7bdb
# ╟─43ff70cc-235f-44e4-9a32-beabd9de7abb
# ╠═38521108-210f-4306-86e4-e1ac29de93ca
# ╠═55883ecc-2d5d-4d51-be13-1163ee70b29f
# ╟─99e49c7b-b2dd-49dc-bee1-336d4d1334b1
# ╠═6a449992-2801-4a0d-a5dd-df0a2a381b9b
# ╠═e1064739-cae5-48b7-ac59-f45a0e8fc64a
# ╟─11cbeac1-8042-476f-8ed3-c8943133ac52
# ╠═85ca8e3d-69d8-4ed5-9155-162a3e47a19d
# ╟─67c992cd-2237-400c-93be-d65048e3b2ad
# ╠═9339102e-af71-4a56-94a5-f3157dd78740
# ╟─bf8af7b8-1f5f-4024-8399-8bf24bcc8bf6
# ╠═927401a6-e4bc-46e2-a65e-8436a7ea5278
# ╠═6cf507be-7328-47e3-8312-dcac4c29cdd9
# ╟─96134cde-f7e4-4bd5-b3c0-2fa05708f7f4
# ╠═833e2a1d-5264-4b02-a891-b6ee063fe60d
# ╟─42008bf2-1584-4dc5-bfb4-20f1f672a4b7
# ╠═b49f62de-505f-4447-81a8-9eace4283329
# ╠═33b7355d-38fc-472c-aa62-e0273c3c0c55
# ╠═2e054eb8-529b-49f4-8e0c-2dec5d0e1499
# ╠═9c087fd6-4a2a-44c4-8e6a-34418fc97cd4
# ╟─8f910bf3-5227-4113-9476-6136194a5e60
# ╠═a1eb360d-4c1b-4e80-b8aa-93cecad1d497
# ╟─b70d1695-7e91-4903-a239-2a3adb4c3bd8
# ╟─59ce2926-09ea-4e9e-9ace-af33127c3984
# ╟─939b3526-6be6-4e92-9243-68809c9daf80
# ╟─03dfa81c-eaa3-4273-bfff-ab4c8159ee35
# ╠═5e787e9a-6e07-4917-8327-843d5063115f
# ╠═7c3aaf49-ea8d-46e2-b34a-51dfc727b1c7
# ╟─add58b5c-26e9-44e9-916f-13960b7e085c
# ╠═9281e85f-dd2b-4410-b41d-e233ce5674e9
# ╟─78a060bd-f930-4205-a956-abbb72797c1c
# ╠═03e08a96-29c2-4921-b107-ded3f7dce079
# ╠═2d46f88c-d157-4754-a8e8-e023432625b4
# ╠═be75289e-1429-4b0d-9a58-92dfb915f8e8
# ╠═e449b656-9f2b-4e34-b97f-12a9d75c7d22
