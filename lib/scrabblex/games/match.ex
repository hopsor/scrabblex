defmodule Scrabblex.Games.Match do
  @moduledoc """
  The Match module contains the main data of a Scrabblex match.

  Status will transition in the following way:

  created -> started -> finished

  When a Match is initially created other players will be able to join it before it's started.
  When the Match transitions to started no more players will be able to join.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Scrabblex.Games.{Lexicon, Play, Player, Tile}

  schema "matches" do
    field :status, :string
    field :turn, :integer
    embeds_many :bag, Tile, on_replace: :delete
    belongs_to :lexicon, Lexicon
    has_many :players, Player, preload_order: [:id]
    has_many :plays, Play, preload_order: [:id]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(match, attrs) do
    match
    |> cast(attrs, [:lexicon_id, :status])
    |> validate_required([:lexicon_id, :status])
  end

  def create_changeset(match, attrs) do
    match
    |> cast(attrs, [:lexicon_id])
    |> cast_assoc(:players, with: &Scrabblex.Games.Player.owner_changeset/2)
    |> put_change(:status, "created")
    |> put_change(:turn, 0)
    |> validate_required(:lexicon_id)
    |> validate_length(:players, is: 1)
  end

  def start_changeset(match, attrs) do
    match
    |> cast(attrs, [])
    |> cast_embed(:bag, required: true)
    |> put_assoc(:players, attrs[:players])
    |> put_change(:status, "started")
  end

  def turn_changeset(match, attrs) do
    match
    |> cast(attrs, [:turn, :status])
    |> put_embed(:bag, attrs[:bag])
    |> validate_required([:turn])
  end

  def owner(%__MODULE__{players: players}), do: Enum.find(players, &(&1.owner == true))
end
