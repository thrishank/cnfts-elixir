use rustler::{Decoder, Error, NifResult, Term};
use solana_client::rpc_client::RpcClient;
use solana_sdk::{pubkey::Pubkey, signature::Keypair};
use std::str::FromStr;

// Wrapper type for Pubkey
pub struct PubkeyWrapper(Pubkey);
impl<'a> Decoder<'a> for PubkeyWrapper {
    fn decode(term: Term<'a>) -> NifResult<Self> {
        let pubkey_string: String = term.decode()?;
        Ok(PubkeyWrapper(
            Pubkey::from_str(&pubkey_string).map_err(|_| Error::RaiseAtom("invalid_pubkey"))?,
        ))
    }
}

// Wrapper type for Keypair
pub struct KeypairWrapper(Keypair);
impl<'a> Decoder<'a> for KeypairWrapper {
    fn decode(term: Term<'a>) -> NifResult<Self> {
        let secret_key_vec: Vec<u8> = term.decode()?;
        let secret_key_bytes: [u8; 64] = secret_key_vec
            .as_slice()
            .try_into()
            .map_err(|_| Error::RaiseAtom("invalid_secret_key"))?;

        let keypair = Keypair::from_bytes(&secret_key_bytes)
            .map_err(|_| Error::RaiseAtom("invalid_keypair"))?;

        Ok(KeypairWrapper(keypair))
    }
}

// Wrapper type for RpcClient
pub struct RpcClientWrapper(RpcClient);
impl<'a> Decoder<'a> for RpcClientWrapper {
    fn decode(term: Term<'a>) -> NifResult<Self> {
        let rpc_url: String = term.decode()?;
        Ok(RpcClientWrapper(RpcClient::new(rpc_url)))
    }
}
pub mod instructions;

rustler::init!("Elixir.CNFT");
