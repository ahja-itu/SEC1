defmodule Handin2.Commitments.Tests do
  use ExUnit.Case, async: false

  alias Handin2.Commitments

  describe "create/1" do
    test "creates a commitment" do
      msg = "hello"
     {rmsg, hash} = Commitments.create(msg)
      assert String.contains?(rmsg, msg)
      assert String.length(hash) >= 0
    end
  end

  describe "verify/2" do
    test "verifies a commitment" do
      msg = "hello"
      {rmsg, hash} = Commitments.create(msg)
      assert Commitments.verify(hash, rmsg) == :ok
    end
  end
end
