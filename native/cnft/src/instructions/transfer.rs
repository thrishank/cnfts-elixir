use bs58;
use mpl_bubblegum::{accounts::TreeConfig, instructions::TransferBuilder};
use reqwest::blocking::Client;
use rustler::NifResult;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use solana_client::rpc_client::RpcClient;
use solana_program::instruction::AccountMeta as ProgramAccountMeta;
use solana_sdk::{
    instruction::AccountMeta, pubkey::Pubkey, signer::Signer, transaction::Transaction,
};
use std::str::FromStr;

use crate::{KeypairWrapper, PubkeyWrapper};

#[rustler::nif]
fn transfer_transaction(
    rpc_url: String,
    asset_id: PubkeyWrapper,
    owner: PubkeyWrapper,
    payer: KeypairWrapper,
    receiver: PubkeyWrapper,
) -> NifResult<String> {
    let rpc_client = RpcClient::new(&rpc_url);
    let owner = owner.0;
    let payer = payer.0;
    let receiver = receiver.0;

    let asset = get_asset_details(&asset_id.0.to_string(), &rpc_url)
        .unwrap()
        .unwrap();
    let proof_data = get_asset_proof(&asset_id.0.to_string(), &rpc_url)
        .unwrap()
        .unwrap();

    // Calculate tree config
    let (tree_config, _) = TreeConfig::find_pda(&Pubkey::from_str(&asset.tree).unwrap());

    // Decode hashes
    let data_hash = decode(&asset.data_hash).unwrap();
    let creator_hash = decode(&asset.creator_hash).unwrap();
    let root_bytes = decode(&proof_data.root).unwrap();

    let proof_accounts: Vec<AccountMeta> = proof_data
        .proof
        .iter()
        .map(|node| AccountMeta::new_readonly(Pubkey::from_str(node).unwrap(), false))
        .collect();

    let proof_accounts_new: Vec<ProgramAccountMeta> = proof_accounts
        .iter()
        .map(|meta| ProgramAccountMeta {
            pubkey: meta.pubkey.to_bytes().into(),
            is_signer: meta.is_signer,
            is_writable: meta.is_writable,
        })
        .collect();
    let transfer_ix = TransferBuilder::new()
        .leaf_owner(owner, true)
        .leaf_delegate(owner, false)
        .merkle_tree(Pubkey::from_str(&asset.tree).unwrap())
        .tree_config(tree_config)
        .new_leaf_owner(receiver)
        .root(root_bytes)
        .nonce(asset.leaf_id)
        .index(asset.leaf_id as u32)
        .add_remaining_accounts(&proof_accounts_new)
        .data_hash(data_hash)
        .creator_hash(creator_hash)
        .instruction();

    let recent_blockhash = rpc_client.get_latest_blockhash().unwrap();
    let tx = Transaction::new_signed_with_payer(
        &[transfer_ix],
        Some(&payer.pubkey()),
        &[&payer],
        recent_blockhash,
    );

    let signature = rpc_client.send_and_confirm_transaction(&tx).unwrap();

    Ok(signature.to_string())
}

fn get_asset_details(
    rpc_url: &str,
    asset_id: &str,
) -> Result<Option<CompressionData>, Box<dyn std::error::Error>> {
    let client = Client::new();
    let request_body = json!({
        "jsonrpc": "2.0",
        "id": "1",
        "method": "getAsset",
        "params": { "id": asset_id }
    });

    let response: Value = client.post(rpc_url).json(&request_body).send()?.json()?;

    if let Some(compression) = response["result"]["compression"].as_object() {
        let compression_data: CompressionData =
            serde_json::from_value(Value::Object(compression.clone()))?;
        return Ok(Some(compression_data));
    }

    Ok(None)
}

fn get_asset_proof(
    rpc_url: &str,
    asset_id: &str,
) -> Result<Option<Proof>, Box<dyn std::error::Error>> {
    let client = Client::new();
    let request_body = json!({
        "jsonrpc": "2.0",
        "id": "1",
        "method": "getAssetProof",
        "params": { "id": asset_id }
    });

    let response: Value = client.post(rpc_url).json(&request_body).send()?.json()?;

    if let Some(compression) = response["result"].as_object() {
        let compression_data: Proof = serde_json::from_value(Value::Object(compression.clone()))?;
        // println!("Compression Data: {:?}", compression_data);
        return Ok(Some(compression_data));
    }

    Ok(None)
}

fn decode(input: &str) -> Result<[u8; 32], Box<dyn std::error::Error>> {
    bs58::decode(input)
        .into_vec()?
        .try_into()
        .map_err(|_| "Expected 32 bytes".into())
}

#[derive(Debug, Serialize, Deserialize)]
struct CompressionData {
    asset_hash: String,
    compressed: bool,
    creator_hash: String,
    data_hash: String,
    eligible: bool,
    leaf_id: u64,
    seq: u64,
    tree: String,
}

#[derive(Debug, Serialize, Deserialize)]
struct Proof {
    root: String,
    proof: Vec<String>,
}
