import SolanaTransactionSender, only: [sign_and_send_transaction: 3]
defmodule CNFT do
  use Rustler, otp_app: :cnft, crate: "cnft"

  def create_tree_transaction(rpc_client, payer), do: :erlang.nif_error(:nif_not_loaded)
  def test do 
    data = create_tree_transaction("https://api.devnet.solana.com", private_key)
    IO.inspect(data, label: "Transaction Data")
  end

  def mint_transaction(rpc_client, tree, owner, payer, name, symbol, uri, nounce), do: :erlang.nif_error(:nif_not_loaded)
  def test_mint do

    data = mint_transaction("https://api.devnet.solana.com","5Pgeo5CxjawjyekQiVXo2UxSvABWoteBg1s7bamAyjCj", "EXBdeRCdiNChKyD7akt64n9HgSXEpUtpPEhmbnm4L6iH", private_key, "test_mint", "TST", "https://solana.com", 1)
    IO.inspect(data, label: "Transaction Data")
  end
  def add(a,b) do
    a + b
  end
  def transfer_transaction(rpc_client,tree, asset, owner,payer, receiver, nounce), do: :erlang.nif_error(:nif_not_loaded)
end
