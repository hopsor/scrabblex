defmodule ScrabblexWeb.Admin.LexiconLiveTest do
  use ScrabblexWeb.ConnCase

  import Phoenix.LiveViewTest
  import Scrabblex.{AccountsFixtures, GamesFixtures}

  @create_attrs %{name: "some name", language: "english", flag: "🇬🇧"}
  @update_attrs %{name: "some updated name", language: "italian", flag: "🇮🇹"}
  @invalid_attrs %{name: "some name", language: ""}

  defp create_lexicon(_) do
    lexicon = lexicon_fixture()
    %{lexicon: lexicon}
  end

  defp login_admin_user(%{conn: conn}) do
    user = user_fixture(email: "admin@domain.com")

    %{conn: log_in_user(conn, user)}
  end

  describe "Index" do
    setup [:create_lexicon, :login_admin_user]

    test "lists all lexicons", %{conn: conn, lexicon: lexicon} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/lexicons")

      assert html =~ "Listing lexicons"
      assert html =~ lexicon.name
    end

    test "saves new lexicon", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/lexicons")

      assert index_live |> element("a", "New Lexicon") |> render_click() =~
               "New Lexicon"

      assert_patch(index_live, ~p"/admin/lexicons/new")

      assert index_live
             |> form("#lexicon-form", lexicon: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#lexicon-form", lexicon: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/lexicons")

      html = render(index_live)
      assert html =~ "Lexicon created successfully"
      assert html =~ "some name"
    end

    test "updates lexicon in listing", %{conn: conn, lexicon: lexicon} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/lexicons")

      assert index_live |> element("#lexicons-#{lexicon.id} td:first-child") |> render_click() =~
               "Edit Lexicon"

      assert_patch(index_live, ~p"/admin/lexicons/#{lexicon}/edit")

      assert index_live
             |> form("#lexicon-form", lexicon: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#lexicon-form", lexicon: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/lexicons")

      html = render(index_live)
      assert html =~ "Lexicon updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes lexicon in listing", %{conn: conn, lexicon: lexicon} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/lexicons")

      assert index_live |> element("#lexicons-#{lexicon.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#lexicons-#{lexicon.id}")
    end
  end

  describe "Entries" do
    setup [:create_lexicon, :login_admin_user]

    test "list entries of the lexicon", %{conn: conn, lexicon: lexicon} do
      lexicon_entry = lexicon_entry_fixture(%{lexicon_id: lexicon.id, name: "FOO"})

      {:ok, _entries_live, html} = live(conn, ~p"/admin/lexicons/#{lexicon}/entries")

      assert html =~ "Entries"
      assert html =~ lexicon_entry.name
    end

    # TODO: Test pagination and search

    test "reset entries", %{conn: conn, lexicon: lexicon} do
      lexicon_entry = lexicon_entry_fixture(%{lexicon_id: lexicon.id, name: "FOO"})

      {:ok, entries_live, _html} = live(conn, ~p"/admin/lexicons/#{lexicon}/entries")

      entries_live
      |> element("#reset-entries")
      |> render_click()

      refute render(entries_live) =~ lexicon_entry.name
    end

    test "upload entries", %{conn: conn, lexicon: lexicon} do
      {:ok, entries_live, _html} = live(conn, ~p"/admin/lexicons/#{lexicon}/entries")

      entries_file =
        file_input(entries_live, "#upload-form", :entries_file, [
          %{
            last_modified: 1_594_171_879_000,
            name: "sample_entries.txt",
            content: File.read!("test/support/fixtures/lexicon/sample_entries.txt"),
            type: "text/plain"
          }
        ])

      assert render_upload(entries_file, "sample_entries.txt") =~ "100%"

      assert entries_live
             |> element("#upload-form")
             |> render_submit(%{entries_file: entries_file}) =~ "1000"
    end
  end

  describe "Definitions" do
    setup [:create_lexicon, :login_admin_user]

    test "list entries of the lexicon", %{conn: conn, lexicon: lexicon} do
      {:ok, _entries_live, html} = live(conn, ~p"/admin/lexicons/#{lexicon}/bag_definitions")

      assert html =~ "Bag definitions"

      Enum.each(lexicon.bag_definitions, fn bag_definition ->
        assert html =~ bag_definition.value
        assert html =~ "#{bag_definition.score}"
        assert html =~ "#{bag_definition.amount}"
      end)
    end

    test "reset definitions", %{conn: conn, lexicon: lexicon} do
      {:ok, definitions_live, _html} = live(conn, ~p"/admin/lexicons/#{lexicon}/bag_definitions")

      assert definitions_live |> element("tbody#definitions tr") |> has_element?()

      definitions_live
      |> element("#reset-definitions")
      |> render_click()

      refute definitions_live |> element("tbody#definitions tr") |> has_element?()
    end

    test "upload definitions", %{conn: conn} do
      lexicon =
        lexicon_fixture(%{
          "name" => "another lexicon",
          "bag_definitions" => []
        })

      {:ok, bag_definitions_live, _html} =
        live(conn, ~p"/admin/lexicons/#{lexicon}/bag_definitions")

      definitions_csv =
        file_input(bag_definitions_live, "#upload-form", :definitions_csv, [
          %{
            last_modified: 1_594_171_879_000,
            name: "sample_bag_definitions.csv",
            content: File.read!("test/support/fixtures/lexicon/sample_bag_definitions.csv"),
            type: "text/csv"
          }
        ])

      assert render_upload(definitions_csv, "sample_bag_definitions.csv") =~ "100%"

      bag_definitions_live
      |> element("#upload-form")
      |> render_submit(%{definitions_csv: definitions_csv})

      assert bag_definitions_live
             |> element("tbody#definitions tr:nth-child(29)")
             |> has_element?()
    end
  end
end
