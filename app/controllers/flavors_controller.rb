class FlavorsController < MVCLI::Controller
  requires :flavors

  def index
    flavors.all
  end
end
