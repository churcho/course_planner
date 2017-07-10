defmodule CoursePlanner.AttendanceView do
  use CoursePlanner.Web, :view

  alias CoursePlanner.SharedView

  def get_teacher_display_name(offered_course_teachers) do
    offered_course_teachers
    |> Enum.map(fn(teacher) -> SharedView.display_user_name(teacher) end)
    |> Enum.join(", ")
  end
end
