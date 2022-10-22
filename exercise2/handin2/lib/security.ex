defmodule Handin2.Security do
  use TypeCheck

  alias Handin2.Utils

  def config(:cert) do
    person = Utils.get_player_name()
    "priv/cert/#{person}/#{person}.crt"
  end

  def config(:privatekey) do
    person = Utils.get_player_name()
    "priv/cert/#{person}/#{person}.key"
  end

  def config(:cacert) do
    "priv/cert/ca/rootCA.crt"
  end
end
