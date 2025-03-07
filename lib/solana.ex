defmodule SolanaTransactionSender do
  @moduledoc """
  Module for signing and sending raw Solana transactions represented as binary data.
  """

  @doc """
  Signs and sends a raw Solana transaction (binary data).

  ## Parameters
    - raw_transaction: Binary transaction data (as Elixir binary/bitstring)
    - private_key: The private key to sign the transaction with (can be Base58 encoded string)
    - rpc_url: The Solana RPC URL (defaults to mainnet)

  ## Returns
    - {:ok, signature} on success
    - {:error, reason} on failure
  """
  def sign_and_send_transaction(raw_transaction, private_key, rpc_url \\ "https://api.mainnet-beta.solana.com") do
    with {:ok, keypair} <- decode_private_key(private_key),
         {:ok, signed_tx} <- sign_transaction(raw_transaction, keypair),
         {:ok, encoded_tx} <- encode_transaction(signed_tx),
         {:ok, signature} <- send_transaction(encoded_tx, rpc_url) do
      {:ok, signature}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Decodes a private key from a base58 encoded string or uses raw binary.
  """
  def decode_private_key(private_key) when is_binary(private_key) do
    # Check if it's likely a Base58 encoded key
    if String.match?(private_key, ~r/^[1-9A-HJ-NP-Za-km-z]{32,88}$/) do
      case Base58.decode(private_key) do
        {:ok, decoded} -> {:ok, decoded}
        :error -> {:error, "Invalid Base58 private key format"}
      end
    else
      # Assume it's already binary data
      {:ok, private_key}
    end
  end

  @doc """
  Signs a raw binary transaction with the provided keypair.
  Uses Ed25519 cryptography which is what Solana uses.
  """
  def sign_transaction(transaction, keypair) when is_binary(transaction) and is_binary(keypair) do
    try do
      # Extract the secret key from keypair (first 32 bytes in Solana's keypair format)
      # Note: In a real implementation, you'd handle this based on your keypair format
      <<secret_key::binary-size(32), _public_key::binary-size(32)>> = keypair

      # Find the message part of the transaction that needs to be signed
      # In a real implementation, you'd need to parse the Solana transaction format properly
      # This is a simplified example assuming the transaction is already properly formatted
      # and just needs the signature added
      
      # Use native Erlang/Elixir crypto for Ed25519 signing
      signature = :crypto.sign(:eddsa, :none, transaction, secret_key, [curve: :ed25519])
      
      # In a real implementation, you would:
      # 1. Parse the transaction to find the signature table
      # 2. Insert the signature in the right position
      # 3. Update any necessary fields
      
      # This is a simplified approach - in a real implementation you'd need to properly
      # modify the transaction format according to Solana's specification
      signed_tx = transaction <> <<0>> <> signature
      
      {:ok, signed_tx}
    rescue
      e -> {:error, "Failed to sign transaction: #{inspect(e)}"}
    end
  end

  @doc """
  Encodes a signed transaction for transmission.
  """
  def encode_transaction(signed_transaction) when is_binary(signed_transaction) do
    # Encode the signed transaction as Base64
    encoded = Base.encode64(signed_transaction)
    {:ok, encoded}
  end

  @doc """
  Sends the transaction to the Solana blockchain via RPC.
  """
  def send_transaction(encoded_transaction, rpc_url) do
    # Prepare the JSON-RPC request payload
    payload = %{
      jsonrpc: "2.0",
      id: 1,
      method: "sendTransaction",
      params: [
        encoded_transaction,
        %{
          encoding: "base64",
          preflightCommitment: "confirmed",
          skipPreflight: false
        }
      ]
    }

    headers = [
      {"Content-Type", "application/json"}
    ]

    # Send the request
    case HTTPoison.post(rpc_url, Jason.encode!(payload), headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"result" => signature}} ->
            {:ok, signature}
          {:ok, %{"error" => error}} ->
            {:error, "RPC error: #{inspect(error)}"}
          {:error, decode_error} ->
            {:error, "Failed to decode JSON response: #{inspect(decode_error)}"}
        end
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "HTTP error: #{status_code}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{inspect(reason)}"}
    end
  end
end

# Example usage:
#
# # Example with a raw binary transaction
# # The transaction would be an actual binary in your code
# transaction = <<1, 0, 1, 3, 23, 0, 5, 231, 185, 7, 89, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>
# 
# # Your private key could be a base58 string or a raw binary
#
# result = SolanaTransactionSender.sign_and_send_transaction(
#   transaction,
#   private_key,
#   "https://api.mainnet-beta.solana.com"
# )
