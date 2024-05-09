using Catlab
using Test

# fig 2.2
X=FinSet(4)
Y=FinSet(5)
f=FinFunction([1,2,4,1],X,Y)
to_graphviz(f, node_labels=true, graph_attrs=Dict(:splines=>"false", :rankdir => "LR"))

# ex 2.1.2.5
# f = SetFunction(x -> x^2, TypeSet(Int), TypeSet(Int))
ℕ = PredicatedSet(Int, x -> x ≥ 0)
f = SetFunction(x -> x^2, ℕ, ℕ)

@test f(2) == 4
@test f(0) == 0
@test_throws ErrorException f(-2) # -2 not in ℕ
@test f(5) == 25

# ex 2.1.2.6
X=FinSet(4)
Y=FinSet(5)
f=FinFunction([1,2,4,1],X,Y)

# use `image` to do this
im_f = image(f)
@test length(apex(cone(im_f))) == 3
# image as subset of the codomain, Y
to_graphviz(legs(cone(im_f))[1])

# ex 2.1.2.8
X = TypeSet(Int)
Y = TypeSet(Int)
i = FinDomFunction([-1,0,1,2,3])
f = SetFunction(x -> x^2, X, Y)
im_f = image(compose(i,f))

# union(compose(i,f).(collect(dom(i))))

# ex 2.1.2.12

# ex 2.1.2.13

# def 2.1.2.14

# ex 2.1.2.24
