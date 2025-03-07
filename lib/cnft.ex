import SolanaTransactionSender, only: [sign_and_send_transaction: 3]
defmodule CNFT do
  use Rustler, otp_app: :cnft, crate: "cnft"

  def create_tree_transaction(rpc_client, merkle_tree, payer), do: :erlang.nif_error(:nif_not_loaded)
  def test do 
  tx = create_tree_transaction(
    "https://api.devnet.solana.com",
    "3fezd2iPhzh7hXChgEzeuE1dpkzxCfxXzvmfvF5iSyDF",
    "thrbabBvANwvKdV34GdrFUDXB6YMsksdfmiKj2ZUV3m"
  )
     result = SolanaTransactionSender.sign_and_send_transaction(
   tx,
   private_key,
   "https://api.devnet.solana.com"
)
    end

  def mint_transaction(_tree, _owner, _payer, _name, _symbol, _uri), do: :erlang.nif_error(:nif_not_loaded)
  def transfer_transaction(tree, owner, payer, new_owner, nounce), do: :erlang.nif_error(:nif_not_loaded)
end
