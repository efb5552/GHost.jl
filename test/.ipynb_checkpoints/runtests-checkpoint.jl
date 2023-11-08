using GHost
using Test
using DataFrames

n_test = 10 #number of particles to test
num_steps_test = 1 # number of steps
M_planet_test = big(10.)^26
R_planet_test = 2*big(10.)^7

m_test = GHost.create_masses(n_test,10^(-20),10^(-10))
R_test,V_test = GHost.initial_conditions(m_test,2,3,M_planet_test,R_planet_test)
A_test = GHost.acceleration(m_test,R_test,M_planet_test,R_planet_test)
x_new = GHost.position_change(1,R_test,V_test,A_test,0.0001)
y_new = GHost.position_change(2,R_test,V_test,A_test,0.0001)
Vx_new = GHost.velocity_change(1,V_test,A_test,0.0001)
Vy_new = GHost.velocity_change(2,V_test,A_test,0.0001)
R_new, V_new = GHost.move_particle(m_test,R_test,V_test,0.0001,M_planet_test,R_planet_test)
orbits_test = GHost.orbit_matrix(m_test,R_test,V_test,num_steps_test,0.0001,M_planet_test,R_planet_test)

@testset "Pythagoras.jl Test" begin
	@test GHost.pythagoras(1,1) == sqrt(2)
	@test GHost.pythagoras(sqrt(2),sqrt(2)) == 2
	@test GHost.pythagoras([1 2 3],[1 2 3]) isa Array
	@test length(GHost.pythagoras([1 2 3],[1 2 3])) == 3
end;

@testset "create_masses.jl Test" begin
	@test m_test isa Vector # output is a vector 
	@test length(m_test) == n_test # vector has correct length
	@test log(maximum(m_test)) - log(minimum(m_test)) < 16 # dynamic range  
end;

@testset "initial_conidtions.jl Test" begin
    @test size(R_test)[1] == size(V_test)[1] == n_test # same length = n
	@test size(R_test)[2] == size(V_test)[2] == 2 # x and y dimensions
	@test minimum(GHost.pythagoras(R_test[:,1],R_test[:,2])) > 1. # no particle starting inside planet
	@test maximum(GHost.pythagoras(V_test[:,1],V_test[:,2])) < 100 # reasonable initial velocity (V_initial == 1)
end;

@testset "acceleration.jl Test" begin
    @test A_test isa Matrix
	@test size(A_test)[1] == size(R_test)[1] == size(V_test)[1] == n_test
	@test size(A_test)[2] == size(R_test)[2] == size(V_test)[2] == 2
	@test maximum(GHost.pythagoras(A_test[:,1],A_test[:,2])) < 2000 # no super large initial accelerations
end;

@testset "position_change.jl Test" begin
    @test maximum(abs.(GHost.pythagoras(x_new,y_new) .- GHost.pythagoras(R_test[:,1],R_test[:,2]))) < 1 # no super big displacements over a small period of time
	@test length(x_new) == length(y_new) == size(R_test)[1] == size(V_test)[1] == size(A_test)[1] == n_test
end;

@testset "velocity_change.jl Test" begin
    @test maximum(abs.(GHost.pythagoras(Vx_new,Vy_new) .- GHost.pythagoras(V_test[:,1],V_test[:,2]))) < 1 # no super big changes in velocity in a small period of time
	@test length(Vx_new) == length(Vy_new) == size(V_test)[1] == size(A_test)[1] == n_test
end;

@testset "move_particle.jl Test" begin
    @test GHost.move_particle([1e-15],[0.25 0.25],[1 1],
		0.0001,M_planet_test,R_planet_test)[1] == [0 0] # if particle inside planet it is moved to center of planet
	@test GHost.move_particle([1e-15],[0.25 0.25],[1 1],
		0.0001,M_planet_test,R_planet_test)[2] == [0 0] # if particle inside planet velocity is now 0
	@test size(R_new) == size(V_new) == size(A_test) == size(R_test) == size(V_test)
end;

@testset "orbit_matrix.jl Test" begin
    @test orbits_test isa DataFrames.DataFrame
	@test size(orbits_test)[1] == n_test
	@test size(orbits_test)[2] == 4*(num_steps_test + 1)
end;

@testset "Parallel v. Serial Comparisons" begin
    A_serial = A_test
    A_parallel_shared = GHost.acceleration(m_test,R_test,M_planet_test,R_planet_test,true,"Shared")
    A_parallel_dist = GHost.acceleration(m_test,R_test,M_planet_test,R_planet_test,true,"Distributed")
    @test isapprox(A_serial,A_parallel_shared,atol=0.001)
    @test isapprox(A_serial,A_parallel_dist,atol=0.001)
    @test isapprox(A_parallel_shared,A_parallel_dist,atol=0.001)
end;