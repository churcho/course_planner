defmodule CoursePlanner.AttendanceHelper do
  @moduledoc """
  This module provides custom functionality for controller over the model
  """
  use CoursePlanner.Web, :model

  alias CoursePlanner.{Repo, OfferedCourse, Attendance}
  alias Ecto.Multi

  def get_course_attendances(offered_course_id) do
    Repo.one(from oc in OfferedCourse,
      join: s in assoc(oc, :students),
      join: c in assoc(oc, :classes),
      join: a in assoc(c,  :attendances),
      join: as in assoc(a, :student),
      join: ac in assoc(a, :class),
      preload: [:term, :course, :teachers, :students],
      preload: [classes: {c, attendances: {a, student: as, class: ac}}],
      where: oc.id == ^offered_course_id and is_nil(s.deleted_at),
      order_by: [asc: c.date])
  end

  def get_teacher_course_attendances(offered_course_id, teacher_id) do
    Repo.one(from oc in OfferedCourse,
      join: t in assoc(oc, :teachers),
      join: s in assoc(oc, :students),
      join: c in assoc(oc, :classes),
      join: a in assoc(c,  :attendances),
      preload: [:term, :course, teachers: t, students: s],
      preload: [classes: {c, attendances: a}],
      where: oc.id == ^offered_course_id and is_nil(s.deleted_at) and t.id == ^teacher_id,
      order_by: [asc: c.date])
  end

  def get_student_attendances(offered_course_id, student_id) do
    Repo.all(from a in Attendance,
      join: s in assoc(a, :student),
      join: c in assoc(a,  :class),
      join: oc in assoc(c, :offered_course),
      preload: [class: {c, [offered_course: {oc, [:course, :term]}]}, student: s],
      where: a.student_id == ^student_id and oc.id == ^offered_course_id,
      order_by: [asc: c.date])
  end

  def get_all_offered_courses do
    Repo.all(from oc in OfferedCourse,
      join: c in assoc(oc, :classes),
      join: s in assoc(oc, :students),
      join: t in assoc(oc, :teachers),
      preload: [:term, :course, teachers: t, students: s, classes: c])
  end

  def get_all_teacher_offered_courses(teacher_id) do
    Repo.all(from oc in OfferedCourse,
      join: t in assoc(oc, :teachers),
      join: c in assoc(oc, :classes),
      join: s in assoc(oc, :students),
      preload: [:term, :course, teachers: t, students: s, classes: c],
      where: t.id == ^teacher_id)
  end

  def get_all_student_offered_courses(student_id) do
    Repo.all(from oc in OfferedCourse,
      join: s in assoc(oc, :students),
      join: c in assoc(oc, :classes),
      join: t in assoc(oc, :teachers),
      preload: [:term, :course, teachers: t, students: s, classes: c],
      where: s.id == ^student_id)
  end

  def update_multiple_attendances(attendance_changeset_list) do
    multi = Multi.new

    updated_multi =
      attendance_changeset_list
      |> Enum.reduce(multi, fn(attendance_changeset, operation_list) ->
           operation_atom =
             attendance_changeset.data.id
             |> Integer.to_string()
             |> String.to_atom()

           Multi.update(operation_list, operation_atom, attendance_changeset)
         end)

    Repo.transaction(updated_multi)
  end
end