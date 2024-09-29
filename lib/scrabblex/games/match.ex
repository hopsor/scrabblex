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
  alias Scrabblex.SupervisedSqids
  alias Scrabblex.Games.{Lexicon, Play, Player, Tile}

  @derive {Phoenix.Param, key: :friendly_id}

  schema "matches" do
    field :status, :string
    field :turn, :integer
    field :friendly_id, :string
    embeds_many :bag, Tile, on_replace: :delete
    belongs_to :lexicon, Lexicon
    has_many :players, Player, preload_order: [:id]
    has_many :plays, Play, preload_order: [desc: :id]

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
    |> prepare_changes(fn changeset ->
      case changeset do
        %Ecto.Changeset{action: :insert, valid?: true} ->
          {:ok, %Postgrex.Result{rows: [[match_id]]}} =
            changeset.repo.query("SELECT NEXTVAL('matches_id_seq')")

          friendly_id = SupervisedSqids.encode!([match_id])

          changeset
          |> put_change(:id, match_id)
          |> put_change(:friendly_id, friendly_id)

        _ ->
          changeset
      end
    end)
  end

  def start_changeset(match, attrs) do
    match
    |> cast(attrs, [])
    |> cast_embed(:bag, required: true)
    |> put_assoc(:players, attrs[:players])
    |> put_change(:status, "started")
  end

  def play_changeset(%__MODULE__{turn: turn} = match, attrs) do
    match
    |> cast(attrs, [:status])
    |> change(turn: turn + 1)
    |> put_embed(:bag, attrs[:bag])
  end

  def skip_turn_changeset(%__MODULE__{turn: turn} = match) do
    match
    |> change(turn: turn + 1)
  end

  def exchange_tiles_changeset(%__MODULE__{turn: turn} = match, attrs) do
    match
    |> cast(attrs, [])
    |> change(turn: turn + 1)
    |> put_embed(:bag, attrs[:bag])
  end

  def owner(%__MODULE__{players: players}), do: Enum.find(players, &(&1.owner == true))
end
