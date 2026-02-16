defmodule TheStoryVoyageApiWeb.BuddyReadJSON do
  alias TheStoryVoyageApi.Communities.BuddyRead

  @doc """
  Renders a list of buddy_reads.
  """
  def index(%{buddy_reads: buddy_reads}) do
    %{data: for(buddy_read <- buddy_reads, do: data(buddy_read))}
  end

  @doc """
  Renders a single buddy_read.
  """
  def show(%{buddy_read: buddy_read}) do
    %{data: data(buddy_read)}
  end

  defp data(%BuddyRead{} = buddy_read) do
    %{
      id: buddy_read.id,
      start_date: buddy_read.start_date,
      status: buddy_read.status,
      book_id: buddy_read.book_id,
      creator_id: buddy_read.creator_id,
      inserted_at: buddy_read.inserted_at,
      book: if(Ecto.assoc_loaded?(buddy_read.book), do: book_data(buddy_read.book), else: nil),
      creator:
        if(Ecto.assoc_loaded?(buddy_read.creator), do: user_data(buddy_read.creator), else: nil),
      participants:
        if(Ecto.assoc_loaded?(buddy_read.participants),
          do: participants_data(buddy_read.participants),
          else: []
        )
    }
  end

  defp book_data(book) do
    %{
      id: book.id,
      title: book.title
    }
  end

  defp user_data(user) do
    %{
      id: user.id,
      username: user.username,
      avatar_url: user.avatar_url
    }
  end

  defp participants_data(participants) do
    for p <- participants do
      %{
        user_id: p.user_id,
        user: if(Ecto.assoc_loaded?(p.user), do: user_data(p.user), else: nil),
        joined_at: p.inserted_at
      }
    end
  end
end
