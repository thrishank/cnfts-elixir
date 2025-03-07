use mpl_bubblegum::{
    accounts::TreeConfig,
    instructions::{CreateTreeConfigBuilder, MintV1Builder},
    types::{Creator, MetadataArgs, TokenProgramVersion, TokenStandard},
};
use rustler::{Decoder, Error, NifResult, Term};
use solana_client::rpc_client::RpcClient;
use solana_sdk::{pubkey::Pubkey, system_instruction, transaction::Transaction};
use spl_account_compression::{state::CONCURRENT_MERKLE_TREE_HEADER_SIZE_V1, ConcurrentMerkleTree};
use std::str::FromStr;

// Wrapper type for Pubkey
#[derive(Clone, Debug)]
struct PubkeyWrapper(Pubkey);

// Implement Decoder for our wrapper
impl<'a> Decoder<'a> for PubkeyWrapper {
    fn decode(term: Term<'a>) -> NifResult<Self> {
        let pubkey_string: String = term.decode()?;
        Ok(PubkeyWrapper(
            Pubkey::from_str(&pubkey_string).map_err(|_| Error::RaiseAtom("invalid_pubkey"))?,
        ))
    }
}

// Wrapper type for RpcClient
struct RpcClientWrapper(RpcClient);

// Implement Decoder for our wrapper
impl<'a> Decoder<'a> for RpcClientWrapper {
    fn decode(term: Term<'a>) -> NifResult<Self> {
        let rpc_url: String = term.decode()?;
        Ok(RpcClientWrapper(RpcClient::new(rpc_url)))
    }
}

#[rustler::nif]
fn create_tree_transaction(
    rpc_client: RpcClientWrapper,
    merkle_tree: PubkeyWrapper,
    payer: PubkeyWrapper,
) -> NifResult<Vec<u8>> {
    let rpc_client = &rpc_client.0;
    let merkle_tree = merkle_tree.0;
    let payer = payer.0;

    let (tree_config, _) = TreeConfig::find_pda(&merkle_tree);

    const MAX_DEPTH: usize = 14;
    const MAX_BUFFER_SIZE: usize = 64;

    let size = CONCURRENT_MERKLE_TREE_HEADER_SIZE_V1
        + std::mem::size_of::<ConcurrentMerkleTree<MAX_DEPTH, MAX_BUFFER_SIZE>>();

    let rent = rpc_client
        .get_minimum_balance_for_rent_exemption(size)
        .unwrap();

    let create_account_ix = system_instruction::create_account(
        &payer,
        &merkle_tree,
        rent,
        size as u64,
        &spl_account_compression::ID,
    );

    let create_tree_config_ix = CreateTreeConfigBuilder::new()
        .merkle_tree(merkle_tree)
        .tree_config(tree_config)
        .payer(payer)
        .tree_creator(payer)
        .max_depth(MAX_DEPTH as u32)
        .max_buffer_size(MAX_BUFFER_SIZE as u32)
        .instruction();

    let tx = Transaction::new_with_payer(&[create_account_ix, create_tree_config_ix], Some(&payer));

    let serialized_tx = match bincode::serialize(&tx) {
        Ok(tx) => tx,
        Err(_) => return Err(Error::RaiseAtom("failed_to_serialize_transaction")),
    };

    Ok(serialized_tx)
}

#[rustler::nif]
fn mint_transaction(
    tree: PubkeyWrapper,
    owner: PubkeyWrapper,
    payer: PubkeyWrapper,
    name: String,
    symbol: String,
    uri: String,
) -> NifResult<Vec<u8>> {
    let tree = tree.0;
    let owner = owner.0;
    let payer = payer.0;
    let (tree_config, _) = TreeConfig::find_pda(&tree);
    let args = MetadataArgs {
        name,
        symbol,
        uri,
        seller_fee_basis_points: 100,
        primary_sale_happened: false,
        is_mutable: true,
        edition_nonce: None,
        token_standard: Some(TokenStandard::NonFungible),
        collection: None,
        uses: None,
        token_program_version: TokenProgramVersion::Original,
        creators: vec![Creator {
            address: owner,
            share: 100,
            verified: false,
        }],
    };

    let mint_ix = MintV1Builder::new()
        .leaf_delegate(owner)
        .leaf_owner(owner)
        .merkle_tree(tree)
        .payer(payer)
        .tree_config(tree_config)
        .tree_creator_or_delegate(payer)
        .metadata(args.clone())
        .instruction();

    let tx = Transaction::new_with_payer(&[mint_ix], Some(&payer));

    let serialized_tx = match bincode::serialize(&tx) {
        Ok(tx) => tx,
        Err(_) => return Err(Error::RaiseAtom("failed_to_serialize_transaction")),
    };

    Ok(serialized_tx)
}

rustler::init!("Elixir.CNFT");
