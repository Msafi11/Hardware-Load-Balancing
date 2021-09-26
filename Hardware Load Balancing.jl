import Pkg
Pkg.add("JuMP")
Pkg.add("GLPK")
function asknumber(string)
    print(string)
    parse(Int, readline())
end
n = asknumber("Enter number Of tasks : ")
N = asknumber("Enter number Of machines : ")
max = asknumber("Enter max hours for all machines : ")
LT=Vector(1:n)
for i in 1:n
    LT[i] = asknumber("length of task $i")  
end
PM=Vector(1:N)
for j in 1:N
    PM[j] = asknumber("processing speed of virtual machine $j") 
end
using GLPK , JuMP, LinearAlgebra
model = Model(GLPK.Optimizer)
@variable(model,x[i=1:n,j=1:N],Bin)
ETC = zeros((n, N))
for i in 1:n
    for j in 1:N
        ETC[i,j] = LT[i] / PM[j]
    end
end
@constraint(model,con1[c=1:N],sum(x[i,c] for i in 1:n)   >= 1 )
@constraint(model,con2[c=1:n],sum(x[c,j] for j in 1:N)   == 1 )
@constraint(model,con3[c=1:N],sum(x[i,c]*ETC[i,c] for i in 1:n)   <= max )
@objective(model,Max,sum(sum(((x[i,j]*ETC[i,j])/10)*100 for i in 1:n) / N for j in 1:N) )
println("----------------------hardware Load Balance problem------------------------------")
println(model)
optimize!(model)
println("Avg utilization of hardware all virtual machines = ",objective_value(model),"%")
for i in 1:n
    for j in 1:N
        if(value(x[i,j])) == 1
            print("Task $i assigned to machine $j -- ")
        end
    end    
end
println("--------------------- ")
for M in 1:N
    print("Machine $M Utlizatrion rate = ",sum((value(x[i,M])*ETC[i,M])/10*100 for i in 1:n),"% -- ")
end



