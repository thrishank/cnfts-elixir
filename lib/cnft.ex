defmodule CNFT do
  use Rustler, otp_app: :cnft, crate: "cnft"

  def create_tree_transaction(rpc_client, merkle_tree, payer), do: :erlang.nif_error(:nif_not_loaded)
end
