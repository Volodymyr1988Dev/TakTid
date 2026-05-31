import { Injectable, Logger } from '@nestjs/common'
import Tesseract from 'tesseract.js'

@Injectable()
export class OcrService {

  private readonly logger =
    new Logger(OcrService.name)

  async recognize(
    imageBuffer: Buffer,
  ): Promise<string> {

    try {

      const result =
        await Tesseract.recognize(
          imageBuffer,
          'swe',
        )

      return result.data.text

    } catch (error) {

      this.logger.error(
        'OCR failed',
        error instanceof Error
          ? error.stack
          : String(error),
      )

      throw error
    }
  }
}