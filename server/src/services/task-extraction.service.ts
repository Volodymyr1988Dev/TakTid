import {
  Injectable,
  Logger,
} from '@nestjs/common'

import OpenAI from 'openai'
import { ExtractedTask } from '../types/project/extractedTask.dto'

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
  ): Promise<ExtractedTask []> {

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
Extract construction tasks.

Return JSON:

{
  "tasks": [
    {
      "title": "",
      "note": "",
      "attentionNote": ""
    }
  ]
}

Rules:

1. title:
   - only the actual work to perform
   - short task name

2. note:
   - product names
   - model names
   - colors
   - codes
   - materials
   - manufacturers
   - article numbers
   - material specifications

3. attentionNote:
    - installation instructions
    - requirements
    - remarks
    - special conditions
    - warnings
    - text placed under tasks
    - project notes
    - guarantees
    - additional information

Examples:

Input:

Montering av tak- samt nockpannor,
Randers RT823. Naturröd.

Output:

{
  "title":
    "Montering av tak- samt nockpannor",

  "note":
    "Randers RT823 Naturröd",

  "attentionNote":
    ""
}

Ignore:

- URLs
- contact information
- legal text
- company presentations
- company marketing text
`/*
Return:

{
  "tasks": [
    "task1",
    "task2"
  ]
}
`,*/
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

      //return parsed.tasks
        //.map((x: string) => x.trim())
        //.filter(Boolean)
        return parsed.tasks
        .filter(
            (task: any) =>
            task?.title,
        )
        .map(
            (task: any) => ({
            title:
                task.title?.trim() || '',

            note:
                task.note?.trim() || '',

            attentionNote:
                task.attentionNote?.trim() || '',
            }),
        )

    } catch (error) {

      this.logger.error(error)

      return []
    }
  }
}