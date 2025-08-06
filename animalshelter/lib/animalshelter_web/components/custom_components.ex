defmodule AnimalshelterWeb.CustomComponents do
  use AnimalshelterWeb, :html

  attr :status, :atom, values: [:upcoming, :open, :close], default: :upcoming
  attr :class, :string, default: nil
  def badge(assigns) do
    assigns = assign(assigns, :status_es, status_in_spanish(assigns.status))

    ~H"""
    <div class={[
      "apply rounded-md px-2 py-1 text-xs font-medium uppercase inline-block border",
      @status == :open && "text-lime-600 border-lime-600",
      @status == :upcoming && "text-amber-600 border-amber-600",
      @status == :close && "text-gray-600 border-gray-600",
      @class
    ]}>
      <%= @status_es %>
    </div>
    """
  end

  defp status_in_spanish(:upcoming), do: "Próximo"
  defp status_in_spanish(:open), do: "Abierto"
  defp status_in_spanish(:close), do: "Cerrado"

  slot :inner_block, required: true
  slot :details
  def banner(assigns) do
    ~H"""
    <div class="banner">
      <h1>
        <%= render_slot(@inner_block) %>
      </h1>
      <div class="details">
        <%= render_slot(@details) %>
      </div>
    </div>
    """
  end

end
