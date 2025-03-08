import SolanaTransactionSender, only: [sign_and_send_transaction: 3]
defmodule CNFT do
  use Rustler, otp_app: :cnft, crate: "cnft"

  def create_tree_transaction(rpc_client, payer), do: :erlang.nif_error(:nif_not_loaded)
  def mint_transaction(rpc_client, tree, owner, payer, name, symbol, uri, nounce), do: :erlang.nif_error(:nif_not_loaded)
  def transfer_transaction(rpc_client, asset, owner, payer, receiver), do: :erlang.nif_error(:nif_not_loaded)

  def create(rpc_client, payer) do
    data = create_tree_transaction(rpc_client, payer)
    IO.inspect(data, label: "Create Tree")
  end

  def mint(rpc_client, tree, owner, payer, name, symbol, uri, nounce) do
    data = mint_transaction(rpc_client, tree, owner, payer, name, symbol, uri, nounce)
    IO.inspect(data, label: "Mint")
  end

  def transfer(rpc_client, asset, owner, payer, receiver) do
    data = transfer_transaction(rpc_client, asset, owner, payer, receiver)
    IO.inspect(data, label: "Transfer")
  end
end
