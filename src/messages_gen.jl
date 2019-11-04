# Convenience functions

# The following methods are generated by the first macro:
# forward(a, A, L)               -> α, logtot
# forward(hmm, observation)      -> α, logtot
# forwardlog(a, A, LL)           -> α, logtot
# forwardlog(hmm, observations)  -> α, logtot
#
# backward(a, A, L)              -> β, logtot
# backward(hmm, observations)    -> β, logtot
# backwardlog(a, A, LL)          -> β, logtot
# backwardlog(hmm, observations) -> β, logtot

# The following methods are also defined:
# posteriors(α, β)                 -> γ
# posteriors(a, A, L)              -> γ
# posteriors(hmm, observations)    -> γ
# posteriorslog(a, a, LL)          -> γ
# posteriorslog(hmm, observations) -> γ

# Forward/Backward

for f in (:forward, :backward)
    f!  = Symbol("$(f)!")   # forward!
    fl  = Symbol("$(f)log") # forwardlog
    fl! = Symbol("$(fl)!")  # forwardlog!
    @eval begin
        # [forward,backward](a, A, L)
        """
            $($f)(a, A, L)

        Compute $($f) probabilities using samples likelihoods.
        See [Forward-backward algorithm](https://en.wikipedia.org/wiki/Forward–backward_algorithm).
        """
        function $(f)(a::AbstractVector, A::AbstractMatrix, L::AbstractMatrix)
            m = Matrix{Float64}(undef, size(L))
            c = Vector{Float64}(undef, size(L)[1])
            $(f!)(m, c, a, A, L)
            m, sum(log.(c))
        end

        # [forwardlog,backwardlog](a, A, LL)
        """
            $($fl)(a, A, LL)

        Compute $($f) probabilities using samples log-likelihoods.
        See [`$($f)`](@ref).
        """
        function $(fl)(a::AbstractVector, A::AbstractMatrix, L::AbstractMatrix)
            m = Matrix{Float64}(undef, size(L))
            c = Vector{Float64}(undef, size(L)[1])
            $(fl!)(m, c, a, A, L)
            m, sum(log.(c))
        end

        # [forward,backward](hmm, observations)
        """
            $($f)(hmm, observations)

        # Example
        ```julia
        hmm = HMM([0.9 0.1; 0.1 0.9], [Normal(0,1), Normal(10,1)])
        z, y = rand(hmm, 1000)
        probs, tot = $($f)(hmm, y)
        ```
        """
        function $(f)(hmm::AbstractHMM, observations)
            $(f)(hmm.a, hmm.A, likelihoods(hmm, observations))
        end

        # [forwardlog,backwardlog](hmm,observations)
        """
            $($fl)(hmm, observations)

        # Example
        ```julia
        hmm = HMM([0.9 0.1; 0.1 0.9], [Normal(0,1), Normal(10,1)])
        z, y = rand(hmm, 1000)
        probs, tot = $($fl)(hmm, y)
        ```
        """
        function $(fl)(hmm::AbstractHMM, observations)
            $(fl)(hmm.a, hmm.A, loglikelihoods(hmm, observations))
        end
    end
end

# Posteriors

"""
    posteriors(α, β)

Compute posterior probabilities from `α` and `β`.
"""
function posteriors(α::AbstractMatrix, β::AbstractMatrix)
    γ = Matrix{Float64}(undef, size(α))
    posteriors!(γ, α, β)
    γ
end

"""
    posteriors(a, A, L)

Compute posterior probabilities using samples likelihoods.
"""
function posteriors(a::AbstractVector, A::AbstractMatrix, L::AbstractMatrix)
    α, _ = forward(a, A, L)
    β, _ = backward(a, A, L)
    posteriors(α, β)
end

"""
    posteriors(hmm, observations)

Compute posterior probabilities using samples likelihoods.

# Example
```julia
hmm = HMM([0.9 0.1; 0.1 0.9], [Normal(0,1), Normal(10,1)])
z, y = rand(hmm, 1000)
γ = posteriors(hmm, y)
```
"""
function posteriors(hmm::AbstractHMM, observations)
    posteriors(hmm.a, hmm.A, likelihoods(hmm, observations))
end

"""
    posteriorslog(α, A, L)

Compute posterior probabilities using samples log-likelihoods.
"""
function posteriorslog(a::AbstractVector, A::AbstractMatrix, LL::AbstractMatrix)
    α, _ = forwardlog(a, A, LL)
    β, _ = backwardlog(a, A, LL)
    posteriors(α, β)
end

"""
    posteriorslog(hmm, observations)

Compute posterior probabilities using samples log-likelihoods.

# Example
```julia
hmm = HMM([0.9 0.1; 0.1 0.9], [Normal(0,1), Normal(10,1)])
z, y = rand(hmm, 1000)
γ = posteriors(hmm, y)
```
"""
function posteriorslog(hmm::AbstractHMM, observations)
    posteriorslog(hmm.a, hmm.A, loglikelihoods(hmm, observations))
end