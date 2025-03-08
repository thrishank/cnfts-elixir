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
  def sign_and_send_transaction(raw_transaction, private_key, rpc_url) do
    with {:ok, _} <- validate_transaction(raw_transaction),
         {:ok, keypair} <- decode_private_key(private_key),
         {:ok, signed_tx} <- sign_transaction(raw_transaction, keypair),
         {:ok, encoded_tx} <- encode_transaction(signed_tx),
         {:ok, signature} <- send_transaction(encoded_tx, rpc_url) do
      {:ok, signature}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Validates the raw transaction format.
  """
  def validate_transaction(transaction) when is_binary(transaction) do
    if byte_size(transaction) < 8 do
      {:error, "Transaction too short"}
    else
      {:ok, transaction}
    end
  end
  def validate_transaction(_), do: {:error, "Transaction must be binary data"}

  @doc """
  Decodes a private key from a base58 encoded string or uses raw binary.
  """
  def decode_private_key(private_key) when is_binary(private_key) do
    # Check if it's likely a Base58 encoded key
    if String.match?(private_key, ~r/^[1-9A-HJ-NP-Za-km-z]{32,88}$/) do
      case Base58.decode(private_key) do
        {:ok, decoded} ->
          if byte_size(decoded) == 64 do
            {:ok, decoded}
          else
            {:error, "Invalid keypair length"}
          end
        :error -> {:error, "Invalid Base58 private key format"}
      end
    else
      # For raw binary, validate the length
      if byte_size(private_key) == 64 do
        {:ok, private_key}
      else
        {:error, "Invalid keypair length"}
      end
    end
  end
  def decode_private_key(_), do: {:error, "Private key must be binary data"}

  @doc """
  Signs a raw binary transaction with the provided keypair.
  Uses Ed25519 cryptography which is what Solana uses.
  """
  def sign_transaction(transaction, keypair) when is_binary(transaction) and is_binary(keypair) do
    try do
      # Extract the secret key and public key from keypair
      <<secret_key::binary-size(32), public_key::binary-size(32)>> = keypair

      # In Solana, we need to sign the message part of the transaction
      # This is a simplified version - in production you'd need to properly
      # parse the transaction format and handle the signature table

      signature = :crypto.sign(:eddsa, :none, transaction, [secret_key, :ed25519])

      # Construct signed transaction
      # Format: [signature_count(1 byte)][signature(64 bytes)][rest of transaction]
      signed_tx = <<1::8, signature::binary, transaction::binary>>

      {:ok, signed_tx}
    rescue
      e -> {:error, "Failed to sign transaction: #{inspect(e)}"}
    end
  end
  def sign_transaction(_, _), do: {:error, "Invalid transaction or keypair format"}

  @doc """
  Encodes a signed transaction for transmission.
  """
  def encode_transaction(signed_transaction) when is_binary(signed_transaction) do
    # Encode the signed transaction as Base64
    encoded = Base.encode64(signed_transaction)
    {:ok, encoded}
  end
  def encode_transaction(_), do: {:error, "Invalid signed transaction format"}

  @doc """
  Sends the transaction to the Solana blockchain via RPC.
  """
  def send_transaction(encoded_transaction, rpc_url) when is_binary(encoded_transaction) and is_binary(rpc_url) do
    # Prepare the JSON-RPC request payload
    payload = %{
      jsonrpc: "2.0",
      id: System.unique_integer([:positive]),
      method: "sendTransaction",
      params: [
        encoded_transaction,
        %{
          encoding: "base64",
          preflightCommitment: "confirmed",
          skipPreflight: false,
          maxRetries: 3
        }
      ]
    }

    headers = [
      {"Content-Type", "application/json"}
    ]

    # Send the request with timeout
    case HTTPoison.post(rpc_url, Jason.encode!(payload), headers, [timeout: 30_000, recv_timeout: 30_000]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"result" => signature}} ->
            {:ok, signature}
          {:ok, %{"error" => %{"message" => message}}} ->
            {:error, "RPC error: #{message}"}
          {:ok, %{"error" => error}} ->
            {:error, "RPC error: #{inspect(error)}"}
          {:error, decode_error} ->
            {:error, "Failed to decode JSON response: #{inspect(decode_error)}"}
        end
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "HTTP error #{status_code}: #{inspect(body)}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{inspect(reason)}"}
    end
  end
  def send_transaction(_, _), do: {:error, "Invalid transaction or RPC URL format"}
end

# Example usage:
#
# # Example with a raw binary transaction
# # The transaction would be an actual binary in your code
# transaction = <<1, 0, 1, 3, 23, 0, 5, 231, 185, 7, 89, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>
#
# # Your private key could be a base58 string or a raw binary
# private_key = "your_base58_private_key_here"
#
# result = SolanaTransactionSender.sign_and_send_transaction(
#   transaction,
#   private_key,
#   "https://api.mainnet-beta.solana.com"
# )
