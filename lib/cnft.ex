defmodule CNFT do
  use Rustler, otp_app: :cnft, crate: "cnft"

  def add(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
  def key(), do: :erlang.nif_error(:nif_not_loaded)
end
