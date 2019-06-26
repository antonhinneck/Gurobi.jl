# Test MIP
#
#   maximize z
#
#   s.t.  3 p1 + 5 p2 + 4 p3 - z = 0
#         0.5 p1 + 2 p2 + 1 p3 <= 6
#
#         p1 is integer: 0 <= p1
#         p1 is integer: 0 <= p2
#         p1 is integer: 0 <= p3
#         z is binary

using Gurobi, Test

@testset "constr_matrix" begin

    simple_model_env = Gurobi.Env()
    setparam!(simple_model_env, "OutputFlag", 0)

    simple_model = Gurobi.Model(simple_model_env, "simple_mip", :maximize)

    add_ivar!(simple_model, 0.0, 0.0, Inf)  # p1
    add_ivar!(simple_model, 0.0, 0.0, Inf)  # p2
    add_ivar!(simple_model, 0.0, 0.0, Inf)  # p3
    add_cvar!(simple_model, 1.0, 0.0, Inf)  # z

    update_model!(simple_model)

    add_constr!(simple_model, [3.0, 5.0, 4.0, -1.0], '<', 0.0)
    add_constr!(simple_model, [0.5, 2.0, 1.0,  0.0], '<', 6.0)
    add_constr!(simple_model, [3.0, 5.0, 4.0, -1.0], '>', 0.0)

    update_model!(simple_model)

    @test [Gurobi.get_vars(simple_model, 1, num_vars(simple_model))[:, 1]...] == [ 3.0, 0.5,  3.0]
    @test [Gurobi.get_vars(simple_model, 1, num_vars(simple_model))[:, 2]...] == [ 5.0, 2.0,  5.0]
    @test [Gurobi.get_vars(simple_model, 1, num_vars(simple_model))[:, 3]...] == [ 4.0, 1.0,  4.0]
    @test [Gurobi.get_vars(simple_model, 1, num_vars(simple_model))[:, 4]...] == [-1.0, 0.0, -1.0]

    @test [Gurobi.get_constrs(simple_model, 1, num_constrs(simple_model))[1, :]...] == [3.0, 5.0, 4.0, -1.0]
    @test [Gurobi.get_constrs(simple_model, 1, num_constrs(simple_model))[2, :]...] == [0.5, 2.0, 1.0,  0.0]
    @test [Gurobi.get_constrs(simple_model, 1, num_constrs(simple_model))[3, :]...] == [3.0, 5.0, 4.0, -1.0]

    @test [Gurobi.get_constrs(simple_model, 2, 2)[2, :]...][2] == [Gurobi.get_vars(simple_model, 2, 2)[:, 2]...][2]
    @test Gurobi.get_constrs(simple_model, 2, 2)[3, :][4] == Gurobi.get_vars(simple_model, 3, 2)[:, 4][3]
    @test Gurobi.get_constrs(simple_model, 1, num_constrs(simple_model)) == Gurobi.get_vars(simple_model, 1, num_vars(simple_model))

end