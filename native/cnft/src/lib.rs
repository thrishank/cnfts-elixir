use mpl_bubblegum::{accounts::TreeConfig, instructions::CreateTreeConfigBuilder};
use rustler::{Decoder, Error, NifResult, Term};
use solana_client::rpc_client::RpcClient;
use solana_sdk::{
    instruction::Instruction, pubkey::Pubkey, signature::Keypair, signer::Signer,
    system_instruction, transaction::Transaction,
};
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
    max_depth: u32,
    max_buffer_size: u32,
) -> NifResult<Vec<u8>> {
    let rpc_client = &rpc_client.0;
    let merkle_tree = merkle_tree.0;
    let payer = payer.0;

    let (tree_config, _) = TreeConfig::find_pda(&merkle_tree);
    let size =
        CONCURRENT_MERKLE_TREE_HEADER_SIZE_V1 + std::mem::size_of::<ConcurrentMerkleTree<14, 64>>();
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
        .max_depth(max_depth)
        .max_buffer_size(max_buffer_size)
        .instruction();

    let tx = Transaction::new_with_payer(&[create_account_ix, create_tree_config_ix], Some(&payer));

    let serialized_tx = match bincode::serialize(&tx) {
        Ok(tx) => tx,
        Err(_) => return Err(Error::RaiseAtom("failed_to_serialize_transaction")),
    };

    Ok(serialized_tx)
}

rustler::init!("Elixir.CNFT");
