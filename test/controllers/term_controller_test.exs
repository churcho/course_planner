defmodule CoursePlanner.TermControllerTest do
  use CoursePlanner.ConnCase

  alias CoursePlanner.Terms.Term
  alias CoursePlanner.User

  setup do
    user =
      %User{
        name: "Test User",
        email: "testuser@example.com",
        password: "secret",
        password_confirmation: "secret"
      }

    conn =
      Phoenix.ConnTest.build_conn()
      |> assign(:current_user, user)
    {:ok, conn: conn}
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, term_path(conn, :new)
    assert html_response(conn, 200) =~ "New term"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    valid_attrs =
      %{
        name: "Spring",
        start_date: %{day: 01, month: 01, year: 2010},
        end_date: %{day: 01, month: 06, year: 2010},
        status: "Planned"
      }
    conn = post conn, term_path(conn, :create), term: valid_attrs
    assert redirected_to(conn) == term_path(conn, :new)
    assert Repo.get_by(Term, valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    invalid_attrs =
      %{
        name: nil,
        status: "invalid-status"
      }
    conn = post conn, term_path(conn, :create), term: invalid_attrs
    assert html_response(conn, 200) =~ "New term"
  end
end