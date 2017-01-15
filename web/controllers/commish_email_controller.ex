defmodule Ex338.CommishEmailController do
  use Ex338.Web, :controller
  alias Ex338.{Repo, FantasyLeague, CommishEmail}

  def new(conn, _params) do
    render(conn, "new.html",
      fantasy_leagues: Repo.all(FantasyLeague)
    )
  end

  def create(conn, %{"commish_email" => %{
    "leagues" => leagues,
    "subject" => subject,
    "message" => message
  }}) do
    result = CommishEmail.send_email_to_leagues(leagues, subject, message)

    case result do
      {:ok, _result} ->
        conn
        |> put_flash(:info, "Email sent successfully")
        |> redirect(to: commish_email_path(conn, :new))
      {:error, _reason} ->
        conn
        |> put_flash(:error, "There was an error while sending the email")
        |> redirect(to: commish_email_path(conn, :new))
    end
  end
end