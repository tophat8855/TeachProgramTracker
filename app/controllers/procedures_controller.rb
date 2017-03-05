class ProceduresController < ApplicationController
  def index
  	@procedures = Procedure.all
  end
end
