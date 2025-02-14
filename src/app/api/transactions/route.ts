import { NextRequest, NextResponse } from 'next/server'

export const POST = async (req: NextRequest) => {
  const { text } = await req.json()

  const url = process.env.LLM_API_URL as string
  const api_key = process.env.LLM_API_KEY as string
  const model = process.env.LLM_API_MODEL as string

  type Transaction = {
    amount: number
    category: string
    type: 'income' | 'expense'
    datetime: string
    detail: string
    quantity: number
    note: string
  }

  const response_format = {
    type: 'json_schema',
    json_schema: {
      name: 'transaction_response',
      schema: {
        type: 'object',
        properties: {
          transactions: {
            type: 'array',
            items: {
              type: 'object',
              properties: {
                amount: {
                  type: 'number',
                  description: '商品的交易金額'
                },
                category: {
                  type: 'string',
                  description: '交易類別，例如：餐飲、交通、娛樂等'
                },
                type: {
                  type: 'string',
                  enum: ['income', 'expense'],
                  description: '交易類型，收入或支出'
                },
                // date: {
                //   type: 'string',
                //   // format: 'date',
                //   description: '交易日期，格式：YYYY-MM-DD'
                // },
                // time: {
                //   type: 'string',
                //   // format: 'time',
                //   description: '交易時間，格式：HH:mm'
                // },
                datetime: {
                  type: 'string',
                  description: '交易日期時間，格式：YYYY-MM-DD HH:mm:ss'
                },
                detail: {
                  type: 'string',
                  description: '商品名稱（簡單描述）'
                },
                quantity: {
                  type: 'integer',
                  description: '購買的數量'
                },
                note: {
                  type: 'string',
                  description:
                    '額外資訊，例如：早餐/午餐/晚餐、地點、特殊情況等，不要顯示時間性用詞，例如：今天、明天、昨天等'
                }
              },
              required: ['amount', 'category', 'type', 'datetime', 'detail', 'quantity']
            }
          }
        },
        required: ['transactions'],
        additionalProperties: false
      },
      strict: true
    }
  }

  console.log(
    url,
    api_key,
    model,
    '目前時間',
    new Date().toLocaleString('zh-TW', { hour12: false }),
    text
  )

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${api_key}`,
        'content-type': 'application/json'
      },
      body: JSON.stringify({
        model,
        messages: [
          {
            role: 'system',
            content: '我是一個記帳小幫手，請告訴我你的交易紀錄。我會使用繁體中文幫你記錄。'
          },
          {
            role: 'user',
            content: `${new Date().toLocaleString('zh-TW', { hour12: false })} ${text}`
          }
        ],
        response_format
      })
    })
    const data = await response.json()
    console.log(JSON.stringify(data, null, 2))
    // 把裡面所有 amount 若有 - 就移除
    const transactions = JSON.parse(data.choices[0].message.content).transactions.map(
      (transaction: Transaction) => {
        transaction.amount = Math.abs(transaction.amount)
        return transaction
      }
    )
    return NextResponse.json(transactions)
  } catch (error) {
    console.error(error)
  }

  return NextResponse.json({ error: 'An unknown error occurred' }, { status: 500 })
}
