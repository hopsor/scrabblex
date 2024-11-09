defmodule Scrabblex.Cldr do
  use Cldr,
    otp_app: :scrabblex,
    locales: ["en"],
    providers: [Cldr.Number, Cldr.Calendar, Cldr.DateTime]
end
