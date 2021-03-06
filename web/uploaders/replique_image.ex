defmodule Peter.RepliqueImage do
  use Arc.Definition
  use Arc.Ecto.Definition

  # Include ecto support (requires package arc_ecto installed):
  # use Arc.Ecto.Definition
  @acl :public_read
  @versions [:original, :thumb]

  # To add a thumbnail version:
  # @versions [:original, :thumb]

  # Whitelist file extensions:
  def validate({file, _}) do
    ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.file_name))
  end

  # Define a thumbnail transformation:
  def transform(:thumb, _) do
    {:convert, "-strip -thumbnail 250x250^ -gravity center -extent 250x250 -format jpg", :jpg}
  end

  # Override the persisted filenames:
  def filename(version, {file, scope}) do
    file_name =
      Path.basename(file.file_name, Path.extname(file.file_name))
      |> String.normalize(:nfd)
      |> String.replace(~r/[^A-z\s]/u, "")
      |> String.replace(~r/\s/, "-")

    hash = Base.encode64(file_name)

    "#{version}_#{file_name}_#{hash}"
  end

  # Override the storage directory:
  def storage_dir(version, {file, scope}) do
    "uploads/repliques/images"
  end

  def s3_object_headers(version, {file, scope}) do
    [content_type: Plug.MIME.path(file.file_name)]
  end

end
