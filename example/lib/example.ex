defmodule Example do
  def run do
    rpc_client = "https://api.devnet.solana.com"
    payer = 
    owner = ""
    receiver = ""

    {sign, tree} = CNFT.create_tree_transaction(rpc_client, payer)

    loop(tree, rpc_client, owner, payer, receiver, 0, 10)
  end
 defp loop(tree, rpc_client, owner, payer, receiver, nonce, num_iterations) when nonce < num_iterations do
    # Mint the NFT
    mint_sign = CNFT.mint_transaction(
      rpc_client,
      tree,
      owner,
      payer,
      "My NFT #{nonce + 1}",
      "NFT",
      "https://example.com",
      100,
      true
    )

    # Get the asset address
    asset_id = CNFT.get_asset_address(tree, nonce)

    # Transfer the NFT
    CNFT.transfer_transaction(rpc_client, asset_id, owner, payer, receiver)

    # Print logs
    IO.puts("Minted NFT #{nonce + 1} with signature: #{mint_sign}")
    IO.puts("Transferred NFT (Asset ID: #{asset_id}) to #{receiver} with signature: #{transfer_sign}")

    # Recursive call with incremented nonce
    loop(tree, rpc_client, owner, payer, receiver, nonce + 1, num_iterations)
  end
end
