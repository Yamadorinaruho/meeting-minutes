class CreateAnalysisResults < ActiveRecord::Migration[8.1]
  def change
    create_table :analysis_results do |t|
      t.references :meeting, null: false, foreign_key: true
      t.references :analyzed_by, null: false, foreign_key: { to_table: :profiles }
      t.jsonb :ai_output
      t.string :used_model
      t.text :prompt_used

      t.timestamps
    end
  end
end
