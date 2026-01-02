"""
AIseed Server
AIと人が共に成長するプラットフォームのAPIサーバー
"""
import asyncio
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
from claude_agent_sdk import query, ClaudeAgentOptions

app = FastAPI(title="AIseed API")

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
    user_context: Optional[dict] = None

class ConversationResponse(BaseModel):
    ai_message: str
    detected_strengths: list[str] = []
    conversation_complete: bool = False

class StrengthAnalysis(BaseModel):
    abilities: list[dict]
    personality: list[dict]

# システムプロンプト
PROMPTS = {
    "spark": """
あなたは「強み発見アシスタント」です。
自然な会話を通じて、相手の能力や「らしさ」を発見してください。

【重要なルール】
- 「テスト」や「評価」の雰囲気を出さない
- 友達と話すようなリラックスした雰囲気で
- 相手の話に興味を持って聞く

【発見したい能力】
- 論理的思考、問題解決力、傾聴力、説明力、状況判断力、共感力

【発見したい「らしさ」】
- 価値観、興味関心、対人スタイル
""",
    "grow": """
あなたは「栽培・料理アドバイザー」です。
自然栽培、伝統野菜、料理についてアドバイスしてください。

【できること】
- 季節に合った野菜の提案
- 栽培方法のアドバイス
- 伝統野菜の歴史と育て方
- 収穫した野菜の料理レシピ

【スタンス】
- 初心者にも分かりやすく
- 実践的なアドバイス
- 一緒に学ぶ姿勢
""",
    "learn": """
あなたは「プログラミング教育アシスタント」です。
初心者から上級者まで、プログラミングを教えてください。

【教えられること】
- Python基礎
- Flutterアプリ開発
- Web制作
- BYOA（自分のAIエージェント開発）

【教え方】
- レベルに合わせて
- 実践的なコード例
- 一緒に問題を解決
- 失敗を恐れない雰囲気
""",
    "create": """
あなたは「Web制作アシスタント」です。
ユーザーの希望を聞いて、Webサイトを作る手伝いをしてください。

【できること】
- サイトの構成提案
- デザインのアドバイス
- コード生成
- 公開方法のガイド

【スタンス】
- 技術知識がなくても大丈夫
- ユーザーの希望を引き出す
- シンプルで美しいデザイン
"""
}

@app.get("/")
async def root():
    return {"message": "AIseed API", "status": "running", "services": ["spark", "grow", "learn", "create"]}

async def handle_conversation(service: str, request: ConversationRequest) -> ConversationResponse:
    """共通の会話処理"""
    
    history = ""
    for msg in request.conversation_history:
        role = "ユーザー" if msg.get("role") == "user" else "AI"
        history += f"{role}: {msg.get('content', '')}\n"
    
    prompt = f"""
{PROMPTS.get(service, PROMPTS["spark"])}

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

# Spark - 強み発見
@app.post("/conversation", response_model=ConversationResponse)
async def spark_conversation(request: ConversationRequest):
    return await handle_conversation("spark", request)

@app.post("/spark/conversation", response_model=ConversationResponse)
async def spark_conversation_alt(request: ConversationRequest):
    return await handle_conversation("spark", request)

# Grow - 栽培・料理
@app.post("/grow/conversation", response_model=ConversationResponse)
async def grow_conversation(request: ConversationRequest):
    return await handle_conversation("grow", request)

# Learn - プログラミング
@app.post("/learn/conversation", response_model=ConversationResponse)
async def learn_conversation(request: ConversationRequest):
    return await handle_conversation("learn", request)

# Create - Web制作
@app.post("/create/conversation", response_model=ConversationResponse)
async def create_conversation(request: ConversationRequest):
    return await handle_conversation("create", request)

# 分析エンドポイント
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

JSON形式で出力:
{{
  "abilities": [{{"name": "能力名", "score": 0.8, "evidence": "根拠"}}],
  "personality": [{{"name": "特徴", "evidence": "根拠"}}]
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
        
        import json
        import re
        
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
