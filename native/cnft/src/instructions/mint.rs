use mpl_bubblegum::{
    accounts::TreeConfig,
    instructions::MintV1Builder,
    types::{Creator, MetadataArgs, TokenProgramVersion, TokenStandard},
    utils::get_asset_id,
};
use rustler::NifResult;
use solana_sdk::{signer::Signer, transaction::Transaction};

use crate::{KeypairWrapper, PubkeyWrapper, RpcClientWrapper};

#[allow(clippy::too_many_arguments)]
#[rustler::nif]
pub fn mint_v1(
    rpc_client: RpcClientWrapper,
    tree: PubkeyWrapper,
    owner: PubkeyWrapper,
    payer: KeypairWrapper,
    name: String,
    symbol: String,
    uri: String,
    seller_fee_basis_points: u16,
    is_mutable: bool,
    nonce: u64,
) -> NifResult<(String, String)> {
    let rpc_client = rpc_client.0;
    let tree = tree.0;
    let owner = owner.0;
    let payer = payer.0;
    let (tree_config, _) = TreeConfig::find_pda(&tree);
    let args = MetadataArgs {
        name,
        symbol,
        uri,
        seller_fee_basis_points, // 100
        primary_sale_happened: false,
        is_mutable, // true
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
        .payer(payer.pubkey())
        .tree_config(tree_config)
        .tree_creator_or_delegate(payer.pubkey())
        .metadata(args.clone())
        .instruction();

    let recent_blockhash = rpc_client.get_latest_blockhash().unwrap();
    let tx = Transaction::new_signed_with_payer(
        &[mint_ix],
        Some(&payer.pubkey()),
        &[&payer],
        recent_blockhash,
    );

    let signature = rpc_client.send_and_confirm_transaction(&tx).unwrap();

    let asset_id = get_asset_id(&tree, nonce);

    /*
        let data_hash = hash_metadata(&args).unwrap();
        let creator_hash = hash_creators(&args.creators);
        let leaf = LeafSchema::V1 {
            id: asset_id,
            owner,
            delegate: owner,
            nonce,
            data_hash,
            creator_hash,
        };
        // println!("Leaf: {:?}", leaf);
    */
    Ok((signature.to_string(), asset_id.to_string()))
}
