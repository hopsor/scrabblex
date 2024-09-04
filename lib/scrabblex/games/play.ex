defmodule Scrabblex.Games.Play do
  use Ecto.Schema
  import Ecto.Changeset

  alias Scrabblex.Games.{Match, Player, Tile, Word}

  @valid_types ~w(play skip exchange)

  schema "plays" do
    field :score, :integer
    field :turn, :integer
    field :type, :string

    belongs_to :player, Player
    belongs_to :match, Match
    embeds_many :tiles, Tile
    embeds_many :words, Word

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(play, attrs) do
    play
    |> cast(attrs, [:turn, :match_id, :type, :player_id])
    |> put_embed(:tiles, attrs[:tiles])
    |> put_embed(:words, attrs[:words])
    |> validate_required([:turn, :match_id, :type, :player_id])
    |> validate_inclusion(:type, @valid_types)
    |> compute_score()
  end

  defp compute_score(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{words: words}} ->
        computed_score = words |> Enum.map(&get_field(&1, :score)) |> Enum.sum()
        put_change(changeset, :score, computed_score)

      _ ->
        changeset
    end
  end
end
