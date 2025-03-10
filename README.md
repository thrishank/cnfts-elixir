# Cnft

Cnft is an Elixir library for handling transactions related to creating, minting, and transferring NFTs on the Solana blockchain. This library uses Rustler to interface with native Rust code for performance-critical operations.

## Installation

```elixir
def deps do
  [
    {:cnft, "~> 0.1.5"}
  ]
end
```

## Usage

### Creating a Tree Transaction

```elixir
rpc_client = # Your RPC client
payer = # The account that will pay for the transaction

{create_sign, tree} = CNFT.create_tree_transaction(rpc_client, payer)
```

### Minting a New NFT

```elixir
owner = # The account that will own the minted NFT
payer = # The account that will pay for the transaction
name = "MyNFT"
symbol = "MNFT"
uri = "http://example.com/metadata"
seller_fee_basis_points = 100
is_mutable = true

CNFT.mint(rpc_client, tree, owner, payer, name, symbol, uri, seller_fee_basis_points, is_mutable)
```

### Transferring an NFT

```elixir
receiver = # The account that will receive the NFT
nonce = 0 # Start at 0 and increment for each mint

asset = CNFT.get_asset_address(tree, nonce)
CNFT.transfer(rpc_client, asset, owner, payer, receiver)
```
