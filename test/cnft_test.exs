defmodule CNFTTest do
  use ExUnit.Case, async: true
  import Mox
  import ExUnit.CaptureIO

  @rpc_client "https://api.devnet.solana.com"
  @private_key "3kSPdPULig47U2UzcsTxVBmSP6Ddor2W9bA1oc6ThJGET6fCFU5QMs7L1Azh9zBB83GuTXZSBGhBVTy1LmLBWto7"
  @owner_key "5Z6TZ11JkxyeXgZ8a1UyuWcp1BZ7QsySNWWRpmx9qgDK"
  @receiver_key "thrbabBvANwvKdV34GdrFUDXB6YMsksdfmiKj2ZUV3m"
  @invalid_key "invalid_key"
  @invalid_rpc "https://invalid.rpc.endpoint"

  setup :verify_on_exit!

  test "create function returns valid tree and signature" do
    capture_io(fn ->
      {create_sig, tree} = CNFT.create_tree_config(@rpc_client, @private_key, 14, 64)
      IO.inspect({create_sig, tree})
      assert is_binary(create_sig)
      assert is_binary(tree)
    end)
  end

  test "mint function returns valid asset ID and signature" do
    capture_io(fn ->
      {create_sig, tree} = CNFT.create_tree_config(@rpc_client, @private_key, 14, 64)

      {mint_sig, asset_id} =
        CNFT.mint_v1(
          @rpc_client,
          tree,
          @owner_key,
          @private_key,
          "Name",
          "SYM",
          "uri",
          100,
          true,
          0
        )

      assert is_binary(mint_sig)
      assert is_binary(asset_id)
    end)
  end

  test "Transfer function returns valid signature" do
    capture_io(fn ->
      {create_sig, tree} = CNFT.create_tree_config(@rpc_client, @private_key, 14, 64)

      {mint_sig, asset_id} =
        CNFT.mint_v1(
          @rpc_client,
          tree,
          @owner_key,
          @private_key,
          "Name",
          "SYM",
          "uri",
          100,
          true,
          0
        )

      transfer_sig = CNFT.transfer(@rpc_client, asset_id, @owner_key, @private_key, @receiver_key)
      assert is_binary(transfer_sig)
    end)
  end

  test "create_tree_config fails with invalid RPC endpoint" do
    capture_io(fn ->
      assert_raise ErlangError, ~r/failed_to_get_rent/, fn ->
        CNFT.create_tree_config(@invalid_rpc, @private_key, 14, 64)
      end
    end)
  end

  test "create_tree_config fails with invalid private key" do
    capture_io(fn ->
      assert_raise ErlangError, ~r/invalid_bs58_encoding/, fn ->
        CNFT.create_tree_config(@rpc_client, @invalid_key, 14, 64)
      end
    end)
  end

  test "create_tree_config fails with negative depth" do
    capture_io(fn ->
      assert_raise ArgumentError, fn ->
        CNFT.create_tree_config(@rpc_client, @private_key, -1, 64)
      end
    end)
  end

  test "mint_v1 fails with invalid tree address" do
    capture_io(fn ->
      assert_raise ErlangError, ~r/invalid_pubkey/, fn ->
        CNFT.mint_v1(
          @rpc_client,
          "invalid_tree_address",
          @owner_key,
          @private_key,
          "Name",
          "SYM",
          "uri",
          100,
          true,
          0
        )
      end
    end)
  end

  test "transfer fails with invalid asset ID" do
    capture_io(fn ->
      assert_raise ErlangError, ~r/invalid_pubkey/, fn ->
        CNFT.transfer(@rpc_client, "invalid_asset_id", @owner_key, @private_key, @receiver_key)
      end
    end)
  end

  test "transfer fails with invalid receiver key" do
    capture_io(fn ->
      {_, tree} = CNFT.create_tree_config(@rpc_client, @private_key, 14, 64)

      {_, asset_id} =
        CNFT.mint_v1(
          @rpc_client,
          tree,
          @owner_key,
          @private_key,
          "Name",
          "SYM",
          "uri",
          100,
          true,
          0
        )

      assert_raise ErlangError, ~r/invalid_pubkey/, fn ->
        CNFT.transfer(@rpc_client, asset_id, @owner_key, @private_key, @invalid_key)
      end
    end)
  end
end
