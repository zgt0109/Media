class Api::Wmall::CategoriesController < Api::Wmall::BaseController
  # GET /api/wmall/categories
  # GET /api/wmall/categories.json
  def index
    @categories = current_mall.categories
  end

  # GET /api/wmall/categories/1
  # GET /api/wmall/categories/1.json
  def show
    @category = current_mall.categories.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @category }
    end
  end

  # GET /api/wmall/categories/new
  # GET /api/wmall/categories/new.json
  def new
    @category = current_mall.categories.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @category }
    end
  end

  # GET /api/wmall/categories/1/edit
  def edit
    @category = current_mall.categories.find(params[:id])
  end

  # POST /api/wmall/categories
  # POST /api/wmall/categories.json
  def create
    @category = current_mall.categories.new(params[:category])

    if @category.save
      render json: @category, status: :created
    else
      render json: @category.errors, status: :unprocessable_entity
    end
  end

  # PUT /api/wmall/categories/1
  # PUT /api/wmall/categories/1.json
  def update
    @category = current_mall.categories.find(params[:id])

    respond_to do |format|
      if @category.update_attributes(params[:category])
        format.html { redirect_to @category, notice: 'Category was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api/wmall/categories/1
  # DELETE /api/wmall/categories/1.json
  def destroy
    @category = current_mall.categories.find(params[:id])
    @category.destroy

    respond_to do |format|
      format.html { redirect_to api_wmall_categories_url }
      format.json { head :no_content }
    end
  end
end
