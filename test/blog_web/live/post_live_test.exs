defmodule BlogWeb.PostLiveTest do
  use BlogWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Blog.Posts

  @create_attrs %{author: "some author", body: "some body", date: ~N[2010-04-17 14:00:00], description: "some description", tags: "some tags", title: "some title"}
  @update_attrs %{author: "some updated author", body: "some updated body", date: ~N[2011-05-18 15:01:01], description: "some updated description", tags: "some updated tags", title: "some updated title"}
  @invalid_attrs %{author: nil, body: nil, date: nil, description: nil, tags: nil, title: nil}

  defp fixture(:post) do
    {:ok, post} = Posts.create_post(@create_attrs)
    post
  end

  defp create_post(_) do
    post = fixture(:post)
    %{post: post}
  end

  describe "Index" do
    setup [:create_post]

    test "lists all posts", %{conn: conn, post: post} do
      {:ok, _index_live, html} = live(conn, Routes.post_index_path(conn, :index))

      assert html =~ "Listing Posts"
      assert html =~ post.author
    end

    test "saves new post", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.post_index_path(conn, :index))

      assert index_live |> element("a", "New Post") |> render_click() =~
        "New Post"

      assert_patch(index_live, Routes.post_index_path(conn, :new))

      assert index_live
             |> form("#post-form", post: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#post-form", post: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.post_index_path(conn, :index))

      assert html =~ "Post created successfully"
      assert html =~ "some author"
    end

    test "updates post in listing", %{conn: conn, post: post} do
      {:ok, index_live, _html} = live(conn, Routes.post_index_path(conn, :index))

      assert index_live |> element("#post-#{post.id} a", "Edit") |> render_click() =~
        "Edit Post"

      assert_patch(index_live, Routes.post_index_path(conn, :edit, post))

      assert index_live
             |> form("#post-form", post: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#post-form", post: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.post_index_path(conn, :index))

      assert html =~ "Post updated successfully"
      assert html =~ "some updated author"
    end

    test "deletes post in listing", %{conn: conn, post: post} do
      {:ok, index_live, _html} = live(conn, Routes.post_index_path(conn, :index))

      assert index_live |> element("#post-#{post.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#post-#{post.id}")
    end
  end

  describe "Show" do
    setup [:create_post]

    test "displays post", %{conn: conn, post: post} do
      {:ok, _show_live, html} = live(conn, Routes.post_show_path(conn, :show, post))

      assert html =~ "Show Post"
      assert html =~ post.author
    end

    test "updates post within modal", %{conn: conn, post: post} do
      {:ok, show_live, _html} = live(conn, Routes.post_show_path(conn, :show, post))

      assert show_live |> element("a", "Edit") |> render_click() =~
        "Edit Post"

      assert_patch(show_live, Routes.post_show_path(conn, :edit, post))

      assert show_live
             |> form("#post-form", post: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#post-form", post: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.post_show_path(conn, :show, post))

      assert html =~ "Post updated successfully"
      assert html =~ "some updated author"
    end
  end
end
