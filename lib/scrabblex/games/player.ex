defmodule Scrabblex.Games.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field :owner, :boolean, default: false
    field :match_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:owner, :user_id])
    |> validate_required([:owner, :user_id])
  end
end
