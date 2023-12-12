# here we are going to figure out general data migrations. they are pretty confusing.
using Catlab
# i guess DataMigrations.jl will be needed soon, after the next Catlab version upgrade

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

# ----------------------------------------------------------------------
# general conjunctive migrations