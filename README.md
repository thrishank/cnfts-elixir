# Cnft

Cnft is an Elixir library for handling transactions related to creating, minting, and transferring NFTs on the Solana blockchain. This library uses Rustler to interface with native Rust code for performance-critical operations.

## Installation

```elixir
def deps do
  [
    {:cnft, "~> 0.1.6"}
  ]
end
```

## Usage

### Creating a Tree Config

```elixir
rpc_client = # RPC connection url
payer = # The account that will pay for the transaction. string or array bytes
max_depth = # https://developers.metaplex.com/bubblegum/create-trees
max_buffer_size =

{create_sign, tree} = CNFT.create_tree_transaction(rpc_client, payer, max_depth, max_buffer_size)
```

### Minting a New NFT

```elixir
owner = # The account that will own the minted NFT
payer = # The account that will pay for the transaction
name  = "MyNFT"
symbol = "MNFT"
uri = "http://example.com/metadata"
seller_fee_basis_points = 100
is_mutable = true
nonce = 0 # Start at 0 and increment for each mint

{mint_sign, asset} = CNFT.mint(rpc_client, tree, owner, payer, name, symbol, uri, seller_fee_basis_points, is_mutable, nonce)
```

### Transfer an NFT

```elixir
receiver = # The account that will receive the NFT

transfer_sign = CNFT.transfer(rpc_client, asset, owner, payer, receiver)
```
