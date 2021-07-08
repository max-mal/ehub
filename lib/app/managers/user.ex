defmodule App.Managers.UserManager do
  require Ecto.Query

  def get_user!(id, repo \\ Storage.Repos.App), do: repo.get!(App.Schemas.User, id)
  
  def register({email, username, password}, repo) do
    case App.Schemas.User |> repo.get_by(email: email) do
      nil -> store(%App.Schemas.User{email: email, username: username, password: Bcrypt.Base.hash_password(password, Bcrypt.gen_salt(12, true))}, repo)
      _ -> {:error, :exists}
    end 
  end

  def findByLogin(login, repo) do
    App.Schemas.User |> Ecto.Query.where(email: ^login) |> Ecto.Query.or_where(username: ^login) |> repo.one
  end

  def store(data, repo) do
  	case repo.insert(data) do
  		{:ok, user} -> {:ok, user}
  		_ -> {:error, :store_error}
  	end
  end

  def verifyPassword(user, password) do
    Bcrypt.verify_pass(password, user.password)
  end

  def login({login, password}, repo) do
    case findByLogin(login, repo) do
      nil -> false
      user -> {verifyPassword(user, password), user}
    end    
  end

  def updateProfile(user, data, repo) do
    changeset = App.Schemas.User.update_profile_changeset(user, data)
    repo.update(changeset)
  end

  def setPassword(user, password, repo) do
    changeset = App.Schemas.User.changeset(user, %{password: Bcrypt.Base.hash_password(password, Bcrypt.gen_salt(12, true))})
    repo.update(changeset)
  end
end