use mpl_bubblegum::{accounts::TreeConfig, instructions::CreateTreeConfigBuilder};
use rustler::{Error, NifResult};
use solana_sdk::{
    signature::Keypair, signer::Signer, system_instruction, transaction::Transaction,
};
use spl_account_compression::{state::CONCURRENT_MERKLE_TREE_HEADER_SIZE_V1, ConcurrentMerkleTree};

use crate::{KeypairWrapper, RpcClientWrapper};

#[rustler::nif]
pub fn create_tree_transaction(
    rpc_client: RpcClientWrapper,
    payer: KeypairWrapper,
) -> NifResult<(String, String)> {
    let rpc_client = rpc_client.0;
    let merkle_tree = Keypair::new();
    let payer = payer.0;

    let (tree_config, _) = TreeConfig::find_pda(&merkle_tree.pubkey());

    const MAX_DEPTH: usize = 14;
    const MAX_BUFFER_SIZE: usize = 64;

    let size = CONCURRENT_MERKLE_TREE_HEADER_SIZE_V1
        + std::mem::size_of::<ConcurrentMerkleTree<MAX_DEPTH, MAX_BUFFER_SIZE>>();

    let rent = match rpc_client.get_minimum_balance_for_rent_exemption(size) {
        Ok(rent) => rent,
        Err(_) => return Err(Error::RaiseAtom("failed_to_get_rent")),
    };

    let create_account_ix = system_instruction::create_account(
        &payer.pubkey(),
        &merkle_tree.pubkey(),
        rent,
        size as u64,
        &spl_account_compression::ID,
    );

    let create_tree_config_ix = CreateTreeConfigBuilder::new()
        .merkle_tree(merkle_tree.pubkey())
        .tree_config(tree_config)
        .payer(payer.pubkey())
        .tree_creator(payer.pubkey())
        .max_depth(MAX_DEPTH as u32)
        .max_buffer_size(MAX_BUFFER_SIZE as u32)
        .instruction();

    let recent_blockhash = match rpc_client.get_latest_blockhash() {
        Ok(blockhash) => blockhash,
        Err(_) => return Err(Error::RaiseAtom("failed_to_get_blockhash")),
    };

    let tx = Transaction::new_signed_with_payer(
        &[create_account_ix, create_tree_config_ix],
        Some(&payer.pubkey()),
        &[&payer, &merkle_tree],
        recent_blockhash,
    );

    let signature = rpc_client.send_and_confirm_transaction(&tx).unwrap();

    Ok((signature.to_string(), merkle_tree.pubkey().to_string()))
}
