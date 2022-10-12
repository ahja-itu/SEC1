defmodule Commitments.Tests do
  use ExUnit.Case, async: false

  setup do
    %{bitstring: :crypto.strong_rand_bytes(256)}
  end

  describe "create/1" do
    test "creates a commitment", %{bitstring: bitstring} do
      msg = "hello"
      {rmsg, hash} = Security.Commitments.create(msg)
      assert String.contains?(rmsg, msg)
      assert String.length(hash) >= 0
    end
  end

  describe "verify/2" do
    test "verifies a commitment", %{bitstring: bitstring} do
      msg = "hello"
      {rmsg, hash} = Security.Commitments.create(msg)
      assert Security.Commitments.verify(hash, rmsg) == :ok
    end
  end
end
