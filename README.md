# Cnft

Cnft is an Elixir library for handling transactions related to creating, minting, and transferring NFTs on the Solana blockchain. This library uses Rustler to interface with native Rust code for performance-critical operations.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed by adding `cnft` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:cnft, "~> 0.1.0"}
  ]
end
```

## Usage

### Creating a Tree Transaction

```elixir
rpc_client = # Your RPC client
payer = # The account that will pay for the transaction

CNFT.create(rpc_client, payer)
```

### Minting a New NFT

```elixir
rpc_client = # Your RPC client
tree = # The tree structure where the NFT will be minted
owner = # The account that will own the minted NFT
payer = # The account that will pay for the transaction
name = "MyNFT"
symbol = "MNFT"
uri = "http://example.com/metadata"
nounce = 1

CNFT.mint(rpc_client, tree, owner, payer, name, symbol, uri, nounce)
```

### Transferring an NFT

```elixir
rpc_client = # Your RPC client
asset = # The NFT asset to be transferred
owner = # The current owner of the NFT
payer = # The account that will pay for the transaction
receiver = # The account that will receive the NFT

CNFT.transfer(rpc_client, asset, owner, payer, receiver)
```
