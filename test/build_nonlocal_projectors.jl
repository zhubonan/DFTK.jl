using Test
using DFTK: PlaneWaveBasis, build_nonlocal_projectors, apply_fourier!, load_psp, Species

include("silicon_testcases.jl")


@testset "build_nonlocal_projectors" begin
    Ecut = 2
    grid_size = [9, 9, 9]
    pw = PlaneWaveBasis(lattice, grid_size, Ecut, kpoints, kweights)

    psp = load_psp("Si-lda-q4.hgh")
    potnl = build_nonlocal_projectors(pw, psp => positions)

    @testset "Agreement of psp and species construction" begin
        silicon = Species(14, psp=psp)
        potnl2 = build_nonlocal_projectors(pw, silicon => positions)

        @test potnl.proj_vectors ≈ potnl2.proj_vectors
        @test potnl.proj_coeffs ≈ potnl2.proj_coeffs
    end

    @testset "Dummy application test for ik == 3" begin
        ik = 3
        in = [
              -0.8549534855488266 - 0.6754549998607065im,
              0.08443727988059929 - 0.9179821254886141im,
              -0.6692401238573114 - 0.46622195170365105im,
               1.5034562862871756 - 0.24044592102546036im,
              0.14524553046329444 + 1.0428814872854042im,
             -0.11626625719060898 + 0.4589708223124379im,
              0.19005048925209195 - 0.6120250843080458im,
               0.2801461126228527 + 0.6945870843856323im,
             -0.15671249035623983 + 0.2931067999407425im,
              -0.2767744878834321 + 1.0817652476336819im,
               1.0807543369571682 - 2.1119318793419297im,
              -0.5394787663743157 + 0.6051301125381743im,
                0.976083612807345 - 0.38332420456349436im,
               1.1352364565129534 - 0.8820865851221369im,
               1.1793089625149973 - 0.9607716455035641im,
              -0.9048735579085041 + 0.885060907911802im ,
              -0.5675180361384465 - 0.5042161723956138im,
               1.3951429113077436 + 1.0413417433606904im,
              -0.0839664948784019 - 0.22985781260723534im,
              0.49440538159011094 + 0.2872884886381994im,
              -1.0015758977998883 + 0.8700828150833414im,
              -0.6404005621426346 + 0.8985670006411672im,
              -1.1080145478182368 - 0.8859534758159319im,
              -0.8527343504913281 - 0.19386173405091806im ,
             -0.21163136072648456 - 0.6329876224003373im,
             -0.41156758426720946 - 0.450748133246067im ,
             -0.18503655169354724 + 0.7114439142378545im,
               1.4354360261905414 + 0.5001251095185011im,
              -1.5987497919352283 - 0.9381588130406086im,
              -0.8528718001444584 - 0.62607350767617im  ,
              -0.4248160710509159 - 0.11190003224943382im,
               0.3929362667346896 - 0.29942221197859925im,
               0.6583912267714727 + 0.18753920533770518im,
              0.36235537336175694 + 0.3392799957105248im,
              -1.3133010957592426 + 0.5765590537853099im,
              -0.8736257421252681 - 0.752328949884127im ,
               0.5265322745436715 + 0.8652987233629306im,
              -0.6463507454685288 - 0.001697619931693731im,
               0.7272186609622812 + 0.8327381012657087im,
        ]

        ref = [
               -0.664819375385888 - 0.42715795522129807im,
             -0.22367530788412238 - 0.4010629448935139im ,
             -0.04241948181614172 - 0.3963689644755802im ,
               0.5183638171939322 - 0.10954370863880752im,
             -0.16980139195461233 - 0.34754415560672214im,
                0.509774368280433 - 0.0434979859180724im ,
                0.900231055058197 + 0.32200191150842783im,
               0.5666743927856103 - 0.08227618954429268im,
                1.129738824134614 + 0.39662612272765246im,
               1.0030802679198636 + 0.6119982862158371im ,
               0.6707482944162675 + 0.22195280443603216im,
               0.7345867695288981 + 0.5623641332878373im ,
              0.19795324749271098 + 0.44210035552155685im,
               0.9097135451116255 + 0.3124217943456289im ,
                0.879579672156741 + 0.4142617254720654im ,
                0.780704714350115 + 0.2561769666904372im ,
               0.9587537248285127 + 0.5477372946652714im ,
              0.37647864222667266 + 0.3720690454590351im ,
               -0.409471315232126 - 0.09323178075765504im,
              0.45479872281680334 + 0.3357360154388991im ,
              0.11885240995286525 + 0.36539730135197535im,
               -0.661458540029646 - 0.08279459143447063im,
               -1.075625664669056 - 0.5033759491163926im ,
              -0.5106858958694792 - 0.02425255531741567im,
              -0.9305753056053774 - 0.4401373909595327im ,
              -0.7890104544679222 - 0.5519892357210223im ,
              0.21472368866414832 + 0.1823365197292422im ,
             -0.44424171577325855 - 0.14571330056776707im,
              -0.8635795357201779 - 0.3962474517293677im ,
              -0.5011417402784359 - 0.10693509694154678im,
              -1.0776445381797832 - 0.5021543101806742im ,
              -1.0060760794195054 - 0.546061359602692im  ,
              -0.6340967750782484 - 0.29619834465697203im,
              -0.7375825810285398 - 0.4964272066746922im ,
             -0.24846138115473135 - 0.25635007189648124im,
              -0.6695590195876564 - 0.3228397856896666im ,
             -0.30358373432616614 - 0.10718922991987309im,
             -0.12232790825818542 - 0.10249524950193939im,
              0.40179339390767305 + 0.22702804471387822im,
        ]
        out = apply_fourier!(similar(in), potnl, ik, in)
        @test ref ≈ out
    end

    @testset "Dummy application test for ik == 1" begin
        ik = 1
        in = [
               0.7017297388223512 - 0.7826070022669703im  ,
              0.06339594485076916 - 0.5929467146496347im  ,
               0.3032766467183882 + 0.8125169845817773im  ,
             -0.24144666678041285 + 0.7642993874185992im  ,
               1.6867012582758985 - 0.3654627737441829im  ,
               1.4545721686585582 - 0.45155570175843623im ,
              -0.7831528410079455 + 0.1514804845552008im  ,
              -2.1912191123696263 + 0.6062006684061534im  ,
              -1.4806546306689128 - 0.22025010176789186im ,
               0.6880193278597426 + 0.2463453031138734im  ,
               1.5151668301386074 - 0.7029366326124846im  ,
               0.7293099597156973 - 0.7473481043576276im  ,
              -0.7647342553925818 + 0.11948132010194444im ,
             -0.24994218637103446 + 0.10688281799606457im ,
               0.9404984362006743 + 1.981742589455308im   ,
               0.5765770802183872 - 0.15118021331492618im ,
            -0.016471951537286023 - 1.3418887759185198im  ,
               0.1700237292909708 - 0.1693698983031606im  ,
             -0.44796187917307817 + 1.0086281074180616im  ,
              -0.2741149631592716 - 0.7143946881230608im  ,
              0.05130506184334053 + 0.8946511101439446im  ,
              0.15570677341053432 + 2.3871032610466156im  ,
             -0.07082495615824523 + 0.11877232594799357im ,
             -0.17829305646126437 - 0.9949712615178385im  ,
               0.6838856273217268 + 0.029449088646683535im,
             -0.08830487875687248 + 0.9775300495325595im  ,
              -0.2352090982302754 + 0.2540425031176507im  ,
        ]

        ref = [
               0.6133328162061066 - 0.07557221618792875im ,
               0.3643834686198163 - 0.15704159184306143im ,
               0.4262258642316722 + 0.05314211987426799im ,
               0.8262323849296159 - 0.3974311954276329im  ,
               0.5527186669918225 - 0.589583658630485im   ,
               0.5030586478499197 - 0.32460078913775997im ,
             -0.15395204948008212 - 0.27086678745834364im ,
              -0.6129937532899972 + 0.17770067298268888im ,
               -0.674836148901853 - 0.03248303873464051im ,
               0.5483128026985405 - 0.5338533485487785im  ,
              0.09878202242649586 - 0.35371323396307724im ,
              -0.3640444057037067 + 0.2591700486378215im  ,
             0.007613063892833595 - 0.3430720093130262im  ,
              -0.6112308394339017 + 0.07314976233823367im ,
              -0.7405340249971477 + 0.614096798136806im   ,
              -0.4877291969274186 - 0.16119737479683727im ,
              -0.7583176717226714 + 0.23315842137807213im ,
              -0.3874783010366327 + 0.49607954242178065im ,
             -0.17693745372927241 + 0.13045571257562477im ,
             -0.23877984934112845 - 0.0797279991417046im  ,
              -0.5724581262775139 + 0.4595358653263186im  ,
              -0.4327324558852535 + 0.7053321018327992im  ,
             -0.38307243674335084 + 0.44034923234007417im ,
              0.07748794227137562 + 0.37980988883490224im ,
              0.42554773839945315 - 0.15111479371525227im ,
               0.4873901340113091 + 0.059068918002077114im,
              0.23844078642501887 - 0.02240045765305552im ,

        ]
        out = apply_fourier!(similar(in), potnl, ik, in)
        @test ref ≈ out
    end
end
