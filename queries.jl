using Catlab, DataFrames

# ----------------------------------------------------------------------
# schemas with path equivalences
@present PathEqSch(FreeSchema) begin
    (Employee,Department)::Ob
    Mgr::Hom(Employee,Employee)
    isIn::Hom(Employee,Department)
    Secr::Hom(Department,Employee)
    String::AttrType
    First::Attr(Employee,String)
    Last::Attr(Employee,String)
    Name::Attr(Department,String)

    compose(Secr,isIn) == id(Department)
    compose(Mgr,isIn) == isIn
end

@acset_type PathEqData(PathEqSch, index=[:Mgr,:isIn,:Secr])

org_data = @acset PathEqData{String} begin
    Employee = 3
    Department = 2
    Mgr = [3,2,3]
    isIn = [1,2,1]
    Secr = [1,2]
    First = ["David","Bertrand","Alan"]
    Last = ["Hilbert","Russell","Turing"]
    Name = ["Sales","Production"]
end


# ----------------------------------------------------------------------
# conjunctive queries on a database instance
@present FamilySch <: SchGraph begin 
    NameType::AttrType
    name::Attr(V,NameType)
end

to_graphviz(FamilySch,graph_attrs=Dict(:dpi=>"72",:size=>"4",:ratio=>"expand"))

# at this point, an interesting observation to make is that this is exactly a graph
# with named vertices, which makes sense, the relationship is directed.
# so the edges are also like a subset of the product of vertices.

@acset_type FamilyData(FamilySch, index=[:p, :c]) <: AbstractGraph

persons = ["Loid","Yor","Van","Trisha","Gendo","Yui","Anya","Alphonse","Ed","Shinji","Rei"]
Families = FamilyData{String}()

add_parts!(Families, :V, length(persons), name=persons)
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

# what if we just want to get all pairs of people, without 
# regard to the relationship between them?

pairs_query = @relation (p1=p1name,p2=p2name) begin
    V(_id=p1, name=p1name)
    V(_id=p2, name=p2name)
end

query(Families, pairs_query)
size(query(Families, pairs_query),1) == nv(Families)^2

# ----------------------------------------------------------------------
# what about data migration?
@present SimpleFamilySch(FreeSchema) begin
    Person::Ob
    child::Hom(Person,Person)
    String::AttrType
    name::Attr(Person,String)
end

@acset_type SimpleFamilyData(SimpleFamilySch, index=[:child])

V1, E1, src1, tgt1, NameType1, name1 = generators(FamilySch)
Person2, child2, String2, name2 = generators(SimpleFamilySch)

F = FinFunctor(
    Dict(V1 => Person2, E1 => Person2, NameType1 => String2),
    Dict(src1 => id(Person2), tgt1 => child2, name1 => name2),
    # Dict(src1 => child2, tgt1 => id(Person2), name1 => name2),
    FamilySch, SimpleFamilySch
)

Σ = SigmaMigrationFunctor(F, FamilyData{String}, SimpleFamilyData{String})

Σ(Families)



SimpleFamilies = @acset SimpleFamilyData{String} begin
    Person = 2
    name = ["parent","kid"]
    child=[2,2]
end


Δ = DataMigrationFunctor(F, SimpleFamilyData{String}, FamilyData{String})
Δ(SimpleFamilies)
