require 'rails_helper'

describe "Items API" do
  it "sends a list of items" do
    create_list(:item, 3) #create list method is given to us by FactoryBot -> create 3 items

    get '/api/v1/items' #sends get request to api/v1/items endpoint

    expect(response).to be_successful

    items = JSON.parse(response.body)

    expect(items.count).to eq(3)
  end

  it "can get one item by its id" do
    #expect newly created item id to match the response item id when we request it
    id = create(:item).id

    get "/api/v1/items/#{id}" # send request to API endpoint

    item = JSON.parse(response.body)

    expect(response).to be_successful
    expect(item["id"]).to eq(id)
  end

  it "can create a new item" do
    item_params = { name: "octopus cactus", description: "a very prickly and smart plant creature"}

    post "/api/v1/items", params: {item: item_params}
    item = Item.last

    expect(response).to be_successful
    expect(item.name).to eq(item_params[:name])
  end

  it "can update an existing item" do
    id = create(:item).id
    previous_name = Item.last.name
    item_params = { name: "Pumpkin"}

    put "/api/v1/items/#{id}", params: {item: item_params}
    item = Item.find_by(id: id)

    expect(response).to be_successful
    expect(item.name).to_not eq(previous_name)
    expect(item.name).to eq("Pumpkin")
  end

  it "can destroy an item" do
    item = create(:item)
    expect(Item.count).to eq(1)
    delete "/api/v1/items/#{item.id}"

    expect(response).to be_successful
    expect(Item.count).to eq(0)
    expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end 
end
