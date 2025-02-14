'use client'

import React from 'react'
import { HomeIcon, MicIcon, SquareIcon } from 'lucide-react'
import { ChevronDownIcon } from 'lucide-react'

import { Calendar } from '@/components/ui/calendar'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger
} from '@/components/ui/dialog'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { useVoiceInput } from '@/hooks/use-voice-input'
import { cn } from '@/lib/utils'

const HomePage = () => {
  const { isListening, transcript, startListening, stopListening, isLoading, error, data } =
    useVoiceInput()

  const [date, setDate] = React.useState<Date | undefined>(new Date())

  const handleVoiceButtonClick = () => {
    if (isListening) {
      stopListening()
    } else {
      startListening()
    }
  }
  // const viewrClassName = 'data-[state=active]:bg-transparent data-[state=active]:shadow-none'
  const viewrClassName = 'data-[state=active]:shadow-none rounded-3xl w-full'

  return (
    <div className='p-4'>
      {/* <Select>
        <SelectTrigger className='w-[180px] border-0 focus:ring-0 focus:ring-offset-0'>
          <SelectValue placeholder='2025-02' />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value='light'>Light</SelectItem>
          <SelectItem value='dark'>Dark</SelectItem>
          <SelectItem value='system'>System</SelectItem>
        </SelectContent>
      </Select> */}

      {/* <div className='flex justify-around overflow-hidden rounded-3xl bg-secondary'>
        <Button variant='ghost'>日</Button>
        <Button variant='ghost'>週</Button>
        <Button variant='ghost'>月</Button>
        <Button variant='ghost'>年</Button>
        <Button variant='ghost'>自訂</Button>
      </div> */}
      <Tabs defaultValue='date'>
        <TabsContent value='date' className='m-0'>
          <Dialog>
            <DialogTrigger asChild>
              <div className='flex cursor-pointer items-center gap-4'>
                <span className='text-xl'>{date?.toLocaleDateString()}</span>
                <ChevronDownIcon />
              </div>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Are you absolutely sure?</DialogTitle>
                <DialogDescription>
                  This action cannot be undone. This will permanently delete your account and remove
                  your data from our servers.
                </DialogDescription>
              </DialogHeader>
              <Calendar
                className='w-full'
                classNames={{
                  months:
                    'flex w-full flex-col sm:flex-row space-y-4 sm:space-x-4 sm:space-y-0 flex-1',
                  month: 'space-y-4 w-full flex flex-col',
                  table: 'w-full h-full border-collapse space-y-1',
                  head_row: '',
                  row: 'w-full mt-2',
                  cell: 'rounded-md h-9 w-9 text-center text-sm p-0 relative [&:has([aria-selected].day-range-end)]:rounded-r-md [&:has([aria-selected].day-outside)]:bg-accent/50 first:[&:has([aria-selected])]:rounded-l-md last:[&:has([aria-selected])]:rounded-r-md focus-within:relative focus-within:z-20',
                  day_today:
                    'bg-primary/80 text-primary-foreground hover:bg-primary hover:text-primary-foreground focus:bg-primary focus:text-primary-foreground'
                }}
                mode='single'
                selected={date}
                onSelect={setDate}
                initialFocus
              />
            </DialogContent>
          </Dialog>
        </TabsContent>
        <TabsContent value='week'>週</TabsContent>
        <TabsContent value='month'>月</TabsContent>
        <TabsContent value='year'>年</TabsContent>
        <TabsContent value='custom'>自訂</TabsContent>
        <TabsList className='w-full rounded-3xl'>
          <TabsTrigger className={viewrClassName} value='date'>
            日
          </TabsTrigger>
          <TabsTrigger className={viewrClassName} value='week'>
            週
          </TabsTrigger>
          <TabsTrigger className={viewrClassName} value='month'>
            月
          </TabsTrigger>
          <TabsTrigger className={viewrClassName} value='year'>
            年
          </TabsTrigger>
          <TabsTrigger className={viewrClassName} value='custom'>
            自訂
          </TabsTrigger>
        </TabsList>
      </Tabs>
      <div>
        <p>{isListening ? 'Listening' : 'Not listening'}</p>
        <p>{transcript}</p>
        {isLoading ? <p>處理中...</p> : null}
        {error ? <p>{error}</p> : null}
        {data ? <p>{JSON.stringify(data, null, 2)}</p> : null}
        <div className='mt-8'>
          <h2 className='mb-4 text-2xl font-bold'>交易記錄</h2>
          <ul className='space-y-4'>
            {/* 顯示數量 */}
            {/* https://orm.drizzle.team/ */}
            {data?.map((transaction, index) => (
              <li key={index} className='rounded-md border p-4'>
                <div className='flex justify-between'>
                  <span className='font-bold'>
                    {transaction.detail} ({transaction.quantity})
                  </span>
                  <span
                    className={transaction.type === 'income' ? 'text-green-500' : 'text-red-500'}
                  >
                    {transaction.type === 'income' ? '+' : '-'}${transaction.amount}
                  </span>
                </div>
                <div className='text-sm text-gray-500'>
                  {/* 格式化時間 yyyy-MM-dd HH:mm */}
                  <span>{transaction.category}</span> |{' '}
                  <span>
                    {new Date(transaction.datetime)
                      .toLocaleString('zh-TW', {
                        hour12: false,
                        year: 'numeric',
                        month: '2-digit',
                        day: '2-digit',
                        hour: '2-digit',
                        minute: '2-digit'
                      })
                      .replace(/\//g, '-')}
                  </span>
                </div>
                {transaction.note && <div className='mt-2 text-sm'>{transaction.note}</div>}
              </li>
            ))}
          </ul>
        </div>
      </div>
      <div id='footer' className='fixed bottom-3 left-0 right-0 z-10 h-12 px-3'>
        <div className='relative grid h-full w-full grid-cols-5 justify-items-center rounded-xl bg-slate-500'>
          {/* 置中 */}

          <button
            id='voice-button'
            // className='absolute bottom-[19px] left-1/2 -translate-x-1/2 transform rounded-full border-[6px] border-white bg-blue-500 p-4'
            className={cn(
              'absolute bottom-[19px] left-1/2 -translate-x-1/2 transform rounded-full border-[6px] border-white bg-blue-500 p-4',
              {
                'bg-red-500': isListening
              }
            )}
            onClick={handleVoiceButtonClick}
          >
            {isListening ? <SquareIcon stroke='white' fill='white' /> : <MicIcon />}
          </button>

          <button>
            <HomeIcon />
          </button>
          <button>
            <HomeIcon />
          </button>
          <div className=''></div>
          <button>
            <HomeIcon />
          </button>
          <button>
            <HomeIcon />
          </button>
        </div>
      </div>
    </div>
  )
}

export default HomePage
