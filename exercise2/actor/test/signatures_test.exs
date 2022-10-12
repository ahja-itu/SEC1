defmodule Security.Signatures.Tests do
  use ExUnit.Case, async: false
  @g 666
  @p 6661
  @sk 414
  @pk 300

  describe "sign/4" do
    test "returns a tuple of two integers" do
      assert {r, s} = Security.Signatures.sign("hello", 1234, @g, @p)
      assert is_integer(r)
      assert is_binary(s)
      assert String.length(s) > 0
    end
  end

  describe "verify/5" do
    test "returns true if the signature is valid" do
      {r, s} = Security.Signatures.sign("hello", @sk, @g, @p)
      assert Security.Signatures.verify({r, s}, "hello", @g, @p, Security.Signatures.create_key(@g, @sk, @p))
    end

    test "returns false if the signature is invalid" do
      {r, s} = Security.Signatures.sign("hello", @sk, @g, @p)
      assert not Security.Signatures.verify({r, s}, "hello", @g, @p, Security.Signatures.create_key(@g, @sk + 1, @p))
    end
  end
end
