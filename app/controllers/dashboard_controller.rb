class DashboardController < ApplicationController
	before_action :authenticate_user!
	def show

		@designers = Designer.all

		@designers_count = @designers.count
	end
end
