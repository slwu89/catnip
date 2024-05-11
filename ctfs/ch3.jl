using Catlab
using Test

# ----------------------------------------------------------------------
# products

# cheating for visuals
@present SetSch(FreeSchema) begin
    X::Ob
end
@present LabeledSetSch <: SetSch begin
    Label::AttrType
    label::Attr(X,Label)
end
@acset_type LabeledSet(LabeledSetSch, unique_index=[:label])

X = @acset LabeledSet{Int} begin
    X=6
    label=1:6
end

Y = @acset LabeledSet{Symbol} begin
    X=4
    label=[:♣,:♢,:♡,:♠]
end 

XxY = product(X,Y,loose=true)

apex(XxY)[:,:label]

# products
X = FinSet(6)
Y = FinSet(4)
XxY = product(X,Y)

π₁ = proj1(XxY)
π₂ = proj2(XxY)

@test length(apex(XxY)) == 24
@test codom(π₁) == X
@test codom(π₂) == Y
# to_graphviz(legs(XxY)[1], graph_attrs=Dict(:splines=>"false"))

# a product is a type of limit, there is a universal arrow we can get
# from any other product-like (lower bound) for X and Y
A = FinSet(10)
f = FinFunction([1,2,3,4,5,6,1,2,3,4],A,X)
g = FinFunction([1,2,3,4,1,2,3,4,1,2],A,Y)
fg = universal(XxY, Span(f,g))

# manually check for universal property
@test force(compose(fg, π₁)) == f
@test force(compose(fg, π₂)) == g


# ----------------------------------------------------------------------
# coproducts

X = @acset LabeledSet{Symbol} begin
    X=4
    label=[:a,:b,:c,:d]
end

Y = @acset LabeledSet{Symbol} begin
    X=3
    label=Symbol.(1:3)
end 

g = (Label=FinFunction(Dict([l=>l for l in X[:,:label]])),)
h = (Label=FinFunction(Dict([l=>l for l in Y[:,:label]])),)
coproduct(X,Y, type_components=[g,h])

colimit(Tuple{LabeledSet{Symbol},LooseACSetTransformation},
        DiscreteDiagram([X,Y]);
        type_components=[g,h]) |> apex



X = FinSet(4)
Y = FinSet(3)
XuY = coproduct(X,Y)

@test length(apex(XuY)) == 7

# coproduct is a colimit, and it is like a least upper bound.
# so for anything else which is an upper bound, the universal
# property says theres a unique morphism from it into the imposter.
