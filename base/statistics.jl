# This file is a part of Julia. License is MIT: https://julialang.org/license

##### mean #####

"""
    mean(f::Function, v)

Apply the function `f` to each element of `v` and take the mean.

```jldoctest
julia> mean(√, [1, 2, 3])
1.3820881233139908

julia> mean([√1, √2, √3])
1.3820881233139908
```
"""
function mean(f::Callable, iterable)
    y = iterate(iterable)
    if y == nothing
        throw(ArgumentError("mean of empty collection undefined: $(repr(iterable))"))
    end
    count = 1
    value, state = y
    f_value = f(value)
    total = reduce_first(add_sum, f_value)
    y = iterate(iterable, state)
    while y !== nothing
        value, state = y
        total += f(value)
        count += 1
        y = iterate(iterable, state)
    end
    return total/count
end
mean(iterable) = mean(identity, iterable)
mean(f::Callable, A::AbstractArray) = sum(f, A) / _length(A)

"""
    mean!(r, v)

Compute the mean of `v` over the singleton dimensions of `r`, and write results to `r`.

# Examples
```jldoctest
julia> v = [1 2; 3 4]
2×2 Array{Int64,2}:
 1  2
 3  4

julia> mean!([1., 1.], v)
2-element Array{Float64,1}:
 1.5
 3.5

julia> mean!([1. 1.], v)
1×2 Array{Float64,2}:
 2.0  3.0
```
"""
function mean!(R::AbstractArray, A::AbstractArray)
    sum!(R, A; init=true)
    x = max(1, _length(R)) // _length(A)
    R .= R .* x
    return R
end

"""
    mean(v; dims)

Compute the mean of whole array `v`, or optionally along the given dimensions.

!!! note
    Julia does not ignore `NaN` values in the computation. Use the [`missing`](@ref) type
    to represent missing values, and the [`skipmissing`](@ref) function to omit them.
"""
mean(A::AbstractArray; dims=:) = _mean(A, dims)

_mean(A::AbstractArray{T}, region) where {T} = mean!(reducedim_init(t -> t/2, +, A, region), A)
_mean(A::AbstractArray, ::Colon) = sum(A) / _length(A)
