defmodule CoursePlanner.VolunteerControllerTest do
  use CoursePlannerWeb.ConnCase
  alias CoursePlanner.{Repo, Accounts.User}

  import CoursePlanner.Factory

  setup do
    {:ok, conn: login_as(:coordinator)}
  end

  defp login_as(user_type) do
    user_type
    |> insert()
    |> guardian_login_html()
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, volunteer_path(conn, :index)
    assert html_response(conn, 200) =~ "Volunteers"
  end

  test "lists all entries on index for supervisor" do
    conn = login_as(:supervisor)
    conn = get conn, volunteer_path(conn, :index)
    assert html_response(conn, 200) =~ "Volunteers"
  end

  test "shows chosen resource", %{conn: conn} do
    volunteer = insert(:volunteer)
    conn = get conn, volunteer_path(conn, :show, volunteer)
    assert html_response(conn, 200) =~ "#{volunteer.name} #{volunteer.family_name}"
  end

  test "shows chosen resource for supervisor" do
    conn = login_as(:supervisor)
    volunteer = insert(:volunteer)
    conn = get conn, volunteer_path(conn, :show, volunteer)
    assert html_response(conn, 200) =~ "#{volunteer.name} #{volunteer.family_name}"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    conn = get conn, volunteer_path(conn, :show, -1)
    assert html_response(conn, 404)
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    volunteer = insert(:volunteer, %{name: "Foo", family_name: "Bar"})
    conn = get conn, volunteer_path(conn, :edit, volunteer)
    assert html_response(conn, 200) =~ "Foo Bar"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    volunteer = insert(:volunteer, %{})
    conn = put conn, volunteer_path(conn, :update, volunteer), %{"user" => %{"email" => "foo@bar.com"}}
    assert redirected_to(conn) == volunteer_path(conn, :show, volunteer)
    assert Repo.get_by(User, email: "foo@bar.com")
  end

  test "does not updates if the resource does not exist", %{conn: conn} do
    conn = put conn, volunteer_path(conn, :update, -1), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 404)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    volunteer = insert(:volunteer, %{name: "Foo", family_name: "Bar"})
    conn = put conn, volunteer_path(conn, :update, volunteer), %{"user" => %{"email" => "not email"}}
    assert html_response(conn, 200) =~ "Foo Bar"
  end

  test "deletes chosen resource", %{conn: conn} do
    volunteer = insert(:volunteer)
    conn = delete conn, volunteer_path(conn, :delete, volunteer)
    assert redirected_to(conn) == volunteer_path(conn, :index)
    refute Repo.get(User, volunteer.id)
  end

  test "does not delete chosen resource when does not exist", %{conn: conn} do
      conn = delete conn, volunteer_path(conn, :delete, "-1")
      assert redirected_to(conn) == volunteer_path(conn, :index)
      assert get_flash(conn, "error") == "Volunteer was not found."
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, volunteer_path(conn, :new)
    assert html_response(conn, 200) =~ "New volunteer"
  end

  test "does not shows chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    volunteer = insert(:volunteer)

    conn = get student_conn, volunteer_path(student_conn, :show, volunteer)
    assert html_response(conn, 403)

    conn = get teacher_conn, volunteer_path(teacher_conn, :show, volunteer)
    assert html_response(conn, 403)

    conn = get volunteer_conn, volunteer_path(volunteer_conn, :show, volunteer)
    assert html_response(conn, 403)
  end

  test "does not list entries on index for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)

    conn = get student_conn, volunteer_path(student_conn, :index)
    assert html_response(conn, 403)

    conn = get teacher_conn, volunteer_path(teacher_conn, :index)
    assert html_response(conn, 403)

    conn = get volunteer_conn, volunteer_path(volunteer_conn, :index)
    assert html_response(conn, 403)
  end

  test "does not renders form for editing chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)
    supervisor_conn = login_as(:supervisor)

    volunteer = insert(:volunteer)

    conn = get student_conn, volunteer_path(student_conn, :edit, volunteer)
    assert html_response(conn, 403)

    conn = get teacher_conn, volunteer_path(teacher_conn, :edit, volunteer)
    assert html_response(conn, 403)

    conn = get volunteer_conn, volunteer_path(volunteer_conn, :edit, volunteer)
    assert html_response(conn, 403)

    conn = get supervisor_conn, volunteer_path(supervisor_conn, :edit, volunteer)
    assert html_response(conn, 403)
  end

  test "does not delete a chosen resource for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)
    supervisor_conn = login_as(:supervisor)

    volunteer = insert(:volunteer)

    conn = delete student_conn, volunteer_path(student_conn, :delete, volunteer.id)
    assert html_response(conn, 403)

    conn = delete teacher_conn, volunteer_path(teacher_conn, :delete, volunteer.id)
    assert html_response(conn, 403)

    conn = delete volunteer_conn, volunteer_path(volunteer_conn, :delete, volunteer.id)
    assert html_response(conn, 403)

    conn = delete supervisor_conn, volunteer_path(supervisor_conn, :delete, volunteer.id)
    assert html_response(conn, 403)
  end

  test "does not render form for new volunteer for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)
    supervisor_conn = login_as(:supervisor)

    conn = get student_conn, volunteer_path(student_conn, :new)
    assert html_response(conn, 403)

    conn = get teacher_conn, volunteer_path(teacher_conn, :new)
    assert html_response(conn, 403)

    conn = get volunteer_conn, volunteer_path(volunteer_conn, :new)
    assert html_response(conn, 403)

    conn = get supervisor_conn, volunteer_path(supervisor_conn, :new)
    assert html_response(conn, 403)
  end

  test "create volunteer for coordinator user", %{conn: conn} do
    conn = post conn, volunteer_path(conn, :create), %{"user" => %{"email" => "foo@bar.com"}}
    assert redirected_to(conn) == volunteer_path(conn, :index)
    assert get_flash(conn, "info") == "Volunteer created and notified by."
  end

  test "does not create volunteer for coordinator user when data is wrong", %{conn: conn} do
    conn = post conn, volunteer_path(conn, :create), %{"user" => %{"email" => ""}}
    assert html_response(conn, 200) =~ "Something went wrong."
  end

  test "does not create volunteer for non coordinator user", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)
    supervisor_conn = login_as(:supervisor)

    conn = post student_conn, volunteer_path(student_conn, :create), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)

    conn = post teacher_conn, volunteer_path(teacher_conn, :create), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)

    conn = post volunteer_conn, volunteer_path(volunteer_conn, :create), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)

    conn = post supervisor_conn, volunteer_path(supervisor_conn, :create), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)
  end

  test "does not update chosen volunteer for non coordinator use", %{conn: _conn} do
    student_conn   = login_as(:student)
    teacher_conn   = login_as(:teacher)
    volunteer_conn = login_as(:volunteer)
    supervisor_conn = login_as(:supervisor)

    volunteer = insert(:volunteer)

    conn = put student_conn, volunteer_path(student_conn, :update, volunteer), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)

    conn = put teacher_conn, volunteer_path(teacher_conn, :update, volunteer), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)

    conn = put volunteer_conn, volunteer_path(volunteer_conn, :update, volunteer), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)

    conn = put supervisor_conn, volunteer_path(supervisor_conn, :update, volunteer), %{"user" => %{"email" => "foo@bar.com"}}
    assert html_response(conn, 403)
  end

  test "show the volunteer himself" do
    volunteer = insert(:volunteer)
    volunteer_conn = guardian_login_html(volunteer)

    conn = get volunteer_conn, volunteer_path(volunteer_conn, :show, volunteer)
    assert html_response(conn, 200) =~ "#{volunteer.name} #{volunteer.family_name}"
  end

  test "edit the volunteer himself" do
    volunteer = insert(:volunteer, name: "Foo", family_name: "Bar")
    volunteer_conn = guardian_login_html(volunteer)

    conn = get volunteer_conn, volunteer_path(volunteer_conn, :edit, volunteer)
    assert html_response(conn, 200) =~ "Foo Bar"
  end

  test "update the volunteer himself" do
    volunteer = insert(:volunteer)
    volunteer_conn = guardian_login_html(volunteer)

    conn = put volunteer_conn, volunteer_path(volunteer_conn, :update, volunteer), %{"user" => %{"email" => "foo@bar.com"}}
    assert redirected_to(conn) == volunteer_path(conn, :show, volunteer)
    assert Repo.get_by(User, email: "foo@bar.com")
  end
end
