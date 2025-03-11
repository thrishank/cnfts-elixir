# CNFT Example Project

This is an example project demonstrating how to use the CNFT package for creating, minting, and transferring Compressed NFTs on the Solana blockchain.

## Setup

1. Clone this repository
```bash
git clone https://github.com/thrishank/cnfts-elixir 

cd cnfts-elixir/example
```
2. Install dependencies:
```elixir
mix deps.get
```
3. update the varaiables with your solana keys. This Example code mints 10 nfts and transfers them to same @receiver address. Make sure to customize it
```elixir
    rpc_client = "https://api.devnet.solana.com"
    payer = ""  
    owner = ""
    receiver = ""
```
4. run the code
```bash
mix run -e "Example.run()"
```

## Troubleshooting

1. If you encounter RPC errors, ensure your Solana node endpoint is accessible
2. Verify that your keypair has sufficient SOL for transactions
3. Check that your metadata URI is accessible and properly formatted

## Resources

- [CNFT Package Documentation](https://hex.pm/packages/cnft)
- [Solana Documentation](https://docs.solana.com)
- [Metaplex Documentation](https://docs.metaplex.com)