# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Banchan.Repo.insert!(%Banchan.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

{:ok, _root} =
  Banchan.Accounts.register_system(%{
    handle: "tteokbokki",
    name: "Tokki",
    bio:
      "Teokbokki (aka Tokki) is the manifestation of the Banchan system itself, taking care of various internal and automated tasks. They're also Banchan's mascot!"
  })

if Application.fetch_env!(:banchan, :env) == :dev do
  {:ok, user} =
    Banchan.Accounts.register_admin(%{
      handle: "sampleuser",
      email: "example@banchan.art",
      password: "foobarbazquux",
      password_confirmation: "foobarbazquux"
    })

  {:ok, _} = Banchan.Repo.transaction(Banchan.Accounts.confirm_user_multi(user))

  user = user |> Banchan.Repo.reload()

  {:ok, _} =
    Banchan.Notifications.update_user_notification_settings(user, %{
      commission_email: true,
      commission_web: true
    })

  {:ok, studio} =
    Banchan.Studios.new_studio(
      %Banchan.Studios.Studio{artists: [user]},
      %{
        handle: "kitteh_studio",
        name: "Kitteh Studio",
        country: "US",
        default_currency: "USD",
        payment_currencies: ["USD", "EUR"]
      }
    )

  {:ok, _} =
    Banchan.Offerings.new_offering(
      user,
      studio,
      %{
        type: "illustration",
        index: 0,
        name: "Illustration",
        description: "A detailed illustration with full rendering and background.",
        open: true,
        hidden: false,
        max_proposals: 3,
        currency: :USD,
        options: [
          %{
            name: "Base Price",
            description: "The commission itself.",
            price: Money.new(10000, :USD),
            default: true,
            sticky: true
          },
          %{
            name: "Extra Character",
            description: "Add another character to the illustration.",
            price: Money.new(500, :USD),
            multiple: true
          },
          %{
            name: "Full background",
            description: "Add full background.",
            price: Money.new(4500, :USD)
          }
        ]
      },
      nil
    )

  {:ok, _} =
    Banchan.Offerings.new_offering(
      user,
      studio,
      %{
        type: "chibi",
        index: 1,
        name: "Chibi",
        description: "Big eyes, small mouth, tiny body, big heart.",
        open: true,
        hidden: true,
        slots: 3,
        currency: :USD,
        options: [
          %{
            name: "Base Price",
            description: "One chibi character, to order.",
            price: Money.new(5000, :USD),
            default: true,
            sticky: true
          },
          %{
            name: "Extra Character",
            description: "Add an extra character to the commission.",
            price: Money.new(2500, :USD),
            multiple: true
          }
        ],
        terms: "**No NFTs**. But also no derivative works."
      },
      nil
    )

  {:ok, studio} =
    Banchan.Studios.new_studio(
      %Banchan.Studios.Studio{artists: [user]},
      %{
        handle: "kitteh_japan",
        name: "Kitteh Studio in Japan",
        country: "JP",
        default_currency: "JPY",
        payment_currencies: ["JPY", "USD", "KRW"]
      }
    )

  {:ok, _} =
    Banchan.Offerings.new_offering(
      user,
      studio,
      %{
        type: "illustration",
        index: 0,
        name: "Illustration",
        description: "A detailed illustration with full rendering and background.",
        open: true,
        hidden: false,
        max_proposals: 3,
        currency: :USD,
        options: [
          %{
            name: "Base Price",
            description: "The commission itself.",
            price: Money.new(10000, :USD),
            default: true,
            sticky: true
          },
          %{
            name: "Extra Character",
            description: "Add another character to the illustration.",
            price: Money.new(500, :USD),
            multiple: true
          },
          %{
            name: "Full background",
            description: "Add full background.",
            price: Money.new(4500, :USD)
          }
        ]
      },
      nil
    )
end
