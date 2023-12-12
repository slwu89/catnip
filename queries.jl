using Catlab, DataFrames

@present FamilySchema <: SchGraph begin 
    NameType::AttrType
    name::Attr(V,NameType)
end

to_graphviz(FamilySchema,graph_attrs=Dict(:dpi=>"72",:size=>"4",:ratio=>"expand"))

# at this point, an interesting observation to make is that this is exactly a graph
# with named vertices, which makes sense, the relationship is directed.
# so the edges are also like a subset of the product of vertices.

@acset_type FamilyData(FamilySchema, index=[:p, :c]) <: AbstractGraph


names = ["Loid","Yor","Van","Trisha","Gendo","Yui","Anya","Alphonse","Ed","Shinji","Rei"]
Families = FamilyData{String}()

add_parts!(Families, :V, length(names), name=names)
add_parts!(
    Families, :E, 10,
    src = [
        only(incident(Families, "Loid", :name)),
        only(incident(Families, "Yor", :name)),
        only(incident(Families, "Van", :name)),
        only(incident(Families, "Trisha", :name)),
        only(incident(Families, "Van", :name)),
        only(incident(Families, "Trisha", :name)),
        only(incident(Families, "Gendo", :name)),
        only(incident(Families, "Gendo", :name)),
        only(incident(Families, "Yui", :name)),
        only(incident(Families, "Yui", :name))
    ],
    tgt = [
        only(incident(Families, "Anya", :name)),
        only(incident(Families, "Anya", :name)),
        only(incident(Families, "Alphonse", :name)),
        only(incident(Families, "Alphonse", :name)),
        only(incident(Families, "Ed", :name)),
        only(incident(Families, "Ed", :name)),
        only(incident(Families, "Shinji", :name)),
        only(incident(Families, "Rei", :name)),
        only(incident(Families, "Shinji", :name)),
        only(incident(Families, "Rei", :name))
    ]
)

to_graphviz(Families,node_labels=:name)


basic_query = @relation (E=e,parent=parentname,child=childname) begin
    E(_id=e, src=parent, tgt=child)
    V(_id=parent, name=parentname)
    V(_id=child, name=childname)
end
to_graphviz(basic_query,box_labels=:name,junction_labels=:variable)

query(Families, basic_query)

query(Families, basic_query, (childname="Anya",))
query(Families, basic_query, (parentname="Gendo",))