using Test
using LinearAlgebra
using DFTK: load_psp, eval_psp_projector_fourier, eval_psp_local_fourier
using DFTK: eval_psp_projector_real, psp_local_polynomial, eval_psp_local_real
using DFTK: psp_projector_polynomial, qcut_psp_projector, qcut_psp_local
using DFTK: eval_psp_energy_correction, count_n_proj_radial
using SpecialFunctions: besselj
using QuadGK


@testset "Check reading 'C-lda-q4'" begin
    psp = load_psp("hgh/lda/C-q4")

    @test psp.identifier == "hgh/lda/c-q4"
    @test occursin("c", lowercase(psp.description))
    @test occursin("pade", lowercase(psp.description))
    @test psp.Zion == 4
    @test psp.rloc == 0.34883045
    @test psp.cloc == [-8.51377110, 1.22843203, 0, 0]
    @test psp.lmax == 1
    @test psp.rp == [0.30455321, 0.2326773]
    @test psp.h[1] == 9.52284179 * ones(1, 1)
    @test psp.h[2] == zeros(0, 0)
end

@testset "Check reading 'Ni-lda-q18'" begin
    psp = load_psp("hgh/lda/Ni-q18")

    @test psp.identifier == "hgh/lda/ni-q18"
    @test occursin("ni", lowercase(psp.description))
    @test occursin("pade", lowercase(psp.description))
    @test psp.Zion == 18
    @test psp.rloc == 0.35000000
    @test psp.cloc == [3.61031072, 0.44963832, 0, 0]
    @test psp.lmax == 2
    @test psp.rp == [0.24510489, 0.23474136, 0.21494950]
    @test psp.h[1] == [[12.16113071, 3.51625420] [3.51625420, -9.07892931]]
    @test psp.h[2] == [[-0.82062357, 2.54774737] [2.54774737, -6.02907069]]
    @test psp.h[3] == -13.39506212 * ones(1, 1)
end

@testset "Check evaluating 'Si-lda-q4'" begin
    psp = load_psp("hgh/lda/Si-q4")

    # Test local part evaluation
    @test eval_psp_local_fourier(psp, norm([0.1,   0,    0])) ≈ -400.395448865164*4π
    @test eval_psp_local_fourier(psp, norm([0.1, 0.2,    0])) ≈ -80.39317320182417*4π
    @test eval_psp_local_fourier(psp, norm([0.1, 0.2, -0.3])) ≈ -28.95951714682582*4π
    @test eval_psp_local_fourier(psp, norm([1.0, -2.0, 3.0])) ≈ -0.275673388844235*4π
    @test eval_psp_local_fourier(psp, norm([10.0, 0.0, 0.0])) ≈ -5.1468909215285576e-5*4π

    # Test nonlocal part evaluation
    qsq = [0, 0.01, 0.1, 0.3, 1, 10]
    qnorms = sqrt.([0, 0.01, 0.1, 0.3, 1, 10])
    @test map(q -> eval_psp_projector_fourier(psp, 1, 0, q), qnorms) ≈ [
        6.503085484692629, 6.497277328372439, 6.445236803354619,
        6.331078654802208, 5.947214691896995, 2.661098803299718,
    ]
    @test map(q -> eval_psp_projector_fourier(psp, 2, 0, q), qnorms) ≈ [
        10.074536712471094, 10.059542796942894, 9.925438587886482,
        9.632787375976731, 8.664551612201326, 1.666783598475508
    ]
    @test map(q -> eval_psp_projector_fourier(psp, 3, 0, q), qnorms) ≈ [
        12.692723197804167, 12.666281142268161, 12.430208137727789,
        11.917710279480355, 10.249557409656868, 0.11180299205602792
    ]

    @test map(q -> eval_psp_projector_fourier(psp, 1, 1, q), qnorms) ≈ [
        0.0, 0.3149163627204332, 0.9853983576555614,
        1.667197861646941, 2.8039993470553535, 3.0863036233824626,
    ]
    @test map(q -> eval_psp_projector_fourier(psp, 2, 1, q), qnorms) ≈ [
        0.0, 0.5320561290084422, 1.657814585041487,
        2.778424038171201, 4.517311337690638, 2.7698566262467117,
    ]

    @test map(q -> eval_psp_projector_fourier(psp, 3, 1, q), qnorms) ≈ [
         0.0, 0.7482799478933317, 2.321676914155303,
         3.8541542745249706, 6.053770711942623, 1.6078748819430986,
    ]


end

@testset "Check qcut routines" begin
    psp = load_psp("hgh/pbe/au-q11.hgh")
    ε = 1e-6

    qcut = qcut_psp_local(psp)
    res = eval_psp_local_fourier.(psp, [qcut - ε, qcut, qcut + ε])
    @test (res[1] < res[2]) == (res[3] < res[2])

    for i in 1:2, l in 0:2
        qcut = qcut_psp_projector(psp, i, l)
        res = eval_psp_projector_fourier.(psp, i, l, [qcut - ε, qcut, qcut + ε])
        @test (res[1] < res[2]) == (res[3] < res[2])
    end
end

@testset "Agreement of polynomial implementation and eval functions" begin
    psp = load_psp("hgh/lda/Si-q4")
    Qloc = psp_local_polynomial(Float64, psp)
    evalQloc(q) = let t = q * psp.rloc; Qloc(t) * exp(-t^2 / 2) / t^2; end
    for q in abs.(randn(10))
        @test evalQloc(q) ≈ eval_psp_local_fourier(psp, q)
    end

    for pspfile in ["Au-q11", "Ba-q10"]
        psp = load_psp("hgh/lda/" * pspfile)
        for l = 0:psp.lmax, i = 1:count_n_proj_radial(psp, l)
            Qproj = psp_projector_polynomial(Float64, psp, i, l)
            evalQproj(q) = let t = q * psp.rp[l + 1]; Qproj(t) * exp(-t^2 / 2); end
            for q in abs.(randn(10))
                @test evalQproj(q) ≈ eval_psp_projector_fourier(psp, i, l, q)
            end
        end
    end
end

@testset "Projectors are consistent in real and Fourier space" begin
    # The spherical bessel function of the first kind in terms of ordinary bessels:
    function j(n, x::T) where {T}
        x == 0 ? zero(T) : sqrt(π/2x) * besselj(n+1/2, x)
    end

    # The integrand for performing the spherical Hankel transfrom,
    # i.e. compute the radial part of the projector in Fourier space
    function integrand(psp, i, l, q, x)
        4π * x^2 * eval_psp_projector_real(psp, i, l, x) * j(l, q*x)
    end

    for pspfile in ["Au-q11", "Ba-q10"]
        psp = load_psp("hgh/lda/" * pspfile)
        for l = 0:psp.lmax, i = 1:count_n_proj_radial(psp, l)
            for q in [0.01, 0.1, 0.2, 0.5, 1, 2, 5, 10]
                reference = quadgk(r -> integrand(psp, i, l, q, r), 0, Inf)[1]
                @test reference ≈ eval_psp_projector_fourier(psp, i, l, q) atol=5e-15 rtol=1e-8
            end
        end
    end
end

@testset "Potentials are consistent in real and Fourier space" begin
    reg_param = 1e-3  # divergent integral, needs regularization
    function integrand(psp, q, r)
        4π * eval_psp_local_real(psp, r) * exp(-reg_param * r) * sin(q*r) / q * r
    end

    for pspfile in ["Au-q11", "Ba-q10"]
        psp = load_psp("hgh/lda/" * pspfile)
        for q in [0.01, 0.2, 1, 1.3]
            reference = quadgk(r -> integrand(psp, q, r), 0, Inf)[1]
            @test reference ≈ eval_psp_local_fourier(psp, q) rtol=.1 atol = .1
        end
    end
end

@testset "PSP energy correction is consistent with real-space potential" begin
    reg_param = 1e-6  # divergent integral, needs regularization
    q_small = 1e-6    # We are interested in q→0 term
    function integrand(psp, n_electrons, r)
        # Difference of potential of point-like atom (what is assumed in Ewald)
        # versus actual structure of the pseudo potential
        coulomb = -psp.Zion / r
        diff = n_electrons * (eval_psp_local_real(psp, r) - coulomb)
        4π * diff * exp(-reg_param * r) * sin(q_small*r) / q_small * r
    end

    n_electrons = 20
    for pspfile in ["Au-q11", "Ba-q10"]
        psp = load_psp("hgh/lda/" * pspfile)
        reference = quadgk(r -> integrand(psp, n_electrons, r), 0, Inf)[1]
        @test reference ≈ eval_psp_energy_correction(psp, n_electrons) atol=1e-2
    end
end

@testset "PSP energy correction is consistent with fourier-space potential" begin
    q_small = 1e-3    # We are interested in q→0 term
    for pspfile in ["Au-q11", "Ba-q10"]
        psp = load_psp("hgh/lda/" * pspfile)
        coulomb = -4π * psp.Zion / q_small^2
        reference = eval_psp_local_fourier(psp, q_small) - coulomb
        @test reference ≈ eval_psp_energy_correction(psp, 1) atol=1e-3
    end
end
