use rustler::{Decoder, Error, NifResult, Term};
use solana_client::rpc_client::RpcClient;
use solana_sdk::{pubkey::Pubkey, signature::Keypair};
use std::str::FromStr;

// Wrapper for PublicKey type
pub struct PubkeyWrapper(Pubkey);
impl<'a> Decoder<'a> for PubkeyWrapper {
    fn decode(term: Term<'a>) -> NifResult<Self> {
        let pubkey_string: String = term.decode()?;
        Ok(PubkeyWrapper(
            Pubkey::from_str(&pubkey_string).map_err(|_| Error::RaiseAtom("invalid_pubkey"))?,
        ))
    }
}

// Wrapper for Keypair type
pub struct KeypairWrapper(Keypair);
impl<'a> Decoder<'a> for KeypairWrapper {
    fn decode(term: Term<'a>) -> NifResult<Self> {
        match term.decode::<Vec<u8>>() {
            Ok(secret_key_vec) => {
                let secret_key_bytes: [u8; 64] = secret_key_vec
                    .as_slice()
                    .try_into()
                    .map_err(|_| Error::RaiseAtom("invalid_secret_key"))?;
                let keypair = Keypair::from_bytes(&secret_key_bytes)
                    .map_err(|_| Error::RaiseAtom("invalid_keypair"))?;
                Ok(KeypairWrapper(keypair))
            }
            // If it's not a binary, try to interpret it as a Base58 string
            Err(_) => {
                let bs58_string: String = term
                    .decode()
                    .map_err(|_| Error::RaiseAtom("invalid_input_format"))?;
                let decoded_bytes = bs58::decode(&bs58_string)
                    .into_vec()
                    .map_err(|_| Error::RaiseAtom("invalid_bs58_encoding"))?;
                let secret_key_bytes: [u8; 64] = decoded_bytes
                    .as_slice()
                    .try_into()
                    .map_err(|_| Error::RaiseAtom("invalid_secret_key_length"))?;
                let keypair = Keypair::from_bytes(&secret_key_bytes)
                    .map_err(|_| Error::RaiseAtom("invalid_keypair"))?;
                Ok(KeypairWrapper(keypair))
            }
        }
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
