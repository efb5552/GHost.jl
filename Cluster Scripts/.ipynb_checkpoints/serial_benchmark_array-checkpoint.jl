include("benchmark.jl")

n = [10,100,1000]
t = [100,100,100]
m = [1e8,1e8,1e8]
r = [1e5,1e5,1e5]

for i in eachindex(n)
    @inbounds benchmark(n[i],t[i],m[i],r[i])
end