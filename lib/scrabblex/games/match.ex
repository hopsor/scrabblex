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

  @valid_dictionaries ~w(fise)

  schema "matches" do
    field :dictionary, :string
    field :status, :string
    has_many :players, Scrabblex.Games.Player

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(match, attrs) do
    match
    |> cast(attrs, [:dictionary, :status])
    |> validate_required([:dictionary, :status])
  end

  def create_changeset(match, attrs) do
    match
    |> cast(attrs, [:dictionary])
    |> cast_assoc(:players)
    |> put_change(:status, "created")
    |> validate_required(:dictionary)
    |> validate_inclusion(:dictionary, @valid_dictionaries)
    |> validate_length(:players, is: 1)
  end

  def valid_dictionaries, do: @valid_dictionaries

  def owner(%__MODULE__{players: players}), do: Enum.find(players, &(&1.owner == true))
end
