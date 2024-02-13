import Printf: format, Format

function sprintf(fmt::String, args...)
  format(Format(fmt), args...)
end
