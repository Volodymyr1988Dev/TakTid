export function cleanPatch<T extends object>(obj: T): Partial<T> {
  return Object.fromEntries(
    Object.entries(obj).filter(
      ([_, v]) => v !== undefined
    )
  ) as Partial<T>
}

export function normalizeTime(time?: string | null): string | undefined {
  if (!time) return undefined;

  // "08:00:00" → "08:00"
  //if (time.length === 8) {
    return time.slice(0, 5);
  //}

  //return time; // "08:00"
}