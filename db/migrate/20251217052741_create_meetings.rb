class CreateMeetings < ActiveRecord::Migration[8.1]
  def change
    create_table :meetings do |t|
      t.references :company, null: false, foreign_key: true
      t.references :evaluator, null: false, foreign_key: { to_table: :profiles }
      t.references :evaluatee, null: false, foreign_key: { to_table: :profiles }
      t.references :speaker_a, null: false, foreign_key: { to_table: :profiles }
      t.references :speaker_b, null: false, foreign_key: { to_table: :profiles }
      t.references :uploaded_by, null: false, foreign_key: { to_table: :profiles }
      t.text :transcription
      t.string :original_filename
      t.string :storage_path

      t.timestamps
    end
  end
end
