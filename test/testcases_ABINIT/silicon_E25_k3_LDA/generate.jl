include("../../testcases.jl")
using DFTK

abinitpseudos = [joinpath(@__DIR__, "Si-q4-pade.abinit.hgh")]
pspmap = Dict(14 => "hgh/lda/si-q4", )

atoms = [Element(14, load_psp(pspmap[14])) => silicon.positions]
model = model_dft(silicon.lattice, [:lda_x, :lda_c_vwn], atoms)

DFTK.run_abinit_scf(model, @__DIR__;
                    abinitpseudos=abinitpseudos, pspmap=pspmap,
                    Ecut=25, kgrid=[3, 3, 3], n_bands=10, tol=1e-10,
                    iscf=3) # Use Anderson mixing instead of minimisation
