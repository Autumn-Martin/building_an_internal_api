class OrderSerializer < ActiveModel::Serializer
  attributes :id, :order_number, :num_items, :message

  has_many :items
  
  def num_items
    object.items.count
    # object refers to actual order,
    # ... or the thing that we're working on right now,
    # ... similar to self or a block parameter for an enumerator
  end

  def message
    "Hello friendos"
  end
end
