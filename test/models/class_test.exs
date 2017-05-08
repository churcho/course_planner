defmodule CoursePlanner.ClassTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.Class
  alias CoursePlanner.Course
  alias CoursePlanner.Repo

  @valid_course_attrs %{description: "some content", name: "some content", number_of_sessions: 42, session_duration: %{hour: 14, min: 0, sec: 0}, status: "Planned", syllabus: "some content"}
  @valid_attrs %{course_id: nil, date: %{day: 17, month: 4, year: 2010}, finishes_at: %{hour: 14, min: 0, sec: 0}, starting_at: %{hour: 14, min: 0, sec: 0}, status: "Planned"}
  @invalid_attrs %{}

  defp create_course do
    changeset = Course.changeset(%Course{}, @valid_course_attrs, :create)
    Repo.insert(changeset)
  end

  test "changeset with valid attributes" do
    {:ok, created_course} = create_course()
    changeset = Class.changeset(%Class{}, %{@valid_attrs | course_id: created_course.id})
    assert changeset.valid?
  end

  test "changeset with no attributes" do
    changeset = Class.changeset(%Class{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with no course_id" do
    changeset = Class.changeset(%Class{}, @valid_attrs)
    refute changeset.valid?
  end

  test "changeset with empty status" do
    {:ok, created_course} = create_course()
    changeset = Class.changeset(%Class{}, %{@valid_attrs | course_id: created_course.id, status: ""})
    refute changeset.valid?
  end

  test "changeset with status random" do
    {:ok, created_course} = create_course()
    changeset = Class.changeset(%Class{}, %{@valid_attrs | course_id: created_course.id, status: "Random"})
    refute changeset.valid?
  end

  test "changeset with status Active" do
    {:ok, created_course} = create_course()
    changeset = Class.changeset(%Class{}, %{@valid_attrs | course_id: created_course.id, status: "Active"})
    assert changeset.valid?
  end

  test "changeset with status Finished" do
    {:ok, created_course} = create_course()
    changeset = Class.changeset(%Class{}, %{@valid_attrs | course_id: created_course.id, status: "Finished"})
    assert changeset.valid?
  end

  test "changeset with status Graduated" do
    {:ok, created_course} = create_course()
    changeset = Class.changeset(%Class{}, %{@valid_attrs | course_id: created_course.id, status: "Graduated"})
    assert changeset.valid?
  end

  test "changeset with status Frozen" do
    {:ok, created_course} = create_course()
    changeset = Class.changeset(%Class{}, %{@valid_attrs | course_id: created_course.id, status: "Frozen"})
    assert changeset.valid?
  end
end