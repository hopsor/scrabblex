defmodule Scrabblex.Games.LexiconEntry do
  use Ecto.Schema

  alias Scrabblex.Games.Lexicon

  schema "lexicon_entries" do
    field :name, :string
    belongs_to :lexicon, Lexicon
  end
end
