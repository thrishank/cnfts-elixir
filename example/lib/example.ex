defmodule Example do
  def run do
    rpc_client = "https://api.devnet.solana.com"
    payer = "3kSPdPULig47U2UzcsTxVBmSP6Ddor2W9bA1oc6ThJGET6fCFU5QMs7L1Azh9zBB83GuTXZSBGhBVTy1LmLBWto7"  
    owner = "5Z6TZ11JkxyeXgZ8a1UyuWcp1BZ7QsySNWWRpmx9qgDK"
    receiver = "thrbabBvANwvKdV34GdrFUDXB6YMsksdfmiKj2ZUV3m"

    # Create tree config
    {sign, tree} = CNFT.create_tree_config(rpc_client, payer, 14, 64)

    loop(tree, rpc_client, owner, payer, receiver, 0, 10)
  end
 defp loop(tree, rpc_client, owner, payer, receiver, nonce, num_iterations) when nonce < num_iterations do
    # Mint the NFT
    {mint_sign, asset_id} = CNFT.mint_v1(
      rpc_client,
      tree,
      owner,
      payer,
      "My NFT #{nonce + 1}",
      "NFT",
      "https://example.com",
      100,
      true,
      nonce
    )

    # Transfer the NFT
    transfer_sign = CNFT.transfer(rpc_client, asset_id, owner, payer, receiver)

    # Print logs
    IO.puts("Minted NFT #{nonce + 1} signature: #{mint_sign}")
    IO.puts("Transferred NFT (Asset ID: #{asset_id}) to #{receiver}  signature: #{transfer_sign}")

    # Recursive call with incremented nonce
    loop(tree, rpc_client, owner, payer, receiver, nonce + 1, num_iterations)
  end
end
