defmodule BanchanWeb.DiscoverLive.Components.Offerings do
  @moduledoc """
  Offerings result listing for the Discover page.
  """
  use BanchanWeb, :live_component

  alias Surface.Components.{LivePatch, LiveRedirect}

  alias Banchan.Accounts
  alias Banchan.Offerings

  alias BanchanWeb.Components.InfiniteScroll
  alias BanchanWeb.StudioLive.Components.OfferingCard

  prop current_user, :struct, from_context: :current_user
  prop query, :string
  prop order_by, :atom, default: :featured
  prop page_size, :integer, default: 24
  prop infinite, :boolean, default: true
  prop suggest_studios, :boolean, default: false

  data offerings, :list

  def update(assigns, socket) do
    socket = socket |> assign(assigns)
    {:ok, socket |> assign(offerings: list_offerings(socket))}
  end

  @impl true
  def handle_event("load_more", _, socket) do
    if socket.assigns.offerings.total_entries >
         socket.assigns.offerings.page_number * socket.assigns.offerings.page_size do
      {:noreply, fetch_results(socket.assigns.offerings.page_number + 1, socket)}
    else
      {:noreply, socket}
    end
  end

  defp list_offerings(socket, page \\ 1) do
    Offerings.list_offerings(
      current_user: socket.assigns.current_user,
      order_by: socket.assigns.order_by || :featured,
      query: socket.assigns.query,
      page_size: socket.assigns.page_size,
      page: page
    )
  end

  defp fetch_results(page, %{assigns: %{offerings: offerings}} = socket) do
    socket
    |> assign(
      :offerings,
      %{
        offerings
        | page_number: page,
          entries: offerings.entries ++ list_offerings(socket, page).entries
      }
    )
  end

  @impl true
  def render(assigns) do
    params =
      if assigns.query && assigns.query != "" do
        %{q: assigns.query}
      else
        %{}
      end

    ~F"""
    <discover-offerings class="flex flex-col items-center">
      {#if !is_nil(@current_user) && Accounts.artist?(@current_user)}
        <div class="pb-2">
          Looking for your own offerings? Go to the <LiveRedirect class="link" to={~p"/studios"}>My Studios</LiveRedirect> page and select a studio.
        </div>
      {/if}
      {#if Enum.empty?(@offerings)}
        <div class="text-2xl">No Results</div>
        {#if @suggest_studios}
          <LivePatch class="link" to={Routes.discover_index_path(Endpoint, :index, "studios", params)}>Search Studios instead.</LivePatch>
        {/if}
      {#else}
        <div class="offering-list grid grid-cols-2 sm:gap-2 sm:grid-cols-3 md:grid-cols-4 xl:grid-cols-5 auto-rows-fr">
          {#for {offering, idx} <- Enum.with_index(@offerings)}
            <OfferingCard id={"offering-#{idx}"} current_user={@current_user} offering={offering} />
          {/for}
        </div>
        {#if @infinite}
          <InfiniteScroll
            id="offerings-infinite-scroll"
            page={@offerings.page_number}
            load_more="load_more"
          />
        {/if}
      {/if}
    </discover-offerings>
    """
  end
end
