class CreateEvaluationCriteria < ActiveRecord::Migration[8.1]
  def change
    create_table :evaluation_criteria do |t|
      t.references :company, null: false, foreign_key: true
      t.string :tag_name
      t.text :description
      t.boolean :is_active

      t.timestamps
    end
  end
end
