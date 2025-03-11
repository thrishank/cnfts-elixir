use mpl_bubblegum::{accounts::TreeConfig, instructions::CreateTreeConfigBuilder};
use reqwest::blocking::Client;
use rustler::{Error, NifResult};
use serde::{Deserialize, Serialize};
use solana_sdk::{
    signature::Keypair, signer::Signer, system_instruction, transaction::Transaction,
};

use crate::{KeypairWrapper, RpcClientWrapper};

#[rustler::nif]
pub fn create_tree_config(
    rpc_client: RpcClientWrapper,
    payer: KeypairWrapper,
    MAX_DEPTH: u32,
    MAX_BUFFER_SIZE: u32,
) -> NifResult<(String, String)> {
    let rpc_client = rpc_client.0;
    let merkle_tree = Keypair::new();
    let payer = payer.0;

    let (tree_config, _) = TreeConfig::find_pda(&merkle_tree.pubkey());

    let size = get_size(MAX_DEPTH, MAX_BUFFER_SIZE).unwrap();

    let rent = match rpc_client.get_minimum_balance_for_rent_exemption(size as usize) {
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
        .max_depth(MAX_DEPTH)
        .max_buffer_size(MAX_BUFFER_SIZE)
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

fn get_size(depth: u32, buffer: u32) -> Result<u64, Box<dyn std::error::Error>> {
    let client = Client::new();

    /* The size calculation is done on the server because Rustler (the Rust-Elixir FFI library) does not allow
    constant parameters in functions. In Rust, we typically calculate the size during compile time using
    constant parameters, which is not feasible in this case due to the limitations of Rustler. Therefore,
    to work around this, the size is calculated dynamically on a server */
    let url = format!(
        "https://server-nu-tawny.vercel.app/api/cnfts?depth={}&buffer={}",
        depth, buffer
    );

    let response = client.get(&url).send()?;
    if !response.status().is_success() {
        return Err(format!("API request failed with status code: {}", response.status()).into());
    }

    let api_response: ApiResponse = response.json()?;
    Ok(api_response.size)
}

#[derive(Debug, Deserialize)]
struct ApiResponse {
    size: u64,
    params: Option<ParamInfo>,
}

#[derive(Debug, Deserialize)]
struct ParamInfo {
    depth: u8,
    buffer: u8,
}
