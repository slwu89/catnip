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