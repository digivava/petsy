class AddColumnsWeightDimensions < ActiveRecord::Migration
  def change
    add_column :products, :weight, :integer
    add_column :products, :height, :integer
    add_column :products, :width, :integer
  end
end
