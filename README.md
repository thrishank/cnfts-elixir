# Cnft

CNFT is an Elixir library for handling Compressed NFT (cNFT) transactions on the Solana blockchain. It provides a native interface through Rustler for efficient creation, minting, and transfer of compressed NFTs using the Metaplex Bubblegum protocol.

## Installation

Add `cnft` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:cnft, "~> 0.1.6"}
  ]
end
```

## Prerequisites

- Elixir 1.12 or later
- Rust toolchain (for native compilation)

## Usage 

### Creating a Tree Config

The first step in working with compressed NFTs is creating a Merkle tree configuration:

```elixir
rpc_client = # Solana RPC connection url
payer = # The account that will pay for the transaction. base58 string or array bytes
max_depth = # https://developers.metaplex.com/bubblegum/create-trees
max_buffer_size =

{create_sign, tree} = CNFT.create_tree_transaction(rpc_client, payer, max_depth, max_buffer_size)
```

### Minting a New NFT
Once you have a tree configured, you can mint compressed NFTs:
```elixir
tree = ""  # The public key of your Merkle tree
owner = "" # The recipient/owner of the NFT
payer = "" # The account that will pay for the transaction
name  = "MyNFT"  # NFT name
symbol = "MNFT"  # NFT symbol
uri = "http://example.com/metadata" # Metadata URI
seller_fee_basis_points = 100 # 5% royalty fee (500 basis points)              
is_mutable = true # Whether the NFT can be updated
nonce = 0 # Unique identifier Start at 0 (increment for each mint)

{mint_sign, asset} = CNFT.mint(rpc_client, tree, owner, payer, name, symbol, uri, seller_fee_basis_points, is_mutable, nonce)
```

### Transferring a Compressed NFT

Transfer an existing compressed NFT to a new owner:

```elixir
receiver = "RECEIVER_PUBLIC_KEY" # The account that will receive the NFT

transfer_sign = CNFT.transfer(rpc_client, asset, owner, payer, receiver)
```

## Development

1. Clone the repository
```bash
git clone https://github.com/thrishank/cnfts-elixir 

cd cnfts-elixir
```
2. Install dependencies with `mix deps.get`
```bash
mix deps.get
```
3. Ensure Rust is installed for native compilation
```bash
mix compile
```
4. update the varaible in test/cnfts_test.exs
```elixir
@rpc_client ""
@private_key ""
@owner_key ""
@receiver_key ""
```
5. Run tests 
```bash
mix test
```