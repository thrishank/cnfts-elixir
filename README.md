# Cnft

Cnft is an Elixir library for handling transactions related to creating, minting, and transferring NFTs on the Solana blockchain. This library uses Rustler to interface with native Rust code for performance-critical operations.

## Installation

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

{create_sign, tree} = CNFT.create(rpc_client, payer) # returns signture and created tree account address
```

### Minting a New NFT

```elixir
owner = # The account that will own the minted NFT
payer = # The account that will pay for the transaction
name = "MyNFT"
symbol = "MNFT"
uri = "http://example.com/metadata"
nounce = 0  # starts at 0 incerease by one everytime you mint a cnft

{mint_sign, asset} = CNFT.mint(rpc_client, tree, owner, payer, name, symbol, uri, nounce)
```

### Transferring an NFT

```elixir
receiver = # The account that will receive the NFT

transfer_sign = CNFT.transfer(rpc_client, asset, owner, payer, receiver)
```
