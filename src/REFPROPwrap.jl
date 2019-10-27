module REFPROPwrap
"""
Initializing by calling the SETUPdll with required fluid name

currently support only pure fluids with one component
"""
function refprop_init(fluid::String)
    ncmax = Ref{Cint}(2)
    refpropcharlength  = Ref{Cint}(255)
    filepathlength  = Ref{Cint}(255)
    lengthofreference = Ref{Cint}(3)
    errormessagelength =  Ref{Cint}(255)
    hfld_length = Ref{Cint}(refpropcharlength[]*ncmax[])
    hf = Array{UInt8}(undef,refpropcharlength[]*ncmax[])
    hrf = Array{UInt8}(undef, lengthofreference[])
    herr = Array{UInt8}(undef, errormessagelength[])
    hfmix = Array{UInt8}(undef,refpropcharlength[])
    hf_name = "/home/aaditya/Desktop/julia/REFPROP/FLUIDS/"*fluid*".FLD\0"
    hfmix_name = "/home/aaditya/Desktop/julia/REFPROP/FLUIDS/HMX.BNC"
    hrf_name = "DEF"
    herr_name = "Ok"
    hf[1:length(hf_name)] = collect(hf_name)
    hfmix[1:length(hfmix_name)] = collect(hfmix_name)
    hrf[1:length(hrf_name)] = collect(hrf_name)
    herr[1:length(herr_name)] = collect(herr_name)
    i = Ref{Cint}(1)
    ierr = Ref{Cint}(0)
    ccall((:SETUPdll,"/home/aaditya/Desktop/julia/librefprop.so"),Cvoid,(Ref{Cint},Ptr{UInt8},Ptr{UInt8},Ptr{UInt8},Ref{Cint},Ptr{UInt8},Ref{Cint},Ref{Cint},Ref{Cint},Ref{Cint}), i, hf, hfmix, hrf, ierr, herr, hfld_length, refpropcharlength, lengthofreference, errormessagelength)
    return String(herr)
end
"""
sample function to call the properties using pressure and enthalpy as the inputs
"""
function refprop_call(pre::Float64, enthal::Float64)
    #initializing the arrays and variables
    ncmax = Ref{Cint}(2)
    ierr = Ref{Cint}(0)
    herr = Array{UInt8}(undef, 255)

    x = Array{Cdouble}(zeros(ncmax[])); xliq = Array{Cdouble}(zeros(ncmax[])); xvap = Array{Cdouble}(zeros(ncmax[])); f = Array{Cdouble}(zeros(ncmax[]));

    wm = Ref{Cdouble}(0)
    vs = Ref{Cdouble}(0)
    ccall((:WMOLdll,"/home/aaditya/Desktop/julia/librefprop.so"), Cvoid, (Ptr{Cdouble}, Ref{Cdouble}), x, wm)
    p = Ref{Cdouble}(pre)
    e = Ref{Cdouble}(0)
    h = Ref{Cdouble}(enthal*wm[]/1000.0)
    s = Ref{Cdouble}(0)
    cv = Ref{Cdouble}(0)
    cp = Ref{Cdouble}(0)
    hjt = Ref{Cdouble}(0)
    temp = Ref{Cdouble}(0)
    rhop = Ref{Cdouble}(0) #(rho/wm[])
    rhol = Ref{Cdouble}(0)
    rhov = Ref{Cdouble}(0)
    qual = Ref{Cdouble}(0)


    #ccall((:THERMdll,"/home/aaditya/Desktop/julia/librefprop.so"),Cvoid,(Ref{Cdouble}, Ref{Cdouble},Ptr{Cdouble},Ref{Cdouble},Ref{Cdouble},Ref{Cdouble},Ref{Cdouble},Ref{Cdouble},Ref{Cdouble},Ref{Cdouble},Ref{Cdouble}), temp, rhop, x, p, e, h, s, cv, cp, vs, hjt);
    ccall((:PHFLSHdll,"/home/aaditya/Desktop/julia/librefprop.so"),Cvoid,(Ref{Cdouble}, Ref{Cdouble}, Ptr{Cdouble}, Ref{Cdouble}, Ref{Cdouble}, Ref{Cdouble}, Ref{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ref{Cdouble}, Ref{Cdouble}, Ref{Cdouble}, Ref{Cdouble}, Ref{Cdouble}, Ref{Cdouble}, Ref{Cint}, Ptr{UInt8}), p,h,x,temp,rhop,rhol,rhov,xliq,xvap,qual,e,s,cv,cp,vs,ierr,herr);

    return p[], h[]/wm[]*1000.0, temp[], rhop[]*wm[], rhol[]*wm[], rhov[]*wm[], qual[],  e[]/wm[]*1000.0, s[]/wm[]*1000.0, cv[]/wm[]*1000.0, cp[]/wm[]*1000.0, vs[]
end # module
