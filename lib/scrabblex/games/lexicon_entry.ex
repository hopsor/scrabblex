defmodule Scrabblex.Games.LexiconEntry do
  use Ecto.Schema
  import Ecto.Changeset

  alias Scrabblex.Games.Lexicon

  schema "lexicon_entries" do
    field :name, :string
    belongs_to :lexicon, Lexicon
  end

  def changeset(lexicon_entry, attrs) do
    lexicon_entry
    |> cast(attrs, [:name, :lexicon_id])
    |> validate_required([:name, :lexicon_id])
  end
end
