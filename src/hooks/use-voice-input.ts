import { useCallback, useEffect, useRef, useState } from 'react'

interface SpeechRecognitionEvent {
  resultIndex: number
  results: {
    length: number
    [key: number]: {
      isFinal: boolean
      [key: number]: {
        transcript: string
      }
    }
  }
}

interface SpeechRecognition extends EventTarget {
  lang: string
  continuous: boolean
  interimResults: boolean
  onresult: (event: SpeechRecognitionEvent) => void
  onend: () => void
  start: () => void
  stop: () => void
}

declare global {
  interface Window {
    SpeechRecognition?: new () => SpeechRecognition
    webkitSpeechRecognition?: new () => SpeechRecognition
  }
}

export const useVoiceInput = () => {
  const [isListening, setIsListening] = useState(false)
  const [transcript, setTranscript] = useState('')
  const recognitionRef = useRef<SpeechRecognition | null>(null)
  const transcriptRef = useRef('') // 新增一個 ref 來保存最新的 transcript

  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [data, setData] = useState(null)

  useEffect(() => {
    // 當 transcript 改變時，更新 ref 的值
    transcriptRef.current = transcript
  }, [transcript])

  useEffect(() => {
    const SpeechRecognitionConstructor = window.SpeechRecognition || window.webkitSpeechRecognition

    if (SpeechRecognitionConstructor && !recognitionRef.current) {
      const instance = new SpeechRecognitionConstructor()
      instance.lang = 'zh-TW'
      instance.continuous = false
      instance.interimResults = true

      instance.onresult = (event: SpeechRecognitionEvent) => {
        let finalTranscript = ''
        let interimTranscript = ''

        for (let i = event.resultIndex; i < event.results.length; ++i) {
          if (event.results[i].isFinal) {
            finalTranscript += event.results[i][0].transcript
          } else {
            interimTranscript += event.results[i][0].transcript
          }
        }
        console.log(`即時結果 ${interimTranscript}`)
        console.log(`最終結果 ${finalTranscript}`)
        setTranscript(finalTranscript || interimTranscript)
      }

      instance.onend = () => {
        console.log('停止辨識', transcriptRef.current)
        setIsListening(false)
        if (transcriptRef.current) {
          // 使用 ref 的值來檢查
          handleVoiceInput(transcriptRef.current)
        }
      }

      recognitionRef.current = instance
    }

    return () => {
      if (recognitionRef.current) {
        recognitionRef.current.stop()
      }
    }
  }, []) // 移除 transcript 依賴

  const startListening = useCallback(() => {
    if (recognitionRef.current) {
      recognitionRef.current.start()
      setIsListening(true)
      setTranscript('')
    }
  }, [])

  const stopListening = useCallback(() => {
    if (recognitionRef.current) {
      recognitionRef.current.stop()
    }
  }, [])

  const handleVoiceInput = async (transcript: string) => {
    setIsLoading(true)
    try {
      const response = await fetch('/api/transactions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ text: transcript })
      })
      const data = await response.json()
      setData(data)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An unknown error occurred')
    } finally {
      setIsLoading(false)
    }
  }

  return { isListening, transcript, startListening, stopListening, isLoading, error, data }
}
