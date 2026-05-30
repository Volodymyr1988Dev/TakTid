import { Injectable } from '@nestjs/common'
import Tesseract from 'tesseract.js'

@Injectable()
export class OcrService {

  async recognize(
    imagePath: string,
  ): Promise<string> {

    const result =
      await Tesseract.recognize(
        imagePath,
        'swe',
      )

    return result.data.text
  }
}