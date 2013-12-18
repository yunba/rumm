class FlavorsController < MVCLI::Controller
  requires :compute

  def index
    compute.flavors.all
  end
end
