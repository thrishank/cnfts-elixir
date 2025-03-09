defmodule CNFTTest do
  use ExUnit.Case, async: true
  import Mox
  import ExUnit.CaptureIO

  @rpc_client "https://api.devnet.solana.com"
  @private_key = []
  @owner_key = " "
  @receiver_key = " "

  setup :verify_on_exit!

  test "create function returns valid tree and signature" do
    capture_io(fn -> 
      {create_sig, tree} = CNFT.create(@rpc_client, @private_key)
      IO.inspect({create_sig, tree})
      assert is_binary(create_sig)
      assert is_binary(tree)
    end)
  end

  test "mint function returns valid asset ID and signature" do
    capture_io(fn -> 
      {create_sig, tree} = CNFT.create(@rpc_client, @private_key)
      {mint_sig, asset_id} = CNFT.mint(@rpc_client, tree, @owner_key, @private_key, "Name", "SYM", "uri", 0)
      assert is_binary(mint_sig)
      assert is_binary(asset_id)
    end)
  end

  test "Transfer function returns valid signature" do
    capture_io(fn -> 
      {create_sig, tree} = CNFT.create(@rpc_client, @private_key)
      {mint_sig, asset_id} = CNFT.mint(@rpc_client, tree, @owner_key, @private_key, "Name", "SYM", "uri", 0)
      transfer_sig = CNFT.transfer(@rpc_client, asset_id, @owner_key, @private_key, @receiver_key)
    end)
  end

end

