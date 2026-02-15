export function cleanPatch<T extends object>(obj: T): Partial<T> {
  return Object.fromEntries(
    Object.entries(obj).filter(
      ([_, v]) => v !== undefined
    )
  ) as Partial<T>
}
/*
export function normalizeTime(time?: string | null): string | undefined {
  if (!time) return undefined;
    return time.slice(0, 5);
  
}*/