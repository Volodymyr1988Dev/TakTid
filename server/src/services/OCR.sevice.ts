import {
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common'

import {
  createWorker,
  Worker,
  PSM,
} from 'tesseract.js'
import { fromBuffer } from 'pdf2pic'
import sharp from 'sharp'
import * as fs from 'fs/promises'

@Injectable()
export class OcrService
  implements OnModuleInit, OnModuleDestroy {

  private readonly logger =
    new Logger(OcrService.name)

  private worker!: Worker

  async onModuleInit() {

    this.worker =
      await createWorker(
        'swe+eng',
      )

    await this.worker.setParameters({
      tessedit_pageseg_mode: PSM.AUTO,
    })

    this.logger.log(
      'OCR worker initialized',
    )
  }

  async onModuleDestroy() {

    if (this.worker) {
      await this.worker.terminate()
    }
  }
  async recognizePdf(
    buffer: Buffer,
  ): Promise<string> {

    const convert =
      fromBuffer(
        buffer,
        {
          density: 300,
          format: 'png',
          width: 2500,
          height: 3500,
          savePath: './tmp',
        },
      )

    let page = 1

    let fullText = ''

    while (true) {

      try {

        const result =
          await convert(page)

        if (!result?.path) {
          break
        }

        const imageBuffer =
          await fs.readFile(
            result.path,
          )

        const processed =
          await sharp(imageBuffer)
            .rotate()
            .grayscale()
            .normalize()
            .sharpen({ sigma: 1.5 })
            .png()
            .toBuffer()

        const ocr =
          await this.worker.recognize(
            processed,
          )

        fullText +=
          '\n\n' +
          ocr.data.text

        await fs.unlink(
          result.path,
        )

        page++

      } catch {

        break
      }
    }

    return fullText
  }
  async recognize(
    buffer: Buffer,
  ): Promise<string> {

    const processed =
      await sharp(buffer)
        .rotate()
        .grayscale()
        .normalize()
        //.sharpen()
        .sharpen({sigma: 1.5})
        //.threshold(160)
        .resize({
          width: 2200,
          withoutEnlargement: false,
        })
        .png()
        .toBuffer()

    const result =
      await this.worker.recognize(
        processed,
      )
      this.logger.log(`OCR result:\n${result.data.text}`)
    return result.data.text
  }
}