defmodule Ex338.Router do
  use Ex338.Web, :router
  use ExAdmin.Router
  use Coherence.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, login: true
  end

  pipeline :public do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session
  end

  pipeline :admin do
    plug :authorize_admin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :public
    coherence_routes :public
  end

  scope "/" do
    pipe_through :browser
    coherence_routes :private
  end

  scope "/", Ex338 do
    pipe_through :public

    resources "/fantasy_leagues", FantasyLeagueController, only: [:show] do
      resources "/fantasy_teams", FantasyTeamController, only: [:index]
      resources "/fantasy_players", FantasyPlayerController, only: [:index]
      resources "/draft_picks", DraftPickController, only: [:index]
      resources "/waivers", WaiverController, only: [:index]
      resources "/trades", TradeController, only: [:index]
      resources "/draft_pick_emails", DraftPickEmailController, only: [:index]
    end

    resources "/draft_pick_emails", DraftPickEmailController, only: [:show]

    get "/", PageController, :index
  end

  scope "/admin", ExAdmin do
    pipe_through [:browser, :admin]
    admin_routes
  end

  if Mix.env == :dev do
    scope "/dev" do
      pipe_through [:browser]

      forward "/mailbox", Plug.Swoosh.MailboxPreview, [base_path: "/dev/mailbox"]
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", Ex338 do
  #   pipe_through :api
  # end
end
