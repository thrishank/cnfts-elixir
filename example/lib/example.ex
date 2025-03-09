defmodule Example do
  def run do
    rpc_client = "https://api.devnet.solana.com"
    payer = []
    owner = ""
    receiver = ""

    {sign, tree} = CNFT.create(rpc_client, payer)

    {mint_sign, asset_id} = CNFT.mint(rpc_client, tree, owner, payer, "My NFT", "NFT", "https://example.com", 0)

    CNFT.transfer(rpc_client, asset_id, owner, payer, receiver)
  end
end

