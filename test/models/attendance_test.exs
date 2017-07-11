defmodule CoursePlanner.AttendanceTest do
  use CoursePlanner.ModelCase

  alias CoursePlanner.{Attendance}
  import CoursePlanner.Factory

  @valid_class_attrs %{offered_course: nil, date: %{day: 17, month: 4, year: 2010}, finishes_at: %{hour: 14, min: 0, sec: 0}, starting_at: %{hour: 15, min: 0, sec: 0}}
  @valid_attrs %{student_id: nil, class_id: nil, attendance_type: "some content", comment: ""}
  @invalid_attrs %{}

  setup do
    insert(:system_variable, key: "ATTENDANCE_DESCRIPTORS", value: "sick leave, informed beforehand", type: "csv")

    student = insert(:user, %{role: "Student"})
    offered_course = insert(:offered_course, %{students: [student]})
    class = insert(:class, %{@valid_class_attrs | offered_course: offered_course})

    {:ok, %{student: student, class: class}}
  end

  test "changeset with valid attributes", context do
    changeset = Attendance.changeset(%Attendance{}, %{@valid_attrs | student_id: context.student.id, class_id: context.class.id})
    assert changeset.valid?
  end

  test "changeset with invalid attributes", _context do
    changeset = Attendance.changeset(%Attendance{}, @invalid_attrs)
    refute changeset.valid?
  end

  describe "attendance comment" do
    test "passes when comment is empty", context do
      changeset = Attendance.changeset(%Attendance{}, %{@valid_attrs | student_id: context.student.id, class_id: context.class.id, comment: ""})
      assert changeset.valid?
    end

    test "passes when comment is nil", context do
      changeset = Attendance.changeset(%Attendance{}, %{@valid_attrs | student_id: context.student.id, class_id: context.class.id, comment: nil})
      assert changeset.valid?
    end

    test "passes when comment is among valid options", context do
      changeset = Attendance.changeset(%Attendance{}, %{@valid_attrs | student_id: context.student.id, class_id: context.class.id, comment: "sick leave"})
      assert changeset.valid?
    end

    test "fails when comment is not among valid options", context do
      changeset = Attendance.changeset(%Attendance{}, %{@valid_attrs | student_id: context.student.id, class_id: context.class.id, comment: "random"})
      refute changeset.valid?
    end
  end
end
