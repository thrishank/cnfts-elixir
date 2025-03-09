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
  Mints a new NFT.

  ## Parameters
    - rpc_client: The RPC client to interact with the Solana blockchain.
    - tree: The tree structure where the NFT will be minted.
    - owner: The account that will own the minted NFT.
    - payer: The account that will pay for the transaction.
    - name: The name of the NFT.
    - symbol: The symbol of the NFT.
    - uri: The URI pointing to the NFT metadata.
    - nounce: A unique identifier for the minting process.

  ## Returns
    - A transaction data structure.
  """
  def mint_transaction(rpc_client, tree, owner, payer, name, symbol, uri, nounce), do: :erlang.nif_error(:nif_not_loaded)

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
  def transfer_transaction(rpc_client, asset, owner, payer, receiver), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Creates a tree transaction and logs the result.

  ## Parameters
    - rpc_client: The RPC client to interact with the Solana blockchain.
    - payer: The account that will pay for the transaction.
  """
  def create(rpc_client, payer) do
    data = create_tree_transaction(rpc_client, payer)
    IO.inspect(data, label: "Create Tree")
  end

  @doc """
  Mints a new NFT and logs the result.

  ## Parameters
    - rpc_client: The RPC client to interact with the Solana blockchain.
    - tree: The tree structure where the NFT will be minted.
    - owner: The account that will own the minted NFT.
    - payer: The account that will pay for the transaction.
    - name: The name of the NFT.
    - symbol: The symbol of the NFT.
    - uri: The URI pointing to the NFT metadata.
    - nounce: A unique identifier for the minting process.
  """
  def mint(rpc_client, tree, owner, payer, name, symbol, uri, nounce) do
    data = mint_transaction(rpc_client, tree, owner, payer, name, symbol, uri, nounce)
    IO.inspect(data, label: "Mint")
  end

  @doc """
  Transfers an NFT to a new owner and logs the result.

  ## Parameters
    - rpc_client: The RPC client to interact with the Solana blockchain.
    - asset: The NFT asset to be transferred.
    - owner: The current owner of the NFT.
    - payer: The account that will pay for the transaction.
    - receiver: The account that will receive the NFT.
  """
  def transfer(rpc_client, asset, owner, payer, receiver) do
    data = transfer_transaction(rpc_client, asset, owner, payer, receiver)
    IO.inspect(data, label: "Transfer")
  end
end
