import {
  Injectable,
  Logger,
} from '@nestjs/common'

import OpenAI from 'openai'

@Injectable()
export class TaskExtractionService {

  private readonly logger =
    new Logger(TaskExtractionService.name)

  private readonly openai =
    new OpenAI({
      apiKey:
        process.env.OPENAI_API_KEY,
    })

  async extractTasks(
    text: string,
  ): Promise<string[]> {

    try {

      const response =
        await this.openai.chat.completions.create({
          model: 'gpt-4.1-mini',

          temperature: 0,

          response_format: {
            type: 'json_object',
          },

          messages: [
            {
              role: 'system',
              content: `
Extract ONLY construction tasks.

Ignore:

- urls
- company info
- guarantees
- legal text
- contact information
- notes

Return:

{
  "tasks": [
    "task1",
    "task2"
  ]
}
`,
            },
            {
              role: 'user',
              content: text,
            },
          ],
        })

      const content =
        response.choices[0].message.content

      if (!content) {
        return []
      }

      const parsed =
        JSON.parse(content)

      if (
        !parsed.tasks ||
        !Array.isArray(parsed.tasks)
      ) {
        return []
      }

      return parsed.tasks
        .map((x: string) => x.trim())
        .filter(Boolean)

    } catch (error) {

      this.logger.error(error)

      return []
    }
  }
}