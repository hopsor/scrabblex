defmodule Scrabblex.Games.Player do
  use Ecto.Schema
  import Ecto.Changeset
  alias Scrabblex.Games.Match
  alias Scrabblex.Accounts.User

  schema "players" do
    field :owner, :boolean, default: false
    belongs_to :match, Match
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:owner, :user_id])
    |> validate_required([:owner, :user_id])
  end
end
