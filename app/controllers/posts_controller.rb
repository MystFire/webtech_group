class PostsController < ApplicationController
	before_action :find_post, only: [:show, :edit, :update, :destroy, :upvote, :downvote]
	before_action :authenticate_user!, except: [:index, :show]

	def index
        @searchString = ""

        if params[:search_field]
            @searchString = params[:search_field]
        end

        unless @searchString == ""

            @posts ||= []

            #filter all the correct things
            @searchString = @searchString.tr(' ','')
            ingredients = @searchString.split(',')

            #we now have a list of ingredients
            ingredients.each do |ingr_name|
                ingredient = Ingredient.where("searchname" => ingr_name)

                if ingredient.count > 0

                    #we now have an ingredient
                    Post.all.each do |post|
                        # we are now going to search for the ingredient
                        found = false

                        post.postingredient.all.each do |pi|
                            if pi.ingredient_id == ingredient.first.id
                                found = true
                                break
                            end
                        end

                        if found
                            # as soon as we have found a post;
                            # check whether the post is already in posts
                            found = false

                            @posts.each do |foundpost|
                                if foundpost.id == post.id
                                    found = true
                                    foundpost.amount = foundpost.amount + 1
                                end
                            end

                            unless found
                                post.amount = 1
                                @posts << post
                            end
                        end
                    end

                end

            end
        else
            @posts = Post.all
        end

	end

	def show
		@comments = Comment.where(post_id: @post)
		@random_post = Post.where.not(id: @post).order("RANDOM()").first

	end

	def new
		@post = current_user.posts.build
        @post.ingredients = ""
	end

	def create
		@post = current_user.posts.build(post_params)

		if @post.save

            # create and link all the ingredients to this post
            ingredients = @post.ingredients.split(",")

            ingredients.each do |ingredient_name|
                foundIngredient = Ingredient.where("name" => ingredient_name)

                if foundIngredient.count > 0

                    postIngredient = Postingredient.new
                    postIngredient.post_id = @post.id
                    postIngredient.ingredient_id = foundIngredient.first.id
                    postIngredient.save

                else

                    ingredient = Ingredient.new
                    ingredient.name = ingredient_name
                    ingredient.searchname = ingredient_name.tr(" ","")
                    ingredient.save

                    postIngredient = Postingredient.new
                    postIngredient.post_id = @post.id
                    postIngredient.ingredient_id = ingredient.id
                    postIngredient.save

                end
            end

			redirect_to @post
		else
			render 'new'
		end
	end

	def edit
	end

	def update
		if @post.update(post_params)
			redirect_to @post
		else
			render 'edit'
		end
	end

	def destroy
		@post.destroy
		redirect_to root_path
	end

	def upvote
		@post.upvote_by current_user
		redirect_to :back
	end

	def downvote
		@post.downvote_from current_user
		redirect_to :back
	end

	private

	def find_post
		@post = Post.find(params[:id])
	end

	def post_params
		params.require(:post).permit(:title, :link, :description, :image, :ingredients, :amount)
	end
end
