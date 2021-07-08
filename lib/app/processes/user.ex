defmodule App.Processes.User do	
	def register(data, repo) do
		App.Managers.UserManager.register(data, repo)
	end

	def signIn({login, password}, repo) do
		App.Managers.UserManager.login({login, password}, repo)
	end

	def updateProfile(user, data, repo) do
		App.Managers.UserManager.updateProfile(user, data, repo)
	end

	def confirm() do
		
	end

	def changePassword(user, password, repo) do
		App.Managers.UserManager.setPassword(user, password, repo)
	end	

	def delete() do
		
	end
end