# Alcubierre drive simulation

using GLMakie, ForwardDiff

N = 100
d = range(-1,1,N)
θ = Observable(zeros(100,100))
T00 = Observable(zeros(100,100))

fig = Figure()
ax  = Axis3(fig[1,1],azimuth=π/4,elevation=π/10,zlabel="θ",title="Alcubierre-meghajtás")
wireframe!(ax,d,d,θ,linewidth=0.5,color=:steelblue1)
cnt = contour!(ax,d,d,T00,levels=15,transformation=(:xy,-10),colorrange=(-2.,2.),colormap=:bwr)
cb  = Colorbar(fig[1, 2], cnt, label="Energiasűrűség")
xlims!(ax,-1,1)
ylims!(ax,-1,1)
zlims!(ax,-10,10)

lsgrid = labelslidergrid!(
    fig,
    ["v","R","σ"],
    [0:0.01:5, 0:0.01:10, 0:0.01:20])
fig[2,1] = lsgrid.layout
v,R,σ = [s.value for s in lsgrid.sliders]

scr = display(fig)
@async begin
    y₀ = -2.5
    while isopen(scr)
        f(r)  = (tanh(σ[]*r+R[]) - tanh(σ[]*r-R[]))/2tanh(σ[]*R[])
        r     = @. sqrt(d^2 + (d-y₀)'^2)
        dfr   = ForwardDiff.derivative.(f,r)
        θ[]   = @. v[] * (d-y₀)' / r * dfr
        T00[] = @. -v[]^2/32π*(d^2)/r^2 * dfr^2

        y₀ += v[] / 100
        if y₀>2.5
            y₀ = -2.5
        end
        sleep(0.01)
    end
end