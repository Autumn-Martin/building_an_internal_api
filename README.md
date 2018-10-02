# README

This project is the result of watching tutorials to learn about building an internal api & customizing it with JSON. This project follows the following tutorials by Mike Dao & Turing School of Software and Design:

* Building An Internal API:
https://www.youtube.com/watch?v=R5FPYQgB6Zc&list=PL1Y67f0xPzdOq2FcpWnawJeyJ3ELUdBkJ&index=1

* Customizing JSON in Your API:
https://www.youtube.com/watch?v=cv1VQ_9OqvE&list=PL1Y67f0xPzdOq2FcpWnawJeyJ3ELUdBkJ&index=2


The written versions of these lessons are also available [here](http://backend.turing.io/module3/lessons/building_an_api), [here](http://backend.turing.io/module3/lessons/customizing_json_in_your_api) and below:
-----------------------------------------------------
Turing School of Software and Design

Building an Internal API
This lesson plan last updated with Ruby 2.4.1 and Rails 5.2.0

Learning Goals
Understand how an internal API works at a conceptual level
Use request specs to cover an internal API
Feel comfortable writing request specs that deal with different HTTP verbs (GET, POST, PUT, DELETE)

Warmup
What is an API in the context of web development?
Why might we decide to expose information in a database we control through an API?
Why might we create an API not to be consumed by others?
What do we need to test in an API?
How will our tests be different from feature tests we have implemented in the past?
Overview
Review of New Tools
RSpec & FactoryBot Setup
Creating Our First Test and Factory
Api::V1::ItemsController#index
Api::V1::ItemsController#show
Api::V1::ItemsController#create
Api::V1::ItemsController#update
Api::V1::ItemsController#destroy
New Tools
Testing
get 'api/v1/items': submits a get request to your application
response: captures the response to a given request
JSON.parse(response): parses a JSON response
Controller
render: tells your controller what to render as a response
json: Item.all: hash argument for render - converts Item.all to valid JSON
Procedure
0. RSpec & Factory Girl Setup
Let’s start by creating a new Rails project. If you are creating an api only Rails project, you can append --api to your rails new line in the command line. Read section 3 of the docs to see how an api-only rails project is configured.

$ rails new building_internal_apis -T -d postgresql --api
$ cd building_internal_apis
$ bundle
$ bundle exec rake db:create
Add gem 'rspec-rails' to your Gemfile.

$ bundle
$ rails g rspec:install
Now let’s get our factories set up!

add gem 'factory_bot_rails' to your :development, :test block in your Gemfile.

Inside of the rails_helper.rb file add this to the RSpec.configure block:

  config.include FactoryBot::Syntax::Methods
Versioned APIs
In software (and probably other areas in life) you’re never going to know less about a problem than you do right now. Procrastination and being resolved to solve only immediate problems can be an effective strategy while writing software. Our assumptions are often wrong and we need to change what we build. When building APIs, we don’t always know exactly how they will be used. Because of this, we should aim to build with the assumption that things will need to change.

Imagine we are serving up an API that several other companies and developers are using. Let’s think through a simple example. Let’s say we have an API endpoint of GET /api/items/1 that returns a JSON response that includes an id, title, description, and number_sold. Now imagine that at a later date we no longer want to provide number_sold and instead want to replace it with a new attribute called popularity. What happens to all of our consumers that were dependent on number_sold?

We can provide a better experience for our clients by versioning our API. Instead of our endpoint being GET /api/items/1 we can add an extra segment to our URL with a version number. Something like GET /api/v1/items/1. If we ever want to change our API in the future we can simply change the segment to represent the new API GET /api/v2/items/1. The big advantage here is we can have both endpoints served simultaneously to allow our clients to transition their code bases to use the newest version. Usually the intent is to shutdown the initial API since maintaining multiple versions can be a drain on resources. Most companies will provide a date that the deprecated API will be shutdown.

We’ll be building a versioned API for this lesson.

1. Creating Our First Test
Now that our configuration is set up, we can start test driving our code. First, let’s set up the test file. In true TDD form, we need to create the structure of the test folders ourselves. Even though we are going to be creating controller files for our api, users are going to be sending HTTP requests to our app. For this reason, we are going to call these specs requests instead of controller specs. Let’s create our folder structure.

$ mkdir -p spec/requests/api/v1
$ touch spec/requests/api/v1/items_request_spec.rb
Note that we are namespacing under /api/v1. This is how we are going to namespace our controllers, so we want to do the same in our tests.

On the first line of our test, we want to set up our data. We configured Factory Bot so let’s have it generate some items for us. We then want to make the request that a user would be making. We want a get request to api/v1/items and we would like to get json back. At the end of the test we want to assert that the response was a success.

spec/requests/api/v1/items_request_spec.rb

require 'rails_helper'

describe "Items API" do
  it "sends a list of items" do
    create_list(:item, 3)

    get '/api/v1/items'

    expect(response).to be_successful
  end
end
2. Creating Our First Model, Migration, and Factory
Let’s make the test pass!

The first error that we should receive is

Failure/Error: create_list(:item, 3) ArgumentError: Factory not registered: item
This is because we have not created a factory yet. The easiest way to create a factory is to generate the model.

Let’s generate a model.

$ rails g model Item name description:text
Notice that not only was the Item model created, but a factory was created for the item in spec/factories/items.rb

Now let’s migrate!

$ bundle exec rake db:migrate
== 20160229180616 CreateItems: migrating ======================================
-- create_table(:items)
   -> 0.0412s
== 20160229180616 CreateItems: migrated (0.0413s) =============================
Before we run our test again, let’s take a look at the Item Factory that was generated for us.

spec/factories/items.rb

FactoryBot.define do
  factory :item do
    name "MyString"
    description "MyText"
  end
end
We can see that the attributes are created with auto-populated data using My and the attribute data type. This is boring. Let’s change it to reflect a real item.

spec/factories/items.rb

FactoryBot.define do
  factory :item do
    name "Banana Stand"
    description "There's always money in the banana stand."
  end
end
3. Api::V1::ItemsController#index
We’re TDD’ing so let’s run our tests again.

We should get the error ActionController::RoutingError: No route matches [GET] "/api/v1/items"

This is because we haven’t yet set up our routing.

# config/routes.rb
  namespace :api do
    namespace :v1 do
      resources :items, only: [:index]
    end
  end
Sure enough, that changes our error.

ActionController::RoutingError:
  uninitialized constant Api
Our routes file is telling our app to look for a directory api in our controllers directory, but that doesn’t yet exist. Ultimately, we’re going to need a controller. Let’s go ahead and create that controller in this next step.

If you’d like, feel free to run your tests after creating the directory structure to see the new error confirming that we’re looking for a controller.

$ mkdir -p app/controllers/api/v1
$ touch app/controllers/api/v1/items_controller.rb
We can add the following to the controller we just made:

# app/controllers/api/v1/items_controller.rb
class Api::V1::ItemsController < ApplicationController
end
Also, add the action in the controller:

# app/controllers/api/v1/items_controller.rb
class Api::V1::ItemsController < ApplicationController

  def index
  end

end
Great! We are successfully getting a response. But we aren’t actually getting any data. Without any data or templates, Rails 5 API will respond with Status 204 No Content. Since it’s a 2xx status code, it is interpreted as a success.

Now lets see if we can actually get some data.

# spec/requests/api/v1/items_request_spec.rb
require 'rails_helper'

describe "Items API" do
  it "sends a list of items" do
     create_list(:item, 3)

      get '/api/v1/items'

      expect(response).to be_successful

      items = JSON.parse(response.body)
   end
end
When we run our tests again, we get a semi-obnoxious JSON::ParserError.

Well that makes sense. We aren’t actually rendering anything yet. Let’s render some JSON from our controller.

# app/controllers/api/v1/items_controller.rb
class Api::V1::ItemsController < ApplicationController

  def index
    render json: Item.all
  end

end
And… our test is passing again.

Let’s take a closer look at the response. Put a pry on line eight in the test, right below where we make the request.

If you just type response you can take a look at the entire response object. We care about the response body. If you enter response.body you can see the data that is returned from the endpoint. We are getting back two items that we never created - this is data served from fixtures. Please feel free to edit the data in the fixtures file as you see fit.

The data we got back is json, and we need to parse it to get a Ruby object. Try entering JSON.parse(response.body). As you see, the data looks a lot more like Ruby after we parse it. Now that we have a Ruby object, we can make assertions about it.

# spec/requests/api/v1/items_request_spec.rb
require 'rails_helper'

describe "Items API" do
  it "sends a list of items" do
    create_list(:item, 3)

    get "/api/v1/items"

    expect(response).to be_successful

    items = JSON.parse(response.body)

    expect(items.count).to eq(3)
  end
end
Run your tests again and they should still be passing.

4. ItemsController#show
Now we are going to test drive the /api/v1/items/:id endpoint. From the show action, we want to return a single item.

First, let’s write the test. As you can see, we have added a key id in the request:

# spec/requests/api/v1/items_request_spec.rb
  it "can get one item by its id" do
    id = create(:item).id

    get "/api/v1/items/#{id}"

    item = JSON.parse(response.body)

    expect(response).to be_successful
    expect(item["id"]).to eq(id)
  end
Try to test drive the implementation before looking at the code below.
Run the tests and the first error we get is: ActionController::RoutingError: No route matches [GET] "/api/v1/items/980190962", or some other similar route. Factory Bot has created an id for us.

Let’s update our routes.

# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :items, only: [:index, :show]
  end
end
Run the tests and… The action 'show' could not be found for Api::V1::ItemsController.

Add the action and declare what data should be returned from the endpoint:

def show
  render json: Item.find(params[:id])
end
Run the tests and… we should have two passing tests.

5. ItemsController#create
Let’s start with the test. Since we are creating a new item, we need to pass data for the new item via the HTTP request. We can do this easily by adding the params as a key-value pair. Also note that we swapped out the get in the request for a post since we are creating data.

Also note that we aren’t parsing the response to access the last item we created, we can simply query for the last Item record created.

# spec/requests/api/v1/items_request_spec.rb
it "can create a new item" do
  item_params = { name: "Saw", description: "I want to play a game" }

  post "/api/v1/items", params: {item: item_params}
  item = Item.last

  assert_response :success
  expect(response).to be_successful
  expect(item.name).to eq(item_params[:name])
end
Run the test and you should get ActionController::RoutingError:No route matches [POST] "/api/v1/items"

First, we need to add the route and the action.

# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :items, only: [:index, :show, :create]
  end
end
# app/controllers/api/v1/items_controller.rb
def create
end
Run the tests… and the test fails. You should get NoMethodError: undefined method 'name' for nil:NilClass. That’s because we aren’t actually creating anything yet.

We are going to create an item with the incoming params. Let’s take advantage of all the niceties Rails gives us and use strong params.

# app/controllers/api/v1/items_controller.rb
def create
  render json: Item.create(item_params)
end

private

  def item_params
    params.require(:item).permit(:name, :description)
  end
Run the tests and we should have 3 passing tests.

6. Api::V1::ItemsController#update
Like before, let’s add a test.

This test looks very similar to the previous one we wrote. Note that we aren’t making assertions about the response, instead we are accessing the item we updated from the database to make sure it actually updated the record.

# spec/requests/api/v1/items_request_spec.rb
it "can update an existing item" do
  id = create(:item).id
  previous_name = Item.last.name
  item_params = { name: "Sledge" }

  put "/api/v1/items/#{id}", params: {item: item_params}
  item = Item.find_by(id: id)

  expect(response).to be_successful
  expect(item.name).to_not eq(previous_name)
  expect(item.name).to eq("Sledge")
end
Try to test drive the implementation before looking at the code below.
# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :items, only: [:index, :show, :create, :update]
  end
end
# app/controllers/api/v1/items_controller.rb
def update
  render json: Item.update(params[:id], item_params)
end
7. Api::V1::ItemsController#destroy
Ok, last endpoint to test and implement: destroy!

In this test, the last line in this test is refuting the existence of the item we created at the top of this test.

# spec/requests/api/v1/items_request_spec.rb
it "can destroy an item" do
  item = create(:item)

  expect(Item.count).to eq(1)

  delete "/api/v1/items/#{item.id}"

  expect(response).to be_successful
  expect(Item.count).to eq(0)
  expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
end
We can also use RSpec’s expect change method as an extra check. In our case, change will check that the numeric difference of Item.count before and after the block is run is -1.

it "can destroy an item" do
  item = create(:item)

  expect{delete "/api/v1/items/#{item.id}"}.to change(Item, :count).by(-1)

  expect(response).to be_success
  expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
end
Make the test pass.
# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :items, except: [:new, :edit]
  end
end
# app/controllers/api/v1/items_controller.rb
def destroy
  Item.delete(params[:id])
end
Pat yourself on the back. You just built an API. And with TDD. Huzzah! Now go call a friend and tell them how cool you are.

Supporting Materials
Getting started with Factory Bot
Use Factory Bot’s Build Stubbed for a Faster Test (Note that this post uses FactoryGirl instead of FactoryBot. FactoryGirl is the old name.)
Building an Internal API Short Tutorial
---------------------------------------------------
Turing School of Software and Design

Customizing JSON in your API
This lesson plan was last verified to have worked with Ruby v2.4.1 and Rails v5.2.0

Learning Goals
Generate and customize Rails Serializers
Discuss other serialization options, like Jbuilder
Understand what constitutes presentation logic in the context of serving a JSON API and why formatting in the model is not the right place

Warmup
Research ActiveModel Serializers

What do serializers allow us to do?
What resources were you able to find? Which seem most promising?
What search terms did you use that gave the best results?
Active Model Serializers
AMS allow us to break from the concept of views fully with our API, and instead, mold that data in an object-oriented fashion.

When we call render json:, Rails makes a call to as_json under the hood unless we have a serializer set up. Eventually, as_json calls to_json and our response is generated.

With how we’ve used render json: up til now, all data related with the resources in our database is sent back to the client as-is.

Let’s imagine that you don’t just want the raw guts of your model converted to JSON and sent out to the user – maybe you want to customize what you send back.

Code Along
Adding to Our Existing Project
We’re going to start where we left off in the internal API testing lesson. Feel free to use the repository that you created yesterday. Otherwise, you can clone the repo below as a starting place.

git clone https://github.com/turingschool-examples/building_internal_apis.git
bundle
git checkout building_api_complete
We want to work with objects that have related models, so let’s add an Order model:

rails g model order order_number
rails g model order_item order:references item:references item_price:integer quantity:integer
bundle exec rake db:migrate
Add gem 'faker':

bundle
Add relationships to your models:

# in item.rb
has_many :order_items
has_many :orders, through: :order_items

# in order.rb
has_many :order_items
has_many :items, through: :order_items
And whip together a quick seed file:

10.times do
  Item.create!(
    name: Faker::Commerce.product_name,
    description: Faker::ChuckNorris.fact,
  )
end

10.times do
  Order.create!(order_number: rand(100000..999999))
end

100.times do
  OrderItem.create!(
    item_id: rand(1..10),
    order_id: rand(1..10),
    item_price: rand(100..10000),
    quantity: rand(1..10)
  )
end
And seed

bundle exec rake db:seed
Create your controller:

rails g controller api/v1/orders index show
Create routes.
Set index and show methods to render appropriate json
Desired Responses
Use Postman or your browser to view the current responses that your API is providing to the routes listed below:

api/v1/items
api/v1/items/:id
api/v1/orders
api/v1/orders/:id
Compare those responses to the responses below. How do they differ?

api/v1/items

[
  {
    "id": 1,
    "name": "Hammer",
  },
  {...}
]
api/v1/items/:id

{
  "id": 1,
  "name": "Hammer",
  "num_orders": 5,
  "orders": [
    {"order_number": "12345ABC"},
    {...}
  ]
}
api/v1/orders

[
  {
    "id": 1,
    "order_number": "12345ABC",
  },
  {...}
]
api/v1/orders/:id

{
  "id": 1,
  "order_number": "12345ABC",
  "num_items": 5,
  "items": [
    {
      "id": 1,
      "name": "Hammer",
      "price": 11
    },
    {...}
  ]
}
Using Active Model Serializers to modify as_json
Install AMS with a gem: gem 'active_model_serializers', '~> 0.10.0'

We’re going to create a serializer for Order.

Create your serializer
rails g serializer order
Add a few attributes
Some existing fields
id, order_number
Some custom fields
num_items
A relationship
items
Our final product should look something like this:

# controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < ApplicationController
  def index
    render json: Order.all
  end

  def show
    render json: Order.find(params[:id])
  end
end
# serializers/order_serializer.rb
class OrderSerializer < ActiveModel::Serializer
  attributes :id, :order_number, :num_items

  has_many :items

  def num_items
    object.items.count
  end
end
Lab
Do what we did to Order, but on Item now.

Some existing fields
id, name, description
Some custom fields
num_orders
A relationship
orders
Additional Resources
Here’s some branches of Storedom with customized JSON:

Active Model Serializer Docs
Storedom branch for Serializers
Storedom branch for Jbuilder
