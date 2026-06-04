import {
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common'

import {
  createWorker,
  Worker,
} from 'tesseract.js'

import sharp from 'sharp'

@Injectable()
export class OcrService
  implements OnModuleInit, OnModuleDestroy {

  private readonly logger =
    new Logger(OcrService.name)

  private worker!: Worker

  async onModuleInit() {

    this.worker =
      await createWorker('swe+eng')

    this.logger.log(
      'OCR worker initialized',
    )
  }

  async onModuleDestroy() {

    if (this.worker) {
      await this.worker.terminate()
    }
  }

  async recognize(
    buffer: Buffer,
  ): Promise<string> {

    const processed =
      await sharp(buffer)
        .grayscale()
        .normalize()
        .sharpen()
        .png()
        .toBuffer()

    const result =
      await this.worker.recognize(
        processed,
      )

    return result.data.text
  }
}