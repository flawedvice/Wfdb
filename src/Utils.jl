
module Utils

export validate

function validate(
    type::Type{T},
    value::SubString{String},
    default::T,
) where {T<:Number}
    if isempty(value)
        return default
    end
    parse(type, value)
end

function validate(
    type::Type{T},
    value::SubString{String},
    default::T,
) where {T<:String}
    if isempty(value)
        return default
    end

    return value
end

end