import { Injectable } from '@nestjs/common';

@Injectable()
export class TaskExtractionService {
  extractTasks(text: string): string[] {
    const cleaned = text

      .replace(/https?:\/\/\S+/gi, '')

      .replace(/www\.\S+/gi, '')

      .replace(/\r/g, '')

      .replace(/\t/g, ' ');
    /*
        .replace(
          /\s+/g,
          ' ',
        )
        */
    const lines = cleaned
      .split('\n')
      .map((x) => x.trim())
      .filter(Boolean);

    const tasks: string[] = [];

    let current = '';

    for (const line of lines) {
      const startsTask = /^[\(\[]?[Oo0●○•]/.test(line) || /^[-•]/.test(line);

      if (startsTask) {
        if (current.length > 20) {
          tasks.push(current.trim());
        }

        current = line.replace(/^[^A-Za-zÅÄÖåäö]+/, '').trim();

        continue;
      }

      current += ` ${line}`;
    }

    if (current.length > 20) {
      tasks.push(current.trim());
    }

    return tasks

      .map((task) =>
        task
          .replace(/\s+/g, ' ')

          .trim(),
      )

      .filter((task) => task.length > 15)

      .filter((task) => !task.includes('garanti'))

      .filter((task) => !task.includes('www'))

      .filter((task) => !task.includes('Övriga överenskommelser'));
  }
}
