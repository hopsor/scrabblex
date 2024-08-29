defmodule Scrabblex.Games.Player do
  use Ecto.Schema
  import Ecto.Changeset
  alias Scrabblex.Games.{Match, Tile}
  alias Scrabblex.Accounts.User

  schema "players" do
    field :owner, :boolean, default: false
    field :score, :integer, default: 0
    field :lock_version, :integer, default: 1

    belongs_to :match, Match
    belongs_to :user, User
    embeds_many :hand, Tile

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:owner, :user_id, :match_id])
    |> validate_required([:owner, :user_id, :match_id])
  end

  def start_changeset(player, attrs) do
    player
    |> cast(attrs, [])
    |> cast_embed(:hand, required: true)
  end

  def hand_changeset(player, hand) do
    player
    |> cast(%{}, [])
    |> put_embed(:hand, hand)
    |> optimistic_lock(:lock_version)
  end

  def owner_changeset(player, attrs) do
    player
    |> cast(attrs, [:user_id])
    |> put_change(:owner, true)
    |> validate_required([:user_id])
  end
end
