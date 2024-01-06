# here we are going to figure out general data migrations. they are pretty confusing.
using Catlab, DataMigrations

# ----------------------------------------------------------------------
# conjunctive migrations

lab_graph = @acset LabeledGraph{String} begin
    V = 5
    label = ["Alice","Bob","Carol","Dan","Emily"]
    E = 6
    src = [1,1,3,3,3,5]
    tgt = [2,3,2,4,5,3]
end

@present SchSet(FreeSchema) begin
  X::Ob
end

@present SchLabeledSet <: SchSet begin
  Label::AttrType
  label::Attr(X,Label)
end

@acset_type LabeledSet(SchLabeledSet)

# ----------------------------------------------------------------------
# migration 1: extract all the edges

# extract the edges
M = @migration SchLabeledSet SchLabeledGraph begin
  X => V
  Label => Label
  label => label
end

migrate(LabeledSet{String}, lab_graph, M)

# is this just a delta migration?
F = @finfunctor SchLabeledSet SchLabeledGraph begin
  X => V
  Label => Label
  label => label
end

Δ = DataMigrationFunctor(F, LabeledGraph{String}, LabeledSet{String})
Δ(lab_graph)


# ----------------------------------------------------------------------
# migration 1: use conjunctive query to extract just some edges

M = @migration SchLabeledSet SchLabeledGraph begin
  X => @join begin
      v::V
      l::Label
      (f:v→l)::(x->label(x) ∈ ["Alice","Bob"] ? "yes" : "no")
      (g:v→l)::(y->"yes")
  end
  Label => Label
  label => begin v => label; l => id(Label) end
end

# M_nodes = @migration SchLabeledGraph SchLabeledGraph begin
#     V => @join begin
#         v::V
#         l::Label
#         (f:v→l)::(x->label(x) ∈ ["Alice","Bob"] ? "yes" : "no")
#         (g:v→l)::(y->"yes")
#     end
#     E => E
#     Label => Label
#     label => begin l => label end
#     src => begin v => src; l => label∘src end
#     tgt => begin v => tgt; l => label∘tgt end
# end


# M_nodes = @migration SchLabeledGraph SchLabeledGraph begin
#   V => @join begin
#       v::V
#       l::Label
#       (f:v→l)::(x->label(x) ∈ ["Alice","Bob"] ? "yes" : "no")
#       (g:v→l)::(y->"yes")
#   end
#   E => @empty
#   Label => Label
# end

# ----------------------------------------------------------------------
# old stuff


@present SchSet(FreeSchema) begin
  X::Ob
end
@acset_type AcsetSet(SchSet)

@present SchDDS <: SchSet begin
  Φ::Hom(X,X)
end
@acset_type DDS(SchDDS, index=[:Φ])

# pretty graphviz settings
to_graphviz(SchDDS,graph_attrs=Dict("dpi"=>"72","size"=>"4","ratio"=>"expand"))

# ----------------------------------------------------------------------
# delta (pullback) migration
dds = @acset DDS begin
  X=7
  Φ=[4,4,5,5,5,7,6]
end
X = SchDDS[:X]

F = @migration SchGraph SchDDS begin
  V => X
  E => X
  src => id(X)
  tgt => Φ
end

g = migrate(Graph, dds, F)
to_graphviz(g,node_labels=true,edge_labels=true)

# a different F that now gives the graph of what state it came from
F = @migration SchGraph SchDDS begin
  V => X
  E => X
  src => Φ
  tgt => id(X)
end

g = migrate(Graph, dds, F)
to_graphviz(g,node_labels=true,edge_labels=true)

# alternate specification syntax
F = @finfunctor SchGraph SchDDS begin
  V => X
  E => X
  src => id(X)
  tgt => Φ
end

Δ = DataMigrationFunctor(F, DDS, Graph)
Δ(dds)

# ----------------------------------------------------------------------
# ex from Functorial Data Migration paper

@present C(FreeSchema) begin
  (T1,T2)::Ob
  (SSN,First,Last,Salary)::AttrType
  ssn::Attr(T1,SSN)
  first_t1::Attr(T1,First)
  last_t1::Attr(T1,First)
  first_t2::Attr(T2,First)
  last_t2::Attr(T2,First)
  salary::Attr(T2,Salary)
end

@acset_type C_data(C)

C_inst = @acset C_data{String,String,String,Int} begin
  T1=3
  ssn=["115-234","122-988","198-877"]
  first_t1=["Bob","Alice","Sue"]
  last_t1=["Smith","Smith","Jones"]
  T2=4
  first_t2=["Alice","Sam","Sue","Carl"]
  last_t2=["Jones","Miller","Smith","Pratt"]
  salary=[100,150,300,200]
end
