defmodule CNFT do
  @moduledoc """
  CNFT is a module for handling transactions related to creating, minting, and transferring NFTs on the Solana blockchain.

  This module uses Rustler to interface with native Rust code for performance-critical operations.
  """
  use Rustler, otp_app: :cnft, crate: "cnft"

  @doc """
  Creates a tree transaction.

  ## Parameters
    - rpc_client: The RPC client to interact with the Solana blockchain.
    - payer: The account that will pay for the transaction.

  ## Returns
    - A transaction data structure.
  """
  def create_tree_transaction(rpc_client, payer), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Mints a new NFT on the Solana blockchain.

  ## Parameters
    - rpc_client: The RPC client to interact with the Solana blockchain.
    - tree: The public key (as a string) of the tree structure where the NFT will be minted.
    - owner: The public key (as a string) of the account that will own the minted NFT.
    - payer: The keypair (as a string, e.g., base58 encoded) of the account that will pay for the transaction.
    - name: The name of the NFT.
    - symbol: The symbol of the NFT.
    - uri: The URI pointing to the NFT metadata.
    - seller_fee_basis_points: The royalty fee in basis points (e.g., 100 = 1%)
    - is_mutable: Boolean indicating if the NFT metadata can be updated. 

  ## Returns
    - `{:ok, transaction_signature}`: A tuple containing the atom `:ok` and the transaction signature as a string.
    - `{:error, reason}`: A tuple containing the atom `:error` and a reason for failure (if the NIF fails).
  """
  def mint_transaction(
        rpc_client,
        tree,
        owner,
        payer,
        name,
        symbol,
        uri,
        seller_fee_basis_points,
        is_mutable
      ) do
    :erlang.nif_error(:nif_not_loaded)
  end

  @doc """
  Gets the asset address for a minted NFT.

  ## Parameters
    - tree: The public key (as a string) of the tree structure where the NFT is minted.
    - nonce: A unique identifier for the minted NFT.

  ## Returns
    - The asset public key address as a string.
  """
  def get_asset_address(tree, nonce), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Transfers an NFT to a new owner.

  ## Parameters
    - rpc_client: The RPC client to interact with the Solana blockchain.
    - asset: The NFT asset to be transferred.
    - owner: The current owner of the NFT.
    - payer: The account that will pay for the transaction.
    - receiver: The account that will receive the NFT.

  ## Returns
    - A transaction data structure.
  """
  def transfer_transaction(rpc_client, asset, owner, payer, receiver),
    do: :erlang.nif_error(:nif_not_loaded)
end
