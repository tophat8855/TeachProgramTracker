class ProceduresController < ApplicationController
  def index
  	@procedures = Procedure.all
  end

  def new
  	@procedures = Procedure.all
  end
end
