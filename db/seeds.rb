# デフォルト会社を作成
company = Company.find_or_create_by!(name: "サンプル株式会社")

# 評価基準を作成
evaluation_criteria = [
  { tag_name: "コミュニケーション能力", description: "相手の話を聞き、自分の意見を明確に伝える能力" },
  { tag_name: "問題解決力", description: "課題を特定し、適切な解決策を提案・実行する能力" },
  { tag_name: "主体性", description: "自ら考え、率先して行動する姿勢" },
  { tag_name: "チームワーク", description: "チームメンバーと協力し、共通の目標に向かう姿勢" },
  { tag_name: "成長意欲", description: "新しいスキルや知識を積極的に習得しようとする姿勢" }
]

evaluation_criteria.each do |criterion|
  EvaluationCriterion.find_or_create_by!(
    company: company,
    tag_name: criterion[:tag_name]
  ) do |ec|
    ec.description = criterion[:description]
    ec.is_active = true
  end
end

puts "Seed data created successfully!"
puts "Company: #{company.name}"
puts "Evaluation Criteria: #{EvaluationCriterion.count}"
