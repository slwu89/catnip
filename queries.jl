using Catlab, 
    Catlab.CategoricalAlgebra, Catlab.WiringDiagrams, Catlab.Programs,
    Catlab.Graphics, Catlab.Graphs
using Graphviz_jll

@present FamilySchema(FreeSchema) begin
    (Pair,Person,Child)::Ob
    p::Hom(Pair,Person)
    c::Hom(Pair,Child)

    Name::AttrType
    p_name::Attr(Person,Name)
    c_name::Attr(Child,Name)
end

to_graphviz(FamilySchema)

@acset_type FamilyData(FamilySchema, index=[:p, :c])

Families = FamilyData{String}()

add_parts!(Families, :Person, 5, p_name=["Loid","Yor","Van","Trisha","Gendo"])
add_parts!(Families, :Child, 4, c_name=["Anya","Alphonse","Ed","Shinji"])
add_parts!(
    Families, 
    :Pair, 
    7,
    p = [
        only(incident(Families, "Loid", :p_name)),
        only(incident(Families, "Yor", :p_name)),
        only(incident(Families, "Van", :p_name)),
        only(incident(Families, "Van", :p_name)),
        only(incident(Families, "Trisha", :p_name)),
        only(incident(Families, "Trisha", :p_name)),
        only(incident(Families, "Gendo", :p_name))
    ],
    c = [
        only(incident(Families, "Anya", :c_name)),
        only(incident(Families, "Anya", :c_name)),
        only(incident(Families, "Alphonse", :c_name)),
        only(incident(Families, "Alphonse", :c_name)),
        only(incident(Families, "Ed", :c_name)),
        only(incident(Families, "Ed", :c_name)),
        only(incident(Families, "Shinji", :c_name))
    ]
)

# get 

basic_query = @relation (Person=parent,Child=child,Pair=p) begin
    Pair(_id=p, p=parent, c=child)
    Person(_id=parent)
    Child(_id=child)
end
to_graphviz(basic_query,box_labels=:name,junction_labels=:variable)

result = query(Families, basic_query)

family_graph = Graph(
    Families,
    Dict(:V => :Person, :E => :Pair),
    Dict(:src => :p, :tgt => :c)
)
