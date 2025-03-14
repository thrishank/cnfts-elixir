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
- [RPC URL](https://solana.com/docs/references/clusters)  [helius](https://dashboard.helius.dev/dashboard) 

## Usage

### Creating a Tree Config

The first step in working with compressed NFTs is creating a Merkle tree configuration:

```elixir
# Configure your Solana connection
rpc_client = "https://api.mainnet-beta.solana.com"  # Or your preferred RPC endpoint

# Configure the payer account (must be funded)
payer = "Base58 encoded key or [bytes_array_of_private_key]" 

# Configure tree parameters
# https://developers.metaplex.com/bubblegum/create-trees
max_depth = 14        
max_buffer_size = 64

# Create the tree
{signature, tree_address} = CNFT.create_tree_transaction(
  rpc_client, 
  payer, 
  max_depth, 
  max_buffer_size
)
```

### Minting a New Compressed NFT

Once you have a tree configured, you can mint compressed NFTs:

```elixir
# Tree address from the creation step
tree = "treePubkeyHere123456789abcdef"  

# NFT recipient
owner = "recipientPubkeyHere123456789" 

# NFT metadata
name = "My Awesome NFT"
symbol = "AWESOME"
uri = "https://arweave.net/yourMetadataJson"  # Should point to JSON matching Metaplex standard
seller_fee_basis_points = 500  # 5% royalty (500 basis points = 5%)
is_mutable = true  # Can metadata be updated later?
nonce = 0  # Uniquely identifies this mint, increment for each subsequent mint

# mint transaction
{signature, asset_id} = CNFT.mint_v1(
  rpc_client, 
  tree, 
  owner, 
  payer, 
  name, 
  symbol, 
  uri, 
  seller_fee_basis_points, 
  is_mutable, 
  nonce
)
```

### Transferring a Compressed NFT

Transfer an existing compressed NFT to a new owner:

```elixir
receiver = "RECEIVER_PUBLIC_KEY" # The account that will receive the NFT

asset_id = "assetpublickeyaddress" # Asset ID from minting step
transfer_sign = CNFT.transfer(rpc_client, asset, owner, payer, receiver)
```

### Fetching Asset Details

Retrieve information about a compressed NFT:

```elixir
asset_id = "assetIdToLookup"
asset_details = CNFT.get_asset(rpc_client, asset_id)
```

## Best Practices
 - Store tree addresses and asset IDs securely - they're needed for all future operations.
 - Increment the nonce value for each mint to the same tree.
 - Verify transactions after submission by checking their status.
 - Consider compression ratio when designing your collection size.
## Demo

1. [create tree transaction](https://explorer.solana.com/tx/5iiE1Vt7B47hxXTuyDM2eDENAMGEUQ3VWTKEzDDmjmTz7q2JbSK3yJNEs9wj5aiWiAf2JGtJJULqobYS288NysBD?cluster=devnet)
2. [mint cnft transaction](https://explorer.solana.com/tx/3VbM3heuhpurc31UdQbko7NYowNXXtpgBrV7oUDVCpWtVRMfbW1JFqH3g2nRdR376t5F4Z1ku3erG4vBdfnoWpsD?cluster=devnet)
3. [transfer cnft transaction](https://explorer.solana.com/tx/5PWoWUScjLrSbPXrpqwGnBLzp8M8CHtjgNyiuiQ9kVnBkKYwYeGEVVJerPprbKUXiZLBEQPVJqRs365b3uDhGmLs?cluster=devnet)

<img width="1232" alt="Screenshot 2025-03-12 at 5 02 32 AM" src="https://github.com/user-attachments/assets/26d1eae2-c305-4702-9672-1e88103eb12f" />

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

## License
This project is licensed under the MIT License.
