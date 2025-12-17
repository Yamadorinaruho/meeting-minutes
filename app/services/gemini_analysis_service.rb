class GeminiAnalysisService
  SCHEMA = {
    type: "object",
    properties: {
      summary: { type: "string", description: "会議内容の3行要約。" },
      evaluation_tags: { type: "array", items: { type: "string" }, description: "人事評価上のキーワード。" },
      score_by_tag: {
        type: "object",
        description: "evaluation_tagsで抽出されたタグすべてに対し、会話の内容に基づき1（最低）から5（最高）の5段階で評価した数値。"
      },
      next_steps: { type: "array", items: { type: "string" }, description: "会議で合意した次の具体的な行動ステップ。" }
    },
    required: ["summary", "evaluation_tags", "score_by_tag", "next_steps"]
  }.freeze

  def initialize(meeting)
    @meeting = meeting
    @api_key = Rails.application.credentials.dig(:gemini, :api_key) || ENV["GEMINI_API_KEY"]
  end

  def analyze
    return { error: "Gemini API key not configured" } unless @api_key
    return { error: "No audio file attached" } unless @meeting.audio_file.attached?

    file_response = upload_file
    return { error: file_response[:error] } if file_response[:error]

    analysis_response = generate_content(file_response[:file_uri])
    delete_file(file_response[:file_name])

    analysis_response
  end

  private

  def upload_file
    file_data = @meeting.audio_file.download
    filename = @meeting.original_filename
    mime_type = @meeting.audio_file.content_type

    conn = Faraday.new(url: "https://generativelanguage.googleapis.com") do |f|
      f.request :multipart
      f.request :url_encoded
      f.adapter Faraday.default_adapter
    end

    response = conn.post("/upload/v1beta/files?key=#{@api_key}") do |req|
      req.headers["X-Goog-Upload-Command"] = "start, upload, finalize"
      req.headers["X-Goog-Upload-Header-Content-Length"] = file_data.bytesize.to_s
      req.headers["X-Goog-Upload-Header-Content-Type"] = mime_type
      req.headers["Content-Type"] = mime_type
      req.body = file_data
    end

    if response.success?
      data = JSON.parse(response.body)
      { file_uri: data.dig("file", "uri"), file_name: data.dig("file", "name") }
    else
      { error: "File upload failed: #{response.body}" }
    end
  end

  def generate_content(file_uri)
    prompt = build_prompt

    request_body = {
      contents: [
        {
          parts: [
            { file_data: { mime_type: @meeting.audio_file.content_type, file_uri: file_uri } },
            { text: prompt }
          ]
        }
      ],
      generationConfig: {
        responseMimeType: "application/json",
        responseSchema: SCHEMA
      }
    }

    conn = Faraday.new(url: "https://generativelanguage.googleapis.com") do |f|
      f.request :json
      f.response :json
      f.adapter Faraday.default_adapter
    end

    response = conn.post("/v1beta/models/gemini-2.0-flash:generateContent?key=#{@api_key}") do |req|
      req.headers["Content-Type"] = "application/json"
      req.body = request_body.to_json
    end

    if response.success?
      text = response.body.dig("candidates", 0, "content", "parts", 0, "text")
      { analysis: JSON.parse(text), prompt: prompt }
    else
      { error: "Analysis failed: #{response.body}" }
    end
  rescue JSON::ParserError => e
    { error: "JSON parse error: #{e.message}" }
  end

  def delete_file(file_name)
    return unless file_name

    conn = Faraday.new(url: "https://generativelanguage.googleapis.com")
    conn.delete("/v1beta/#{file_name}?key=#{@api_key}")
  rescue StandardError
    # Ignore deletion errors
  end

  def build_prompt
    evaluator = @meeting.evaluator
    evaluatee = @meeting.evaluatee
    criteria = @meeting.company.evaluation_criteria.active

    criteria_list = criteria.map { |c| "- #{c.tag_name}: #{c.description}" }.join("\n")

    <<~PROMPT
      あなたは、人事評価と育成支援を専門とするAIアシスタントです。
      以下の1on1の音声ログを解析し、人事評価に必要なインサイトを抽出してください。

      --- 会議情報 ---
      話者A (評価者): #{evaluator.name} (役割: #{evaluator.role}, 職種: #{evaluator.job_title || 'N/A'})
      話者B (被評価者): #{evaluatee.name} (役割: #{evaluatee.role}, 職種: #{evaluatee.job_title || 'N/A'})

      --- 評価基準リスト ---
      以下の評価基準（タグ名と定義）に厳密に従って分析し、**1から5の5段階**で採点してください。
      #{criteria_list}

      --- 指示 ---
      1. 音声ログ全体を文字起こしし、話者を「#{evaluator.name} (A):」と「#{evaluatee.name} (B):」のように明確に分離して表示してください。
      2. 評価結果はJSON形式のスキーマに厳密に従って出力してください。
    PROMPT
  end
end
