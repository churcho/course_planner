defmodule CoursePlanner.TermController do
  use CoursePlanner.Web, :controller

  alias CoursePlanner.Terms

  def new(conn, _params) do
    render(conn, "new.html", changeset: Terms.new)
  end

  def create(conn, %{"term" => term_params}) do
    case Terms.create_term(term_params) do
      {:ok, _term} ->
        conn
        |> put_flash(:info, "Term created successfully.")
        |> redirect(to: term_path(conn, :new))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end