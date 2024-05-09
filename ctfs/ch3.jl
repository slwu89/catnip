using Catlab
using Test

# cheating for visuals
@present SetSch(FreeSchema) begin
    X::Ob
end
@present LabeledSetSch <: SetSch begin
    Label::AttrType
    label::Attr(X,Label)
end
@acset_type LabeledSet(LabeledSetSch, unique_index=[:label])

X = @acset LabeledSet{Symbol} begin
    X=6
    label=Symbol.(1:6)
end

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

@test length(apex(XxY)) == 24
@test codom(legs(XxY)[1]) == X
@test codom(legs(XxY)[2]) == Y
# to_graphviz(legs(XxY)[1], graph_attrs=Dict(:splines=>"false"))