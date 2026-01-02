"""
Spark Part3 Server
対話から強みを発見するためのAPIサーバー
"""
import asyncio
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
from claude_agent_sdk import query, ClaudeAgentOptions

app = FastAPI(title="Spark Part3 API")

# CORS設定
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# リクエスト/レスポンスモデル
class ConversationRequest(BaseModel):
    user_message: str
    conversation_history: list[dict] = []
    user_context: Optional[dict] = None  # 年齢、職業経験など

class ConversationResponse(BaseModel):
    ai_message: str
    detected_strengths: list[str] = []
    conversation_complete: bool = False

class StrengthAnalysis(BaseModel):
    abilities: list[dict]  # {"name": "傾聴力", "score": 0.8, "evidence": "..."}
    personality: list[dict]  # {"name": "共感的", "evidence": "..."}

# システムプロンプト
DISCOVERY_PROMPT = """
あなたは「強み発見アシスタント」です。
自然な会話を通じて、相手の能力や「らしさ」を発見してください。

【重要なルール】
- 「テスト」や「評価」の雰囲気を出さない
- 友達と話すようなリラックスした雰囲気で
- 相手の話に興味を持って聞く
- 押し付けがましくない

【発見したい能力】
- 論理的思考（説明の組み立て方）
- 問題解決力（困った時の対処法）
- 傾聴力（相手の話の拾い方）
- 説明力（複雑なことの伝え方）
- 状況判断力（適切な対応）
- 共感力（相手の気持ちを汲む）

【発見したい「らしさ」】
- 価値観（何を大事にするか）
- 興味関心（何に熱中するか）
- 対人スタイル（どう関わるか）

会話を続けながら、自然に相手の強みを見つけてください。
"""

@app.get("/")
async def root():
    return {"message": "Spark Part3 API", "status": "running"}

@app.post("/conversation", response_model=ConversationResponse)
async def conversation(request: ConversationRequest):
    """会話を続け、強みを発見する"""
    
    # 会話履歴を構築
    history = ""
    for msg in request.conversation_history:
        role = "ユーザー" if msg.get("role") == "user" else "AI"
        history += f"{role}: {msg.get('content', '')}\n"
    
    # ユーザーコンテキストを追加
    context = ""
    if request.user_context:
        if request.user_context.get("age_group"):
            context += f"年齢層: {request.user_context['age_group']}\n"
        if request.user_context.get("work_experience"):
            context += f"職業経験: {request.user_context['work_experience']}\n"
    
    prompt = f"""
{DISCOVERY_PROMPT}

{f"【ユーザー情報】{context}" if context else ""}

【これまでの会話】
{history}

【ユーザーの最新メッセージ】
{request.user_message}

自然に会話を続けてください。返答のみを出力してください。
"""

    try:
        options = ClaudeAgentOptions(
            system_prompt="あなたは親しみやすい対話パートナーです。"
        )
        
        response_text = ""
        async for message in query(prompt=prompt, options=options):
            if hasattr(message, 'content'):
                for block in message.content:
                    if hasattr(block, 'text'):
                        response_text += block.text
        
        return ConversationResponse(
            ai_message=response_text.strip(),
            detected_strengths=[],
            conversation_complete=False
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/analyze", response_model=StrengthAnalysis)
async def analyze_strengths(conversation_history: list[dict]):
    """会話履歴から強みを分析"""
    
    history = "\n".join([
        f"{'ユーザー' if msg.get('role') == 'user' else 'AI'}: {msg.get('content', '')}"
        for msg in conversation_history
    ])
    
    prompt = f"""
以下の会話から、ユーザーの強みを分析してください。

【会話】
{history}

【分析してほしいこと】
1. 能力（論理的思考、問題解決力、傾聴力、説明力、状況判断力、共感力など）
2. らしさ（価値観、興味関心、対人スタイル）

JSON形式で出力:
{{
  "abilities": [
    {{"name": "能力名", "score": 0.8, "evidence": "会話からの根拠"}}
  ],
  "personality": [
    {{"name": "特徴", "evidence": "会話からの根拠"}}
  ]
}}
"""

    try:
        options = ClaudeAgentOptions()
        
        response_text = ""
        async for message in query(prompt=prompt, options=options):
            if hasattr(message, 'content'):
                for block in message.content:
                    if hasattr(block, 'text'):
                        response_text += block.text
        
        # JSONをパース（簡易版）
        import json
        import re
        
        # JSON部分を抽出
        json_match = re.search(r'\{.*\}', response_text, re.DOTALL)
        if json_match:
            result = json.loads(json_match.group())
            return StrengthAnalysis(**result)
        
        return StrengthAnalysis(abilities=[], personality=[])
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
