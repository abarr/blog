defmodule Blog.Posts do
  @moduledoc """
  The Posts context.
  """

  alias Blog.Posts.Post

  for app <- [:earmark] do
    Application.ensure_all_started(app)
  end

  posts_paths = "posts/**/*.md" |> Path.wildcard() |> Enum.sort()
  IO.inspect(posts_paths)

  posts =
    for post_path <- posts_paths do
      @external_resource Path.relative_to_cwd(post_path)
      Post.parse!(post_path)
    end

  @posts Enum.sort_by(posts, & &1.date, {:desc, Date})

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    @posts
  end

  @doc """
  Returns post by id.

  ## Examples

      iex> get_post!("latest-post")
      %Post{}

  """
  def get_post!(id) do
    Enum.find(list_posts(), &(&1.id == id))
  end

  @doc """
  Returns post by id.

  ## Examples

      iex> get_post!("latest-post")
      %Post{}

  """
  def get_latest_post!() do
    Enum.at(list_posts(),0)
  end


end
